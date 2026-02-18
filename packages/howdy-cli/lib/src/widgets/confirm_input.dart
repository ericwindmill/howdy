import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/theme.dart';

/// A yes/no confirmation prompt.
///
/// The user presses `y`/`n` or Enter (to accept the default).
///
///```txt
/// Are you sure? (Y/n)
///```
///
/// ```dart
/// final ok = ConfirmInput.send('Delete everything?', defaultValue: false);
/// ```
class ConfirmInput extends InputWidget<bool> {
  ConfirmInput({
    required super.label,
    super.help,
    bool defaultValue = false,
    Validator<bool>? validator,
    TextStyle? labelStyle,
    TextStyle? helpStyle,
    TextStyle? hintStyle,
    TextStyle? successStyle,
    TextStyle? errorStyle,
    TextStyle? valueStyle,
  }) : _defaultValue = defaultValue,
       _validator = validator,
       labelStyle = labelStyle ?? Theme.current.title,
       helpStyle = helpStyle ?? Theme.current.label,
       hintStyle = hintStyle ?? Theme.current.label,
       successStyle = successStyle ?? Theme.current.success,
       errorStyle = errorStyle ?? Theme.current.error,
       valueStyle = valueStyle ?? Theme.current.body;

  final bool _defaultValue;
  final Validator<bool>? _validator;

  final TextStyle labelStyle;
  final TextStyle helpStyle;
  final TextStyle hintStyle;
  final TextStyle successStyle;
  final TextStyle errorStyle;
  final TextStyle valueStyle;

  bool _value = false;
  bool _isDone = false;
  String? _error;

  /// Convenience factory, uses active theme values.
  static bool send(
    String label, {
    String? description,
    bool defaultValue = false,
    Validator<bool>? validator,
  }) {
    return ConfirmInput(
      label: label,
      help: description,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  String get _hint => _defaultValue ? 'Y/n' : 'y/N';

  @override
  KeyResult handleKey(KeyEvent event) {
    bool? chosen;
    switch (event) {
      case CharKey(char: 'y' || 'Y'):
        chosen = true;
      case CharKey(char: 'n' || 'N'):
        chosen = false;
      case SpecialKey(key: Key.enter):
        chosen = _defaultValue;
      default:
        return KeyResult.ignored;
    }

    // Run validator before completing
    if (_validator != null) {
      final error = _validator(chosen);
      if (error != null) {
        _error = error;
        return KeyResult.consumed;
      }
    }

    _error = null;
    _value = chosen;
    _isDone = true;
    return KeyResult.done;
  }

  @override
  bool get value => _isDone ? _value : _defaultValue;

  @override
  bool get isDone => _isDone;

  @override
  String build(StringBuffer buf) {
    final parts = [
      // The prompt label
      label.style(labelStyle),

      // Optional help text
      if (help != null) help!.style(helpStyle),

      // The input / result line
      if (isDone)
        '${Icon.check} ${_value ? 'Yes' : 'No'}'.success
      else
        '${Icon.cursor} ($_hint)'.style(hintStyle),

      // Reserve a line for the error, regardless of whether it exists
      hasError ? '${Icon.error} $_error'.style(errorStyle) : '',
    ];

    buf.writeAll(parts, '\n');
    return buf.toString();
  }

  @override
  bool write() {
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
