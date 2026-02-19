import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';

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
class TextInput extends InteractiveWidget<String> {
  TextInput({
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
    String? help,
    String? defaultValue,
    Validator<String>? validator,
  }) {
    return TextInput(
      label: label,
      help: help,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  /// The text buffer being built character by character.
  final StringBuffer _input = StringBuffer();
  bool _isDone = false;

  bool get hasInput => _input.isNotEmpty;

  @override
  String get usage => usageHint([
    (keys: 'type your answer', action: ''),
    (keys: 'enter', action: 'submit'),
  ]);

  @override
  void reset() {
    super.reset();
    _input.clear();
    _isDone = false;
  }

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

    // Restore default cursor shape and show it to release the session.
    terminal.resetCursorShape();
    terminal.cursorShow();

    return value;
  }

  // How many lines below the input line were rendered last time.
  int _linesBelow = 0;

  /// Render and reposition the real cursor at the end of the typed input.
  void _renderAndPosition() {
    final rendered = render();
    terminal.updateScreen(rendered);

    // Track rows to handle manual wrapping correctly.
    final lines = rendered.split('\n');
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();

    // Find the row containing the pointer (the input row).
    final inputLineIndex = lines.indexWhere((l) => l.contains(Icon.pointer));

    if (inputLineIndex != -1) {
      _linesBelow = lines.length - 1 - inputLineIndex;
      terminal.cursorUp(_linesBelow + 1);

      // Extract the line and find where the cursor should be.
      // The cursor should be at the end of the visible text.
      final col = lines[inputLineIndex].visibleLength + 1;
      terminal.cursorToColumn(col);
    } else {
      _linesBelow = 0;
    }
  }

  /// Move cursor back to the end of the rendered output so that
  /// [updateScreen]'s erase logic works from the correct position.
  void _restoreCursorToBottom() {
    terminal.cursorDown(_linesBelow + 1);
    terminal.cursorToColumn(1);
  }
}
