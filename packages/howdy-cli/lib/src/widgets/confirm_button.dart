import 'package:howdy/src/framework/icons.dart';
import 'package:howdy/src/framework/indented_string_buffer.dart';
import 'package:howdy/src/framework/keymap/keymap.dart';
import 'package:howdy/src/framework/render_state.dart';
import 'package:howdy/src/framework/validate.dart';
import 'package:howdy/src/framework/widget/widget.dart';
import 'package:howdy/src/terminal/key_event.dart';
import 'package:howdy/src/terminal/styled_text.dart';

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
class ConfirmInput extends InputWidget<bool> {
  ConfirmInput(
    super.title, {
    super.help,
    super.key,
    super.defaultValue = false,
    super.validator,
    super.theme,
    ConfirmKeyMap? keymap,
  }) {
    keymap ??= defaultKeyMap.confirm;
  }

  /// Convenience factory for standalone widget.
  /// Uses active theme values and keymap
  static bool send(
    String title, {
    String? help,
    bool defaultValue = false,
    Validator<bool>? validator,
  }) {
    var widget = ConfirmInput(
      title,
      help: help,
      defaultValue: defaultValue,
      validator: validator,
    );

    widget.write();
    return widget.value;
  }

  bool _isDone = false;

  bool _value = true;

  @override
  ConfirmKeyMap keymap = defaultKeyMap.confirm;

  @override
  bool get isDone => _isDone;

  @override
  KeyResult handleKey(KeyEvent event) {
    if (keymap.toggle.matches(event)) {
      _value = !_value;
      return KeyResult.consumed;
    } else if (keymap.accept.matches(event)) {
      _value = true;
      return KeyResult.consumed;
    } else if (keymap.reject.matches(event)) {
      _value = false;
      return KeyResult.consumed;
    } else if (keymap.submit.matches(event)) {
      final chosen = _value;
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
  bool get value => _value;

  @override
  String build(IndentedStringBuffer buf) {
    if (title != null) buf.writeln(title!.style(fieldStyle.title));
    if (help != null) buf.writeln(help!.style(fieldStyle.description));
    buf.writeln();

    if (isDone) {
      buf.writeln(
        '${Icon.check} ${_value ? 'Yes' : 'No'}'.style(
          fieldStyle.successMessage,
        ),
      );
    } else {
      // Render both options inline; highlight the active one.
      final yesStyle = _value
          ? fieldStyle.confirm.focusedButton
          : fieldStyle.confirm.blurredButton;
      final noStyle = !_value
          ? fieldStyle.confirm.focusedButton
          : fieldStyle.confirm.blurredButton;

      final yes = ' Yes '.style(yesStyle);
      final no = ' No '.style(noStyle);
      buf.writeln('$yes $no');
    }

    // Chrome: usage hint + error — only shown when standalone.
    // When inside a form, parent owns this chrome.
    switch (renderState) {
      case RenderState.editing:
      case RenderState.waiting:
      case RenderState.waitingInForm:
      case RenderState.editingInForm:
      case RenderState.completeInForm:
        if (!renderState.isFormElement) {
          buf.writeln();
          buf.writeln(usage.style(theme.help.shortDesc));
          buf.writeln();
          buf.writeln();
        }
      case RenderState.error:
        buf.writeln();
        buf.writeln(usage.style(theme.help.shortDesc));
        buf.writeln('${Icon.error} $error'.style(fieldStyle.errorMessage));
        buf.writeln();
      case RenderState.errorInForm:
        break; // form owns chrome
      case RenderState.verified:
      case RenderState.verifiedInForm:
        break; // form owns chrome
    }
    return buf.toString();
  }
}
