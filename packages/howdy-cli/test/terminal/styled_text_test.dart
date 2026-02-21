import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('StyledText', () {
    test('render applies style', () {
      final span = StyledText('hi', style: TextStyle(bold: true));
      expect(span.render(), '\x1B[1mhi\x1B[0m');
    });

    test('render with no style returns plain text', () {
      const span = StyledText('hello');
      expect(span.render(), 'hello');
    });

    test('length returns raw text length, ignoring style', () {
      const span = StyledText('hello', style: TextStyle(bold: true));
      expect(span.length, 5);
    });

    test('toString delegates to render', () {
      const span = StyledText('x');
      expect(span.toString(), span.render());
    });
  });

  group('renderSpans', () {
    test('concatenates styled spans', () {
      final result = StyledText.renderSpans([
        StyledText('a', style: TextStyle(bold: true)),
        StyledText('b'),
      ]);
      expect(result, contains('a'));
      expect(result, contains('b'));
    });

    test('empty list returns empty string', () {
      expect(StyledText.renderSpans([]), '');
    });
  });

  group('StyledString extension', () {
    test('.style applies arbitrary TextStyle', () {
      final result = 'hi'.style(TextStyle(italic: true));
      expect(result, contains('3')); // italic code
    });
  });
}
