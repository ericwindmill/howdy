part of 'widget.dart';

abstract class InputWidget<T> extends Widget<T> {
  InputWidget(
    super.title, {
    super.help,
    this.defaultValue,
    this.validator,
    super.key,
    super.theme,
  });

  /// If set, the value returned by the widget if the input is left blank.
  final T? defaultValue;

  /// The current validation error, if any. Null means valid.
  ///
  /// Subclasses set this in [handleKey] when validation fails.
  /// Parent containers (e.g. [Form]) read this to display errors
  /// in a centralized location.
  String? error;

  final Validator<T>? validator;

  bool get hasDefault => defaultValue != null;

  bool get hasError => error != null;

  @override
  void reset() {
    error = null;
  }

  /// Process a key event. Override for interactive widgets.
  ///
  /// Returns [KeyResult.consumed] if the key changed widget state,
  /// [KeyResult.ignored] if it wasn't relevant, or [KeyResult.done]
  /// if the widget has finished collecting input.
  @override
  KeyResult handleKey(KeyEvent event) => KeyResult.ignored;

  @override
  FutureOr<T> write() {
    terminal.cursorHide();
    terminal.updateScreen(render());

    terminal.runRawModeSync<void>(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);

        if (keyResult == KeyResult.done) {
          return;
        }

        if (keyResult == KeyResult.consumed) {
          terminal.updateScreen(render());
        }
      }
    });

    terminal.clearScreen();
    terminal.write(render());
    terminal.cursorShow();

    return value;
  }
}
