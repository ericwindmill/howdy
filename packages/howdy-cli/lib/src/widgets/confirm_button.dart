import 'package:howdy/src/framework/icons.dart';
import 'package:howdy/src/framework/indented_string_buffer.dart';
import 'package:howdy/src/framework/keymap/keymap.dart';
import 'package:howdy/src/framework/theme.dart';
import 'package:howdy/src/framework/validate.dart';
import 'package:howdy/src/framework/widget/widget.dart';
import 'package:howdy/src/terminal/key_event.dart';
import 'package:howdy/src/terminal/styled_text.dart';
import 'package:howdy/src/terminal/terminal.dart';

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
    ConfirmKeyMap? keymap,
    super.key,
    super.help,
    super.defaultValue = false,
    super.validator,
    super.theme,
  }) : keymap = keymap ?? defaultKeyMap.confirm {
    _isYes = defaultValue ?? false;
  }

  /// Convenience factory, uses active theme values.
  static bool send(
    String label, {
    ConfirmKeyMap? keymap,
    String? description,
    bool defaultValue = false,
    Validator<bool>? validator,
  }) {
    return ConfirmInput(
      label: label,
      keymap: keymap,
      help: description,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  @override
  final ConfirmKeyMap keymap;
  late bool _isYes;
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

  @override
  KeyResult handleKey(KeyEvent event) {
    if (keymap.toggle.matches(event)) {
      _isYes = !_isYes;
      return KeyResult.consumed;
    } else if (keymap.accept.matches(event)) {
      _isYes = true;
      return KeyResult.consumed;
    } else if (keymap.reject.matches(event)) {
      _isYes = false;
      return KeyResult.consumed;
    } else if (keymap.submit.matches(event)) {
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
    }
    return KeyResult.ignored;
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
