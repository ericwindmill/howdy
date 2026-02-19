import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  final options = [
    Option(label: 'Dart', value: 'dart'),
    Option(label: 'Go', value: 'go'),
    Option(label: 'Rust', value: 'rust'),
  ];

  group('Select', () {
    late Select<String> widget;

    setUp(() {
      widget = Select<String>(label: 'Language', options: options);
    });

    test('initial state selects first option', () {
      expect(widget.value, 'dart');
      expect(widget.selectedIndex, 0);
      expect(widget.isDone, isFalse);
    });

    group('handleKey', () {
      test('arrowDown moves selection forward', () {
        final result = widget.handleKey(SpecialKey(Key.arrowDown));
        expect(result, KeyResult.consumed);
        expect(widget.selectedIndex, 1);
        expect(widget.value, 'go');
      });

      test('arrowUp moves selection backward', () {
        widget.handleKey(SpecialKey(Key.arrowDown));
        final result = widget.handleKey(SpecialKey(Key.arrowUp));
        expect(result, KeyResult.consumed);
        expect(widget.selectedIndex, 0);
      });

      test('arrowUp at top is ignored', () {
        final result = widget.handleKey(SpecialKey(Key.arrowUp));
        expect(result, KeyResult.ignored);
        expect(widget.selectedIndex, 0);
      });

      test('arrowDown at bottom is ignored', () {
        widget.handleKey(SpecialKey(Key.arrowDown));
        widget.handleKey(SpecialKey(Key.arrowDown));
        final result = widget.handleKey(SpecialKey(Key.arrowDown));
        expect(result, KeyResult.ignored);
        expect(widget.selectedIndex, 2);
      });

      test('enter submits and sets isDone', () {
        widget.handleKey(SpecialKey(Key.arrowDown)); // Go
        final result = widget.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.done);
        expect(widget.isDone, isTrue);
        expect(widget.value, 'go');
      });

      test('unrelated key is ignored', () {
        final result = widget.handleKey(CharKey('x'));
        expect(result, KeyResult.ignored);
      });

      test('enter with failing validator blocks submit', () {
        final w = Select<String>(
          label: 'Pick',
          options: options,
          validator: (v) => v == 'dart' ? 'Not Dart' : null,
        );
        final result = w.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.consumed);
        expect(w.isDone, isFalse);
        expect(w.error, 'Not Dart');
      });

      test('enter with passing validator completes', () {
        final w = Select<String>(
          label: 'Pick',
          options: options,
          validator: (v) => v == 'dart' ? null : 'Must be Dart',
        );
        final result = w.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.done);
        expect(w.isDone, isTrue);
      });
    });

    group('reset', () {
      test('restores to initial state', () {
        widget.handleKey(SpecialKey(Key.arrowDown));
        widget.handleKey(SpecialKey(Key.enter));
        widget.reset();
        expect(widget.selectedIndex, 0);
        expect(widget.isDone, isFalse);
        expect(widget.value, 'dart');
      });
    });

    group('render', () {
      test('contains label', () {
        expect(widget.render(), contains('Language'));
      });

      test('contains option labels', () {
        final output = widget.render();
        expect(output, contains('Dart'));
        expect(output, contains('Go'));
        expect(output, contains('Rust'));
      });
    });
  });
}
