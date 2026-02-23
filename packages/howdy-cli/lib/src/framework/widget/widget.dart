import 'dart:async';

import 'package:howdy/howdy.dart';

part 'multi_widget.dart';
part 'display_widget.dart';
part 'input_widget.dart';

/// How a widget responded to a key event.
enum KeyResult {
  /// Key was processed, widget state changed (triggers re-render).
  consumed,

  /// Key was not relevant to this widget.
  ignored,

  /// Widget is finished — [value] is the final answer.
  done,
}

/// Base class for all terminal widgets.
sealed class Widget<T> {
  Widget(
    this.title, {
    this.help,
    this.key,
    Theme? theme,
  }) : theme = theme ?? Theme.current;

  /// The main text displayed by this widget.
  final String? title;

  /// Helper text for this widget.
  final String? help;

  /// Used for easy retrieval of results in [MultiWidgetResults]
  String? key;

  /// Whether this widget is currently focused in a group or form.
  bool isFocused = true;

  /// Keys that perform actions while this widget is focused.
  KeyMap get keymap => NoActionKeyMap();

  /// Optional theme override for this widget.
  /// Falls back to [Theme.current] if not provided.
  final Theme theme;

  /// The active style based on focus state.
  FieldStyles get fieldStyle => isFocused ? theme.focused : theme.blurred;

  /// Whether the widget has finished collecting input.
  bool get isDone => false;

  /// Whether the widget currently has a validation error.
  /// InputWidget overrides this to check the error field.
  bool get hasError => false;

  /// The widget's current value.
  ///
  /// For input widgets, this may be a partial/default value until
  /// [isDone] is true.
  T get value;

  /// The control hint text for this widget (e.g. "space to toggle, enter to submit").
  ///
  /// Displayed below the widget when rendering standalone.
  /// Read by parent containers (e.g. [Form]) to show contextual guide text.
  String get usage => keymap.usage;

  KeyResult handleKey(KeyEvent event) => KeyResult.done;

  /// Whether this widget is inside a form/page container.
  ///
  /// When true, the parent container owns chrome (error messages, usage hints).
  /// Set to true by [Form] when adding widgets to a page.
  bool isFormElement = false;

  /// Whether this widget is rendering standalone (i.e. owns its chrome).
  bool get isStandalone => !isFormElement;

  /// The current render state derived from widget properties.
  RenderState get renderState => RenderState.get((
    isFocused: isFocused,
    isComplete: isDone,
    isFormElement: isFormElement,
    hasError: hasError,
  ));

  /// Reset the widget to its initial (unfilled) state.
  ///
  /// Called by [Form] when the user navigates back to a previous page.
  void reset() {}

  /// Render current visual state as a string. Does NOT write to output.
  /// Usually you want to override [build] instead of [render].
  String render() {
    final buf = IndentedStringBuffer();
    final str = build(buf);
    return str;
  }

  /// Build the widget's visual output into [buf].
  ///
  /// Use [IndentedStringBuffer.indent] and [IndentedStringBuffer.dedent]
  /// to control indentation instead of hardcoding spaces.
  String build(IndentedStringBuffer buf);

  /// Run standalone — manages raw mode, reads keys, writes to output.
  ///
  /// This is the convenience wrapper that wires [render] and
  /// [handleKey] together with terminal IO for one-off usage.
  FutureOr<void> write();
}

mixin FormElement on Widget {}
