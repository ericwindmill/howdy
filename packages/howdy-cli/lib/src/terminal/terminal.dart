import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:howdy/src/terminal/key_event.dart';
import 'package:howdy/src/terminal/styled_text.dart';

Terminal get terminal {
  return Terminal();
}

/// Central I/O service for terminal interaction.
///
/// Consolidates all output (cursor, erase, styled text), _input
/// (raw mode, key reading), and screen management into one place.
///
/// By default, [Terminal.instance] writes to [stdout] and reads
/// from [stdin]. Replace [instance] with a custom [Terminal] for
/// testing or custom output targets:
///
/// ```dart
/// Terminal.instance = Terminal(output: myCustomSink);
/// ```
/// Terminal cursor shape, controlled via ANSI escape sequences.
///
/// Each value carries its full escape sequence, including the
/// `ESC[?12h` blink-enable prefix for blinking variants.
/// Pass to [Terminal.setCursorShape].
enum CursorShape {
  /// Blinking block cursor (▋).
  blinkingBlock('\x1B[?12h\x1B[1 q'),

  /// Steady (non-blinking) block cursor (█).
  steadyBlock('\x1B[2 q'),

  /// Blinking underline cursor (_).
  blinkingUnderline('\x1B[?12h\x1B[3 q'),

  /// Steady underline cursor.
  steadyUnderline('\x1B[4 q'),

  /// Blinking bar cursor (|) — common IDE default.
  blinkingBar('\x1B[?12h\x1B[5 q'),

  /// Steady bar cursor.
  steadyBar('\x1B[6 q')
  ;

  const CursorShape(this.sequence);

  /// The full ANSI escape sequence for this cursor shape.
  final String sequence;
}

class Terminal {
  /// The global terminal instance used by all widgets.
  static final Terminal _instance = Terminal._();

  factory Terminal() {
    return _instance;
  }

  Terminal._() : _output = stdout, _input = stdin {
    // Restore the cursor on SIGTERM (fires when the event loop is running).
    ProcessSignal.sigterm.watch().listen((_) {
      cursorShow();
      resetCursorShape();
      exit(0);
    });

    // SIGINT (Ctrl+C) is tricky: when inside runRawModeSync the main isolate's
    // event loop is blocked in readByteSync(), so an async signal listener here
    // can never fire. Spawn a background isolate whose event loop runs freely —
    // Dart delivers signals to ALL isolates that are watching them, so the
    // background isolate will receive SIGINT even when the main is blocked.
    Isolate.spawn(_sigintWatcher, null);
  }

  /// Watches SIGINT in a background isolate so it fires even when the main
  /// isolate is blocked in a synchronous read loop.
  static void _sigintWatcher(dynamic _) {
    ProcessSignal.sigint.watch().listen((_) {
      stdout.write('\x1B[?25h'); // show cursor
      stdout.write('\x1B[?12l\x1B[0 q'); // reset cursor shape
      exit(0);
    });
  }

  /// The output sink. Defaults to [stdout].
  IOSink _output;

  /// The _input stream. Defaults to [stdin].
  Stdin _input;

  set output(IOSink sink) {
    _output = sink;
  }

  set input(Stdin stream) {
    _input = stream;
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Write [s] to the output sink.
  void write(String s) => _output.write(s);

  /// Write [s] followed by a newline to the output sink.
  void writeln([String s = '']) => _output.writeln(s);

  /// Render a list of [StyledText] spans and write to the output sink.
  void writeSpans(List<StyledText> spans) => write(renderSpans(spans));

  /// Render a list of [StyledText] spans and write with a trailing newline.
  void writeSpansLn(List<StyledText> spans) => writeln(renderSpans(spans));

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Read the next key event from _input synchronously.
  ///
  /// **Requires raw mode to be enabled.** Blocks until a keypress
  /// is available.
  KeyEvent readKeySync() {
    final byte = _input.readByteSync();

    if (byte == -1) return const SpecialKey(Key.escape);
    if (byte == 10 || byte == 13) return const SpecialKey(Key.enter);
    if (byte == 9) return const SpecialKey(Key.tab);
    if (byte == 127 || byte == 8) return const SpecialKey(Key.backspace);
    if (byte == 32) return const SpecialKey(Key.space);

    // Ctrl+C (ETX, byte 3): raw mode prevents the OS from converting this to
    // SIGINT, so the ProcessSignal handler never fires. Clean up and exit here.
    if (byte == 3) {
      disableRawMode();
      cursorShow();
      resetCursorShape();
      exit(0);
    }

    if (byte == 27) return _parseEscapeSequence();

    if (byte >= 32 && byte < 127) return CharKey(String.fromCharCode(byte));

    // Multi-byte UTF-8: reassemble the bytes and decode as UTF-8.
    if (byte >= 0xC0) {
      final bytes = [byte];
      final remaining = byte < 0xE0
          ? 1
          : byte < 0xF0
          ? 2
          : 3;
      for (var i = 0; i < remaining; i++) {
        final next = _input.readByteSync();
        if (next == -1) break;
        bytes.add(next);
      }
      try {
        return CharKey(utf8.decode(bytes));
      } catch (_) {
        return const SpecialKey(Key.escape);
      }
    }

    return const SpecialKey(Key.escape);
  }

  KeyEvent _parseEscapeSequence() {
    final next = _input.readByteSync();
    if (next == -1) return const SpecialKey(Key.escape);

    if (next == 91) {
      // CSI: ESC [
      final code = _input.readByteSync();
      return switch (code) {
        65 => const SpecialKey(Key.arrowUp),
        66 => const SpecialKey(Key.arrowDown),
        67 => const SpecialKey(Key.arrowRight),
        68 => const SpecialKey(Key.arrowLeft),
        72 => const SpecialKey(Key.home),
        70 => const SpecialKey(Key.end),
        90 => const SpecialKey(Key.shiftTab),
        51 => _consumeTilde(Key.delete),
        _ => const SpecialKey(Key.escape),
      };
    }

    if (next == 79) {
      // SS3: ESC O
      final code = _input.readByteSync();
      return switch (code) {
        72 => const SpecialKey(Key.home),
        70 => const SpecialKey(Key.end),
        _ => const SpecialKey(Key.escape),
      };
    }

    return const SpecialKey(Key.escape);
  }

  KeyEvent _consumeTilde(Key key) {
    final tilde = _input.readByteSync();
    if (tilde == 126) return SpecialKey(key);
    return const SpecialKey(Key.escape);
  }

  // ---------------------------------------------------------------------------
  // Cursor
  // ---------------------------------------------------------------------------

  /// Move cursor up by [n] lines.
  void cursorUp([int n = 1]) => write('\x1B[${n}A');

  /// Move cursor down by [n] lines.
  void cursorDown([int n = 1]) => write('\x1B[${n}B');

  /// Move cursor right by [n] columns.
  void cursorRight([int n = 1]) => write('\x1B[${n}C');

  /// Move cursor left by [n] columns.
  void cursorLeft([int n = 1]) => write('\x1B[${n}D');

  /// Move cursor to column [col] (1-indexed).
  void cursorToColumn(int col) => write('\x1B[${col}G');

  /// Move cursor to the start of the current line.
  void cursorToStart() => write('\r');

  /// Save the current cursor position (DEC private).
  void cursorSave() => write('\x1B7');

  /// Restore a previously saved cursor position (DEC private).
  void cursorRestore() => write('\x1B8');

  /// Hide the cursor.
  void cursorHide() => write('\x1B[?25l');

  /// Show the cursor.
  void cursorShow() => write('\x1B[?25h');

  /// Set the terminal cursor shape.
  ///
  /// Takes effect immediately. Pair with [resetCursorShape] to restore
  /// the terminal's default on exit.
  void setCursorShape(CursorShape shape) => write(shape.sequence);

  /// Reset the cursor shape to the terminal's default.
  void resetCursorShape() => write('\x1B[?12l\x1B[0 q');

  // ---------------------------------------------------------------------------
  // Cursor escape sequence strings (for composition / testing)
  // ---------------------------------------------------------------------------

  /// Returns the escape sequence string for moving up [n] lines.
  static String cursorUpSeq([int n = 1]) => '\x1B[${n}A';

  /// Returns the escape sequence string for moving down [n] lines.
  static String cursorDownSeq([int n = 1]) => '\x1B[${n}B';

  /// Returns the escape sequence string for moving right [n] columns.
  static String cursorRightSeq([int n = 1]) => '\x1B[${n}C';

  /// Returns the escape sequence string for moving left [n] columns.
  static String cursorLeftSeq([int n = 1]) => '\x1B[${n}D';

  /// Returns the escape sequence string for moving to column [col].
  static String cursorToColumnSeq(int col) => '\x1B[${col}G';

  /// Escape sequence for hiding the cursor.
  static String get cursorHideSeq => '\x1B[?25l';

  /// Escape sequence for showing the cursor.
  static String get cursorShowSeq => '\x1B[?25h';

  // ---------------------------------------------------------------------------
  // Erase
  // ---------------------------------------------------------------------------

  /// Clear from cursor to end of line.
  void eraseLineToEnd() => write('\x1B[0K');

  /// Clear from start of line to cursor.
  void eraseLineToStart() => write('\x1B[1K');

  /// Clear the entire current line.
  void eraseLine() => write('\x1B[2K');

  /// Clear from cursor to end of screen.
  void eraseScreenDown() => write('\x1B[0J');

  /// Clear the entire screen.
  void eraseScreen() => write('\x1B[2J');

  /// Clear [n] lines above the cursor.
  ///
  /// Moves the cursor up one line at a time, clearing each line,
  /// then moves to the start of the resulting line.
  void eraseLinesUp(int n) {
    for (var i = 0; i < n; i++) {
      cursorUp();
      eraseLine();
    }
    cursorToStart();
  }

  // ---------------------------------------------------------------------------
  // Erase escape sequence constants (for composition / testing)
  // ---------------------------------------------------------------------------

  /// Escape sequence for clearing from cursor to end of line.
  static const String eraseLineToEndSeq = '\x1B[0K';

  /// Escape sequence for clearing from start of line to cursor.
  static const String eraseLineToStartSeq = '\x1B[1K';

  /// Escape sequence for clearing the entire line.
  static const String eraseLineSeq = '\x1B[2K';

  /// Escape sequence for clearing from cursor to end of screen.
  static const String eraseScreenDownSeq = '\x1B[0J';

  /// Escape sequence for clearing the entire screen.
  static const String eraseScreenSeq = '\x1B[2J';

  // ---------------------------------------------------------------------------
  // Raw Mode
  // ---------------------------------------------------------------------------

  bool _previousLineMode = true;
  bool _previousEchoMode = true;

  /// Enable raw mode.
  ///
  /// Disables line buffering and echo so that individual keypresses
  /// can be read without waiting for Enter.
  ///
  /// Always pair with [disableRawMode] or use [runRawMode] for
  /// automatic cleanup.
  void enableRawMode() {
    _previousLineMode = _input.lineMode;
    _previousEchoMode = _input.echoMode;
    _input.lineMode = false;
    _input.echoMode = false;
  }

  /// Restore the terminal to its previous mode.
  void disableRawMode() {
    _input.lineMode = _previousLineMode;
    _input.echoMode = _previousEchoMode;
  }

  /// Run [fn] with raw mode enabled, restoring on exit.
  Future<T> runRawMode<T>(Future<T> Function() fn) async {
    enableRawMode();
    try {
      return await fn();
    } finally {
      disableRawMode();
    }
  }

  /// Synchronous version of [runRawMode].
  T runRawModeSync<T>(T Function() fn) {
    enableRawMode();
    try {
      return fn();
    } finally {
      disableRawMode();
    }
  }

  // ---------------------------------------------------------------------------
  // Screen Buffer
  // ---------------------------------------------------------------------------

  int _lastLineCount = 0;

  /// Erase previously rendered lines and write [content].
  void updateScreen(String content) {
    _eraseScreen();
    write(content);
    _lastLineCount = '\n'.allMatches(content).length;
  }

  /// Clear all tracked lines without writing new content.
  void clearScreen() {
    _eraseScreen();
    _lastLineCount = 0;
  }

  void _eraseScreen() {
    for (var i = 0; i < _lastLineCount; i++) {
      cursorUp();
      eraseLine();
    }
    if (_lastLineCount > 0) {
      cursorToStart();
    }
  }

  // ---------------------------------------------------------------------------
  // Terminal Info
  // ---------------------------------------------------------------------------

  /// The current terminal width in columns.
  ///
  /// Returns a default of 80 if the terminal width cannot be determined.
  int get columns {
    try {
      return stdout.terminalColumns;
    } on StdoutException {
      return 80;
    }
  }

  /// The current terminal height in rows.
  ///
  /// Returns a default of 24 if the terminal height cannot be determined.
  int get rows {
    try {
      return stdout.terminalLines;
    } on StdoutException {
      return 24;
    }
  }

  /// Whether stdout is connected to an interactive terminal.
  bool get isInteractive {
    try {
      return stdout.hasTerminal;
    } catch (_) {
      return false;
    }
  }
}
