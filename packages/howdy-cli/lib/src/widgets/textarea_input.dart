import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/wrap.dart';

/// A multi-line text input prompt.
///
/// Visually renders with a `│` left-border on each line and uses
/// Enter to insert newlines. Press **Ctrl+J** to submit.
///
///```txt
/// Title
/// HelperText
/// │ [default] OR │ current input line 1
/// │ current input line 2
/// <error if any>
///```
///
/// ```dart
/// final desc = Textarea.send(
///   'Description',
///   help: 'A brief summary of your project',
/// );
/// ```
class Textarea extends InputWidget<String> {
  Textarea(
    super.title, {
    TextAreaKeyMap? keymap,
    super.help,
    super.defaultValue,
    super.validator,
    super.key,
    super.theme,
  }) : keymap = keymap ?? defaultKeyMap.textArea;

  /// Convenience factory for textareas.
  static String send(
    String label, {
    TextAreaKeyMap? keymap,
    String? help,
    String? defaultValue,
    Validator<String>? validator,
  }) {
    return Textarea(
      label,
      keymap: keymap,
      help: help,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  @override
  final TextAreaKeyMap keymap;

  /// The text buffer being built character by character.
  final StringBuffer _input = StringBuffer();
  bool _isDone = false;

  // How many trailing pipes were added (to offset cursor calculations).
  int _trailingPipesCounter = 0;

  // How many lines below the input line were rendered last time.
  int _linesBelow = 0;

  bool get hasInput => _input.isNotEmpty;

  @override
  bool get isDone => _isDone;

  @override
  KeyResult handleKey(KeyEvent event) {
    if (keymap.submit.matches(event)) {
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
    } else if (keymap.newline.matches(event)) {
      error = null;
      _input.write('\n');
      return KeyResult.consumed;
    } else if (event == const SpecialKey(Key.backspace)) {
      error = null;
      if (_input.isNotEmpty) {
        final current = _input.toString();
        _input.clear();
        _input.write(current.substring(0, current.length - 1));
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    } else if (event == const SpecialKey(Key.space)) {
      error = null;
      _input.write(' ');
      return KeyResult.consumed;
    } else if (event is CharKey) {
      error = null;
      _input.write(event.char);
      return KeyResult.consumed;
    }
    return KeyResult.ignored;
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
    // The rendered string is wrapped by updateScreen, so we must
    // wrap it here to calculate the correct physical lines.
    final wrapped = rendered.wordWrap(terminal.columns);
    final lines = wrapped.split('\n');
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();

    int inputLineIndex;
    if (_input.isEmpty) {
      // If empty, the cursor is placed on the first pipe line (the placeholder).
      inputLineIndex = lines.indexWhere((l) => l.contains(Icon.pipe));
    } else {
      // We added trailing pipes at the bottom of the input. Each trailing pipe is 1 wrap line.
      // So the last user input line is exactly _trailingPipesCounter lines above the last pipe.
      inputLineIndex =
          lines.lastIndexWhere((l) => l.contains(Icon.pipe)) -
          _trailingPipesCounter;
    }

    if (inputLineIndex != -1) {
      _linesBelow = lines.length - 1 - inputLineIndex;
      terminal.cursorUp(_linesBelow + 1);

      // The cursor should be at the end of the visible text, or start of placeholder.
      final col = _input.isEmpty
          ? Icon.pipe.visibleLength + 2
          : lines[inputLineIndex].visibleLength + 1;
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

  void _applyTrailingPipes(
    IndentedStringBuffer buf,
    String pipeChar, [
    int? physicalLineCount,
  ]) {
    final lineCount =
        physicalLineCount ??
        (_input.isEmpty ? 1 : _input.toString().split('\n').length);
    if (lineCount < 3) {
      _trailingPipesCounter = 3 - lineCount;
    } else {
      _trailingPipesCounter = 1;
    }

    for (int i = 0; i < _trailingPipesCounter; i++) {
      buf.writeln(pipeChar);
    }
  }

  @override
  String get value {
    final input = _input.toString();
    return input.isEmpty ? (defaultValue ?? '') : input;
  }

  @override
  String build(IndentedStringBuffer buf) {
    // Title
    if (title != null) buf.writeln(title!.style(fieldStyle.title));

    // Help / description
    if (help != null) buf.writeln(help!.style(fieldStyle.description));

    // If no max width, give it one so long text areas don't span the whole terminal.
    int? currentMaxWidth = terminal.maxWidth;
    terminal.maxWidth ??= 60;
    final cursor = ' '.style(fieldStyle.text.cursor);
    if (isDone && !isFocused) {
      buf.writeln('${Icon.check} $value'.style(fieldStyle.successMessage));
    } else {
      final pipe = renderContext == RenderContext.single
          ? '${Icon.pipe.style(fieldStyle.text.prompt)} '
          : '';
      if (_input.isEmpty) {
        if (renderContext == RenderContext.form) {
          buf.writeln(
            '${Icon.question.style(fieldStyle.text.prompt)} ${(defaultValue ?? '').style(fieldStyle.text.placeholder)}',
          );
        } else {
          buf.writeln(
            '$pipe${(defaultValue ?? '').style(fieldStyle.text.placeholder)}',
          );
        }
        _applyTrailingPipes(buf, pipe, 1);
      } else {
        final wrapWidth = terminal.maxWidth! - 2; // Subtract pipe prefix width
        final lines = _input.toString().split('\n');
        int physicalLineCount = 0;

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final wrappedLine = line.wordWrap(wrapWidth);
          final wrappedSublines = wrappedLine.split('\n');
          final isLastLine = i == lines.length - 1;
          for (int j = 0; j < wrappedSublines.length; j++) {
            physicalLineCount++;
            final isLastSubline = isLastLine && j == wrappedSublines.length - 1;
            final content =
                '$pipe${wrappedSublines[j].style(fieldStyle.text.text)}';
            buf.writeln(isLastSubline ? '$content$cursor' : content);
          }
        }

        // styled block
        terminal.maxWidth = currentMaxWidth;
        _applyTrailingPipes(buf, pipe, physicalLineCount);
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
