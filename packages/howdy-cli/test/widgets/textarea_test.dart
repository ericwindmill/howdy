import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('Textarea', () {
    late Textarea widget;

    setUp(() {
      widget = Textarea(label: 'Description');
    });

    test('enter inserts newline instead of submitting', () {
      widget.handleKey(CharKey('a'));
      final result = widget.handleKey(SpecialKey(Key.enter));
      expect(result, KeyResult.consumed);
      expect(widget.isDone, isFalse);
      expect(widget.value, contains('\n'));
    });

    test('tab submits textarea', () {
      widget.handleKey(CharKey('x'));
      final result = widget.handleKey(SpecialKey(Key.tab));
      expect(result, KeyResult.done);
      expect(widget.isDone, isTrue);
      expect(widget.value, 'x');
    });

    test('multi-line input works', () {
      widget.handleKey(CharKey('a'));
      widget.handleKey(SpecialKey(Key.enter));
      widget.handleKey(CharKey('b'));
      widget.handleKey(SpecialKey(Key.tab));
      expect(widget.value, 'a\nb');
    });

    test('render contains pipe character', () {
      final output = widget.render();
      expect(output, contains(Icon.pipe));
    });
  });
}
