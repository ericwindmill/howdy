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
class ConfirmInput extends InteractiveWidget<bool> {
  ConfirmInput({
    required super.label,
    super.key,
    super.help,
    super.defaultValue = false,
    super.validator,
    super.theme,
  });

  bool _value = false;
  bool _isDone = false;

  @override
  String get usage => 'y/n to choose, enter to submit';

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

  String get _hint => (defaultValue ?? false) ? 'Y/n' : 'y/N';

  @override
  KeyResult handleKey(KeyEvent event) {
    bool? chosen;
    switch (event) {
      case CharKey(char: 'y' || 'Y'):
        chosen = true;
      case CharKey(char: 'n' || 'N'):
        chosen = false;
      case SpecialKey(key: Key.enter):
        chosen = defaultValue ?? false;
      default:
        return KeyResult.ignored;
    }

    // Run validator before completing
    if (validator != null) {
      final error = validator!(chosen);
      if (error != null) {
        this.error = error;
        return KeyResult.consumed;
      }
    }

    error = null;
    _value = chosen;
    _isDone = true;
    return KeyResult.done;
  }

  @override
  bool get value => _isDone ? _value : (defaultValue ?? false);

  @override
  bool get isDone => _isDone;

  @override
  String build(IndentedStringBuffer buf) {
    // The prompt label
    buf.writeln(label.style(theme.label));

    // Optional help text
    if (help != null) buf.writeln(help!.style(theme.body));

    // The input / result line
    buf.indent();
    if (isDone) {
      buf.writeln('${Icon.check} ${_value ? 'Yes' : 'No'}'.success);
    } else {
      buf.writeln(
        '${Icon.pointer} ($_hint)'.style(theme.defaultValue),
      );
    }

    // Reserve a line for the error, regardless of whether it exists
    if (isStandalone) {
      buf.writeln();
      buf.writeln(usage.dim);
      hasError ? buf.writeln('${Icon.error} $error'.style(theme.error)) : '';
      buf.writeln();
    }
    buf.dedent();
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
