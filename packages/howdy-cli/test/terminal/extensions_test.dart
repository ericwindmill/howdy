import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('stripAnsi', () {
    test('returns plain text unchanged', () {
      expect(stripAnsi('hello world'), 'hello world');
    });

    test('strips bold sequence', () {
      expect(stripAnsi('\x1B[1mhello\x1B[0m'), 'hello');
    });

    test('strips multiple sequences', () {
      final styled = '\x1B[1mbold\x1B[0m and \x1B[3mitalic\x1B[0m';
      expect(stripAnsi(styled), 'bold and italic');
    });

    test('strips color sequences', () {
      final styled = TextStyle(foreground: Color.red).apply('red');
      expect(stripAnsi(styled), 'red');
    });

    test('handles empty string', () {
      expect(stripAnsi(''), '');
    });
  });

  group('visibleLength', () {
    test('plain string returns string length', () {
      expect('hello'.visibleLength, 5);
    });

    test('styled string returns text length only', () {
      final styled = TextStyle(bold: true).apply('abc');
      expect(styled.visibleLength, 3);
    });

    test('empty string returns 0', () {
      expect(''.visibleLength, 0);
    });
  });

  group('withBorder', () {
    test('rounded border wraps content', () {
      final result = 'hello'.withBorder(borderType: BorderType.rounded);
      expect(result, contains('╭'));
      expect(result, contains('╰'));
      expect(result, contains('│'));
      expect(result, contains('hello'));
    });

    test('sharp border uses sharp corners', () {
      final result = 'hello'.withBorder(borderType: BorderType.sharp);
      expect(result, contains('┌'));
      expect(result, contains('└'));
    });

    test('ascii border uses +, -, |', () {
      final result = 'hello'.withBorder(borderType: BorderType.ascii);
      expect(result, contains('+'));
      expect(result, contains('-'));
      expect(result, contains('|'));
    });

    test('leftOnly border has only left edge', () {
      final result = 'hello'.withBorder(borderType: BorderType.leftOnly);
      expect(result, contains('│'));
      // Should not contain top/bottom border lines with horizontal chars
      expect(result, isNot(contains('─')));
    });

    test('padding adds spaces inside border', () {
      final result = 'hi'.withBorder(
        borderType: BorderType.rounded,
        padding: EdgeInsets.all(1),
      );
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      // Should have: top border, top padding, content, bottom padding, bottom border
      expect(lines.length, 5);
    });

    test('multi-line content is bordered', () {
      final result = 'line1\nline2'.withBorder(borderType: BorderType.rounded);
      expect(result, contains('line1'));
      expect(result, contains('line2'));
      // Both lines should appear between the borders
      final lines = result.split('\n').where((l) => l.isNotEmpty).toList();
      // top border + 2 content lines + bottom border = 4
      expect(lines.length, 4);
    });

    test('partial border draws only specified sides', () {
      final style = BorderType.rounded.copyWith(top: false, bottom: false);
      final result = 'hi'.withBorder(borderType: style);
      // Should have left/right edges but no top/bottom border
      expect(result, contains('│'));
      expect(result, isNot(contains('╭')));
      expect(result, isNot(contains('╰')));
    });
  });
}
