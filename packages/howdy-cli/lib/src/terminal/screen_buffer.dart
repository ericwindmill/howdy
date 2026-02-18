import 'package:howdy/src/terminal/terminal.dart';

/// Tracks rendered output and handles flicker-free re-rendering.
///
/// [ScreenBuffer] remembers how many lines were last written to the
/// terminal. On [update], it erases those lines and writes the new
/// content, producing a clean in-place redraw.
///
/// Used internally by widget [print] methods and by Form/Group.
class ScreenBuffer {
  int _lastLineCount = 0;

  /// Erase previously rendered lines and write [content].
  void update(String content) {
    _erase();
    terminal.write(content);
    _lastLineCount = '\n'.allMatches(content).length;
  }

  /// Erase the lines from the last [update] call.
  void _erase() {
    for (var i = 0; i < _lastLineCount; i++) {
      terminal.cursorUp();
      terminal.eraseLine();
    }
    if (_lastLineCount > 0) {
      terminal.cursorToStart();
    }
  }

  /// Clear all tracked lines without writing new content.
  void clear() {
    _erase();
    _lastLineCount = 0;
  }
}
