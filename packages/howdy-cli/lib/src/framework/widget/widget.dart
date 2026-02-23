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

/// Encapsulates the four boolean axes that drive [RenderState] for a widget.
///
/// Provides private backing fields, public setters (used by parent containers
/// such as [Form] and [Page]), and the [renderState] getter that derives the
/// correct [RenderState] value from those fields.
///
/// All widget base classes use this mixin so the state-management logic lives
/// in one place.  Widget `build` methods should consume [renderState] rather
/// than any individual field.
mixin RenderStateMixin {
  /// Whether this widget is currently focused in a group or form.
  bool _isFocused = true;

  /// Whether the widget has finished collecting input.
  bool _isComplete = false;

  bool _isFormElement = false;

  /// Whether the widget currently has a validation error.
  /// [InputWidget] overrides [hasError] to check its [error] field instead.
  bool _hasError = false;

  set isFocused(bool value) {
    _isFocused = value;
  }

  set isComplete(bool value) {
    _isComplete = value;
  }

  set isFormElement(bool value) {
    _isFormElement = value;
  }

  set hasError(bool value) {
    _hasError = value;
  }

  /// Whether the widget currently has a validation error.
  ///
  /// Overridden by [InputWidget] to return `error != null`.
  bool get hasError => _hasError;

  /// Whether the widget has finished collecting input.
  ///
  /// Overridden by concrete input widgets.
  bool get isDone => _isComplete;

  /// The current render state derived from widget properties.
  RenderState get renderState {
    return RenderState.get((
      isFocused: _isFocused,
      isComplete: isDone,
      isFormElement: _isFormElement,
      hasError: hasError,
    ));
  }
}

/// Base class for all terminal widgets.
sealed class Widget<T> with RenderStateMixin {
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

  /// Keys that perform actions while this widget is focused.
  KeyMap get keymap => NoActionKeyMap();

  /// Optional theme override for this widget.
  /// Falls back to [Theme.current] if not provided.
  final Theme theme;

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

  /// Convenience getter — returns [theme.focused] or [theme.blurred]
  /// based on the current [renderState].
  ///
  /// Widget `build` methods should use this instead of accessing
  /// `theme.focused` / `theme.blurred` directly so the focused/blurred
  /// decision is always derived from [renderState].
  FieldStyles get fieldStyle =>
      renderState.isFocused ? theme.focused : theme.blurred;

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
