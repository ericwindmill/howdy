import 'package:howdy/howdy.dart';

/// A structural widget that displays a label and pauses the form
/// until the user presses Enter.
///
/// It does not collect any input data and always returns `void`.
///
/// ```dart
/// NextButton(label: 'Continue');
/// ```
class NextButton extends InteractiveWidget<void> {
  NextButton({
    required super.label,
    PageKeyMap? keymap,
    super.key,
    super.theme,
    this.next = true,
  }) : keymap = keymap ?? defaultKeyMap.page;

  /// Convenience factory, uses active theme values.
  static void send(String label, {PageKeyMap? keymap}) {
    NextButton(
      label: label,
      keymap: keymap,
    ).write();
  }

  final PageKeyMap keymap;
  bool _isDone = false;

  final bool next;

  @override
  bool get isDone => _isDone;

  @override
  String get usage => usageHint([
    (keys: keymap.next.helpKey, action: 'submit'),
  ]);

  @override
  void get value {}

  @override
  KeyResult handleKey(KeyEvent event) {
    if (keymap.next.matches(event)) {
      _isDone = true;
      return KeyResult.done;
    }
    return KeyResult.ignored;
  }

  @override
  void reset() {
    super.reset();
    _isDone = false;
  }

  @override
  String build(IndentedStringBuffer buf) {
    if (isDone) {
      buf.writeln('${Icon.check} $label'.success);
    } else {
      final button = ' $label ${Icon.arrowRight} '.style(
        fieldStyle.confirm.focusedButton,
      );
      buf.writeln(button);
    }

    if (!isDone && isStandalone) {
      buf.writeln();
      buf.writeln(usage.style(theme.help.shortDesc));
      buf.writeln();
    }
    return buf.toString();
  }

  @override
  void write() {
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
  }
}
