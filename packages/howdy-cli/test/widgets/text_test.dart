import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/wrap.dart';
import 'package:test/test.dart';

void main() {
  group('Text', () {
    test('render includes label', () {
      final widget = Text('Hello world');
      final output = widget.render();
      expect(stripAnsi(output), contains('Hello world'));
    });

    test('render includes leading text', () {
      final widget = Text('msg', leading: '> ');
      final output = widget.render();
      expect(stripAnsi(output), contains('> '));
      expect(stripAnsi(output), contains('msg'));
    });

    test('newline true adds trailing newline', () {
      final widget = Text('hi', newline: true);
      final output = widget.render();
      expect(output, endsWith('\n'));
    });

    test('newline false does not add trailing newline', () {
      final widget = Text('hi', newline: false);
      final output = widget.render();
      expect(output, isNot(endsWith('\n')));
    });

    test('isDone is always true', () {
      expect(Text('x').isDone, isTrue);
    });

    test('style is applied', () {
      final widget = Text('bold', style: TextStyle(bold: true));
      final output = widget.render();
      // Should contain ANSI bold sequence
      expect(output, contains('\x1B['));
    });
  });
}
