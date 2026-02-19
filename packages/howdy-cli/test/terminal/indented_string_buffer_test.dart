import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('IndentedStringBuffer', () {
    test('writeln without indent has no prefix', () {
      final buf = IndentedStringBuffer();
      buf.writeln('hello');
      expect(buf.toString(), 'hello\n');
    });

    test('indent adds prefix to subsequent lines', () {
      final buf = IndentedStringBuffer();
      buf.indent();
      buf.writeln('indented');
      expect(buf.toString(), '  indented\n');
    });

    test('dedent removes one level of indent', () {
      final buf = IndentedStringBuffer();
      buf.indent(2);
      buf.dedent();
      buf.writeln('one level');
      expect(buf.toString(), '  one level\n');
    });

    test('dedent below zero clamps to 0', () {
      final buf = IndentedStringBuffer();
      buf.dedent(5);
      buf.writeln('no indent');
      expect(buf.toString(), 'no indent\n');
    });

    test('nested indent/dedent produces correct output', () {
      final buf = IndentedStringBuffer();
      buf.writeln('root');
      buf.indent();
      buf.writeln('child');
      buf.indent();
      buf.writeln('grandchild');
      buf.dedent(2);
      buf.writeln('root again');
      expect(
        buf.toString(),
        'root\n'
        '  child\n'
        '    grandchild\n'
        'root again\n',
      );
    });

    test('write without newline does not add line break', () {
      final buf = IndentedStringBuffer();
      buf.write('a');
      buf.write('b');
      expect(buf.toString(), 'ab');
    });

    test('write with embedded newlines indents subsequent lines', () {
      final buf = IndentedStringBuffer();
      buf.indent();
      buf.write('line1\nline2');
      expect(buf.toString(), '  line1\n  line2');
    });

    test('custom indentUnit is used', () {
      final buf = IndentedStringBuffer(indentUnit: '\t');
      buf.indent();
      buf.writeln('tab');
      expect(buf.toString(), '\ttab\n');
    });

    test('writeln with empty string writes just newline', () {
      final buf = IndentedStringBuffer();
      buf.indent();
      buf.writeln();
      // Empty writeln should not prepend indent
      expect(buf.toString(), '\n');
    });
  });
}
