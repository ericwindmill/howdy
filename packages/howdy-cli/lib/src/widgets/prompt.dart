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
class Prompt extends InteractiveWidget<String> {
  Prompt({
    required super.label,
    super.help,
    super.defaultValue,
    super.validator,
    super.key,
    super.theme,
  });

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

  bool get hasInput => _input.isNotEmpty;

  @override
  String get usage => 'type your answer, enter to submit';

  @override
  KeyResult handleKey(KeyEvent event) {
    switch (event) {
      case SpecialKey(key: Key.enter):
        // Run validator before completing
        if (validator != null) {
          final error = validator!(value);
          if (error != null) {
            this.error = error;
            return KeyResult.consumed;
          }
        }
        error = null;
        _isDone = true;
        return KeyResult.done;
      case SpecialKey(key: Key.backspace):
        error = null;
        if (_input.isNotEmpty) {
          final current = _input.toString();
          _input.clear();
          _input.write(current.substring(0, current.length - 1));
          return KeyResult.consumed;
        }
        return KeyResult.ignored;
      case CharKey(char: final c):
        error = null;
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
  String build(IndentedStringBuffer buf) {
    // The prompt for the user
    buf.writeln(label.style(theme.label));

    // Explain the field to the user
    if (help != null) buf.writeln(help!.style(theme.body));

    // The input line
    buf.indent();
    switch ((isDone, _input.isEmpty)) {
      // When complete
      case (true, _):
        buf.writeln('${Icon.check} $value'.success);
      // When awaiting, and user hasn't typed yet (show default)
      case (false, true):
        buf.writeln(
          '${Icon.pointer.style(theme.pointer)} ${(defaultValue ?? '').style(theme.defaultValue)}',
        );
      // When awaiting more input, and user hasn't pressed enter
      case (false, false):
        buf.writeln(
          '${Icon.pointer.style(theme.pointer)} $_input'.style(
            theme.body,
          ),
        );
    }

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
  String write() {
    // Use a blinking block cursor during text input so the insertion
    // point is clearly visible. Show the cursor (don't hide it).
    terminal.setCursorShape(CursorShape.blinkingBlock);
    terminal.cursorShow();
    _renderAndPosition();

    terminal.runRawModeSync<void>(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);

        if (keyResult == KeyResult.done) {
          return;
        }

        if (keyResult == KeyResult.consumed) {
          // Restore cursor to end of output before updateScreen erases lines.
          _restoreCursorToBottom();
          _renderAndPosition();
        }
      }
    });

    // Restore to bottom so clearScreen erases from the right place.
    _restoreCursorToBottom();

    // Show done state — render() handles isDone, use clearScreen + write
    // so the completed line persists (isn't erased by the next widget).
    terminal.clearScreen();
    terminal.write(render());

    // Restore default cursor shape and hide it for subsequent widgets.
    terminal.resetCursorShape();
    terminal.cursorHide();

    return value;
  }

  // How many lines below the input line were rendered last time.
  int _linesBelow = 0;

  /// Render and reposition the real cursor at the end of the typed input.
  void _renderAndPosition() {
    terminal.updateScreen(render());

    // Lines rendered after the input line when standalone:
    //   writeln()        → blank line
    //   writeln(usage)   → usage line
    //   writeln(error)?  → error line (only when hasError)
    //   writeln()        → blank line
    // +1 because the input line itself ends with \n, putting the cursor
    // one line below the input line before we start counting chrome lines.
    _linesBelow = isStandalone ? (hasError ? 4 : 3) : 0;
    terminal.cursorUp(_linesBelow + 1);

    // Column: 1-indexed. indent=2, pointer=1, space=1, then input chars.
    final col = 2 + 1 + 1 + _input.length + 1;
    terminal.cursorToColumn(col);
  }

  /// Move cursor back to the end of the rendered output so that
  /// [updateScreen]'s erase logic works from the correct position.
  void _restoreCursorToBottom() {
    terminal.cursorDown(_linesBelow + 1);
    terminal.cursorToColumn(1);
  }
}
