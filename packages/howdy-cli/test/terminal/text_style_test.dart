import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('Color', () {
    test('fgCode returns 38;2;r;g;b', () {
      expect(Color.red.fgCode, '38;2;204;0;0');
      expect(Color.white.fgCode, '38;2;255;255;255');
      expect(Color.black.fgCode, '38;2;0;0;0');
    });

    test('bgCode returns 48;2;r;g;b', () {
      expect(Color.green.bgCode, '48;2;56;142;60');
      expect(Color.blue.bgCode, '48;2;30;136;229');
    });
  });

  group('TextStyle', () {
    test('apply with no style returns text unchanged', () {
      const style = TextStyle();
      expect(style.apply('hello'), 'hello');
    });

    test('apply bold wraps with correct codes', () {
      const style = TextStyle(bold: true);
      expect(style.apply('hi'), '\x1B[1mhi\x1B[0m');
    });

    test('apply dim wraps with code 2', () {
      const style = TextStyle(dim: true);
      expect(style.apply('hi'), '\x1B[2mhi\x1B[0m');
    });

    test('apply foreground color uses fgCode', () {
      const style = TextStyle(foreground: Color.red);
      expect(style.apply('x'), '\x1B[${Color.red.fgCode}mx\x1B[0m');
    });

    test('apply background color uses bgCode', () {
      const style = TextStyle(background: Color.blue);
      expect(style.apply('x'), '\x1B[${Color.blue.bgCode}mx\x1B[0m');
    });

    test('apply combined styles joins codes with semicolons', () {
      const style = TextStyle(bold: true, italic: true);
      final result = style.apply('hi');
      expect(result, contains('1;3'));
      expect(result, startsWith('\x1B['));
      expect(result, endsWith('\x1B[0m'));
    });

    test('hasStyle is false for default', () {
      expect(const TextStyle().hasStyle, isFalse);
    });

    test('hasStyle is true when any property set', () {
      expect(const TextStyle(bold: true).hasStyle, isTrue);
      expect(const TextStyle(foreground: Color.red).hasStyle, isTrue);
      expect(const TextStyle(background: Color.blue).hasStyle, isTrue);
      expect(const TextStyle(underline: true).hasStyle, isTrue);
    });

    test('copyWith overrides specified properties', () {
      const original = TextStyle(bold: true, foreground: Color.red);
      final copied = original.copyWith(foreground: Color.blue);
      expect(copied.bold, isTrue);
      expect(copied.foreground, Color.blue);
    });

    test('copyWith preserves unspecified properties', () {
      const original = TextStyle(bold: true, dim: true);
      final copied = original.copyWith(bold: false);
      expect(copied.bold, isFalse);
      expect(copied.dim, isTrue);
    });

    test('+ merges styles with other taking precedence for colors', () {
      const a = TextStyle(bold: true, foreground: Color.red);
      const b = TextStyle(italic: true, foreground: Color.blue);
      final merged = a + b;
      expect(merged.bold, isTrue);
      expect(merged.italic, isTrue);
      expect(merged.foreground, Color.blue);
    });

    test('+ preserves first foreground when second is null', () {
      const a = TextStyle(foreground: Color.red);
      const b = TextStyle(bold: true);
      final merged = a + b;
      expect(merged.foreground, Color.red);
      expect(merged.bold, isTrue);
    });

    test('equality for identical styles', () {
      const a = TextStyle(bold: true, foreground: Color.red);
      const b = TextStyle(bold: true, foreground: Color.red);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different styles', () {
      const a = TextStyle(bold: true);
      const b = TextStyle(italic: true);
      expect(a, isNot(equals(b)));
    });

    test('toString lists properties', () {
      const style = TextStyle(bold: true, foreground: Color.red);
      final str = style.toString();
      expect(str, contains('bold'));
      expect(str, contains('fg:red'));
    });
  });
}
