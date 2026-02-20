import 'package:howdy/howdy.dart';

/// A yes/no confirmation prompt.
///
/// Use ← / → (or 'y'/'n') to choose, Enter to submit.
///
///```txt
/// Delete everything?
///   ← Yes    No →
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
  }) {
    _isYes = defaultValue ?? false;
  }

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

  late bool _isYes;
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

  @override
  String get usage => usageHint([
    (keys: '${Icon.arrowLeft} / ${Icon.arrowRight}', action: 'choose'),
    (keys: 'enter', action: 'submit'),
  ]);

  @override
  KeyResult handleKey(KeyEvent event) {
    switch (event) {
      // Arrow / y / n update the selection without submitting
      case SpecialKey(key: Key.arrowLeft):
      case CharKey(char: 'y' || 'Y'):
        _isYes = true;
        return KeyResult.consumed;
      case SpecialKey(key: Key.arrowRight):
      case CharKey(char: 'n' || 'N'):
        _isYes = false;
        return KeyResult.consumed;
      case SpecialKey(key: Key.enter):
        final chosen = _isYes;
        if (validator != null) {
          final err = validator!(chosen);
          if (err != null) {
            error = err;
            return KeyResult.consumed;
          }
        }
        error = null;
        _isDone = true;
        return KeyResult.done;
      default:
        return KeyResult.ignored;
    }
  }

  @override
  void reset() {
    super.reset();
    _isYes = defaultValue ?? false;
    _isDone = false;
  }

  @override
  bool get value => _isYes;

  @override
  String build(IndentedStringBuffer buf) {
    buf.writeln(label.style(fieldStyle.title));
    if (help != null) buf.writeln(help!.style(fieldStyle.description));
    buf.writeln();

    if (isDone) {
      buf.writeln('${Icon.check} ${_isYes ? 'Yes' : 'No'}'.success);
    } else {
      // Render both options inline; highlight the active one.
      final yesStyle = _isYes
          ? fieldStyle.confirm.focusedButton
          : fieldStyle.confirm.blurredButton;
      final noStyle = !_isYes
          ? fieldStyle.confirm.focusedButton
          : fieldStyle.confirm.blurredButton;

      final yes = ' Yes '.style(yesStyle);
      final no = ' No '.style(noStyle);
      buf.writeln('$yes $no');
    }

    if (isStandalone) {
      buf.writeln();
      buf.writeln(usage.style(theme.help.shortDesc));
      if (hasError) {
        buf.writeln('${Icon.error} $error'.style(fieldStyle.errorMessage));
      }
      buf.writeln();
    }
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
        if (keyResult == KeyResult.done) return;
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
