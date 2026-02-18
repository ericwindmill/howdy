import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/theme.dart';

/// A single-line text input prompt.
///
/// Uses character-by-character input in raw mode so it can participate
/// in the [handleKey] protocol for form composition.
///
///```txt
/// Title
/// HelperText
/// ❯ [default] OR ❯ current input
/// <error if any>
///```
///
///
/// ```dart
/// final name = Prompt.send('Project name', defaultValue: 'my_app');
/// ```
class Prompt extends InputWidget<String> {
  Prompt({
    required super.label,
    super.help,
    super.defaultValue,
    super.validator,
    TextStyle? labelStyle,
    TextStyle? helpStyle,
    TextStyle? defaultStyle,
    TextStyle? inputStyle,
    TextStyle? cursorStyle,
    TextStyle? successStyle,
    TextStyle? errorStyle,
  }) : labelStyle = labelStyle ?? Theme.current.title,
       helpStyle = helpStyle ?? Theme.current.label,
       defaultStyle = defaultStyle ?? Theme.current.label,
       inputStyle = inputStyle ?? Theme.current.body,
       successStyle = successStyle ?? Theme.current.success,
       errorStyle = errorStyle ?? Theme.current.error,
       cursorStyle = cursorStyle ?? Theme.current.body;

  final TextStyle labelStyle;
  final TextStyle helpStyle;
  final TextStyle defaultStyle;
  final TextStyle inputStyle;
  final TextStyle cursorStyle;
  final TextStyle successStyle;
  final TextStyle errorStyle;

  /// Convenience factory, uses active theme values
  static String send(
    String label, {
    String? description,
    String? defaultValue,
    Validator<String>? validator,
  }) {
    return Prompt(
      label: label,
      help: description,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  /// The text buffer being built character by character.
  final StringBuffer _input = StringBuffer();
  bool _isDone = false;

  String? _error;

  bool get hasInput => _input.isNotEmpty;

  @override
  KeyResult handleKey(KeyEvent event) {
    switch (event) {
      case SpecialKey(key: Key.enter):
        // Run validator before completing
        if (validator != null) {
          final error = validator!(value);
          if (error != null) {
            _error = error;
            return KeyResult.consumed;
          }
        }
        _error = null;
        _isDone = true;
        return KeyResult.done;
      case SpecialKey(key: Key.backspace):
        _error = null;
        if (_input.isNotEmpty) {
          final current = _input.toString();
          _input.clear();
          _input.write(current.substring(0, current.length - 1));
          return KeyResult.consumed;
        }
        return KeyResult.ignored;
      case CharKey(char: final c):
        _error = null;
        _input.write(c);
        return KeyResult.consumed;
      default:
        return KeyResult.ignored;
    }
  }

  @override
  String get value {
    final input = _input.toString();
    return input.isEmpty ? (defaultValue ?? '') : input;
  }

  @override
  bool get isDone => _isDone;

  @override
  String build(StringBuffer buf) {
    final parts = [
      // The prompt for the user
      label.style(labelStyle),

      // Explain the field to the user
      if (help != null) help!.style(helpStyle),

      // The input line
      switch ((isDone, _input.isEmpty)) {
        // When complete
        (true, _) => '${Icon.check} $value'.success,

        // When awaiting, and user hasn't typed yet (show default)
        (false, true) => '${Icon.cursor} ${defaultValue ?? ''}'.style(
          labelStyle,
        ),

        // When awaiting, and user hasn't pressed enter
        (false, false) => '${Icon.cursor} $_input'.style(inputStyle),
      },

      // Reserve a line for the error, regardless of whether it exists
      hasError ? '${Icon.error} $_error'.style(errorStyle) : '',
    ];

    buf.writeAll(parts, '\n');
    return buf.toString();
  }

  @override
  String write() {
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

    // Show done state — render() handles isDone, use clearScreen + write
    // so the completed line persists (isn't erased by the next widget).
    terminal.clearScreen();
    terminal.write(render());
    terminal.cursorShow();

    return value;
  }
}
