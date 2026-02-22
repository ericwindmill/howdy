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

/// The rendering context for an interactive widget.
///
/// Controls whether the widget renders its own chrome (error messages,
/// control hints) or defers to a parent container.
enum RenderContext {
  /// Sginle — widget owns all chrome (error line, control hints).
  single,

  /// Inside a container (e.g. [Form]) — container owns error and controls.
  form,
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

  /// The rendering context for this widget.
  ///
  /// Defaults to [RenderContext.single] for standalone usage.
  /// Parent containers (e.g. [Form]) set this to
  /// [RenderContext.form] to take ownership of error display
  /// and control hints.
  RenderContext renderContext = RenderContext.single;

  /// Whether this widget is rendering standalone (i.e. owns its chrome).
  bool get isStandalone => renderContext == RenderContext.single;

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
