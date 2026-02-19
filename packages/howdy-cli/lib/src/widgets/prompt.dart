import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';

/// A text input prompt.
///
/// Use the default constructor for single-line questions, or [Prompt.textarea]
/// to indicate intent for longer-form input (e.g. descriptions, logs).
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
/// ```dart
/// final name = Prompt.send('Project name', defaultValue: 'my_app');
///
/// final desc = Prompt.textarea(
///   label: 'Description',
///   help: 'A brief summary of your project',
/// ).write();
/// ```
class Prompt extends InteractiveWidget<String> {
  Prompt({
    required super.label,
    super.help,
    super.defaultValue,
    super.validator,
    super.key,
    super.theme,
  }) : _isTextarea = false;

  /// Named constructor for longer-form, multi-line input.
  ///
  /// Visually renders with a `│` left-border on each line and uses
  /// Enter to insert newlines.  Press **Ctrl+D** to submit.
  Prompt.textarea({
    required super.label,
    super.help,
    super.defaultValue,
    super.validator,
    super.key,
    super.theme,
  }) : _isTextarea = true;

  /// Convenience factory for single-line prompts.
  static String send(
    String label, {
    String? help,
    String? defaultValue,
    Validator<String>? validator,
  }) {
    return Prompt(
      label: label,
      help: help,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  /// Convenience factory for longer-form prompts.
  static String sendTextarea(
    String label, {
    String? help,
    String? defaultValue,
    Validator<String>? validator,
  }) {
    return Prompt.textarea(
      label: label,
      help: help,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  /// Whether this prompt accepts multi-line input.
  final bool _isTextarea;

  /// The text buffer being built character by character.
  final StringBuffer _input = StringBuffer();
  bool _isDone = false;

  // How many lines below the input line were rendered last time.
  int _linesBelow = 0;

  bool get hasInput => _input.isNotEmpty;

  @override
  bool get isDone => _isDone;

  @override
  String get usage => _isTextarea
      ? usageHint([
          (keys: 'type your answer', action: ''),
          (keys: 'enter', action: 'newline'),
          (keys: 'ctrl+d', action: 'submit'),
        ])
      : usageHint([
          (keys: 'type your answer', action: ''),
          (keys: 'enter', action: 'submit'),
        ]);

  @override
  KeyResult handleKey(KeyEvent event) {
    switch (event) {
      // ── Submit ─────────────────────────────────────────────────────
      // Single-line: Enter submits.  Textarea: Ctrl+D submits.
      case SpecialKey(key: Key.enter) when !_isTextarea:
      case SpecialKey(key: Key.ctrlD) when _isTextarea:
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

      // ── Newline (textarea only) ───────────────────────────────────
      case SpecialKey(key: Key.enter) when _isTextarea:
        error = null;
        _input.write('\n');
        return KeyResult.consumed;

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
  void reset() {
    super.reset();
    _input.clear();
    _isDone = false;
  }

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

  @override
  String get value {
    final input = _input.toString();
    return input.isEmpty ? (defaultValue ?? '') : input;
  }

  @override
  String build(IndentedStringBuffer buf) {
    // Title
    buf.writeln(label.style(fieldStyle.title));

    // Help / description
    if (help != null) buf.writeln(help!.style(fieldStyle.description));

    buf.indent();
    if (isDone) {
      // ── Completed state (same for both modes) ───────────────────
      buf.writeln('${Icon.check} $value'.success);
    } else if (_isTextarea) {
      // ── Textarea: multi-line with │ left-border ─────────────────
      final pipe = Icon.pipe.style(fieldStyle.text.prompt);
      if (_input.isEmpty) {
        buf.writeln(
          '$pipe ${(defaultValue ?? '').style(fieldStyle.text.placeholder)}',
        );
      } else {
        final lines = _input.toString().split('\n');
        for (final line in lines) {
          buf.writeln('$pipe ${line.style(fieldStyle.text.text)}');
        }
      }
    } else {
      // ── Single-line: original ❯ pointer ─────────────────────────
      if (_input.isEmpty) {
        buf.writeln(
          '${Icon.pointer.style(fieldStyle.text.prompt)} '
          '${(defaultValue ?? '').style(fieldStyle.text.placeholder)}',
        );
      } else {
        buf.writeln(
          '${Icon.pointer.style(fieldStyle.text.prompt)} '
                  '$_input'
              .style(fieldStyle.text.text),
        );
      }
    }

    if (isStandalone) {
      buf.writeln();
      buf.writeln(usage.style(theme.help.shortDesc));
      if (hasError) {
        buf.writeln(
          '${Icon.error} $error'.style(fieldStyle.errorMessage),
        );
      }
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
}
