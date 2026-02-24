import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('String.wrapAnsi', () {
    test('does not modify string if width is infinite or <= 0', () {
      expect('hello world'.wordWrap(0), 'hello world');
      expect('hello world'.wordWrap(-1), 'hello world');
    });

    test('does not wrap if text is shorter than width', () {
      expect('hello world'.wordWrap(20), 'hello world');
    });

    test('wraps on space within width', () {
      // "hello world" is 11 chars.
      // Wrapping at 5 should split "hello" and "world"
      expect('hello world'.wordWrap(5), 'hello\nworld');
    });

    test('wraps multiple times', () {
      expect('the quick brown fox'.wordWrap(5), 'the\nquick\nbrown\nfox');
    });

    test('preserves existing newlines and resets width', () {
      expect('hello\nworld'.wordWrap(5), 'hello\nworld');
      expect(
        'a very long\nstring that'.wordWrap(10),
        'a very\nlong\nstring\nthat',
      );
    });

    test('hard wraps words longer than max width', () {
      // "supercalifragilistic" is 20 chars
      expect('supercalifragilistic'.wordWrap(5), 'super\ncalif\nragil\nistic');
    });

    test('ignores ANSI escape sequences for length calculation', () {
      final text = 'hello ${'world'.style(TextStyle(foreground: Color.red))}';
      // 'world' is styled, but visible length is still 11.
      expect(
        text.wordWrap(5),
        'hello\n${'world'.style(TextStyle(foreground: Color.red))}',
      );
    });

    test('handles ANSI strings that hard wrap', () {
      final text = 'longword'.style(TextStyle(bold: true));
      // length is 8. wrap at 4.
      // We expect the first 4 chars, then newline, then next 4.
      // The bold code happens before the 'l'.
      final wrapped = text.wordWrap(4);
      // The exact output depends on string chunks. Our regex breaks it into ANSI and chars.
      // The bold start code `\x1B[1m` is inserted, then `long`, then `\n`, then `word`, then reset `\x1B[0m`.
      expect(wrapped, '\x1B[1mlong\nword\x1B[0m');
    });
  });
}
