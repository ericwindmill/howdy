import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  final options = [
    Option(label: 'Lint', value: 'lint'),
    Option(label: 'Test', value: 'test'),
    Option(label: 'CI', value: 'ci'),
  ];

  group('Multiselect', () {
    late Multiselect<String> widget;

    setUp(() {
      widget = Multiselect<String>(label: 'Features', options: options);
    });

    test('initial state has nothing selected', () {
      expect(widget.value, isEmpty);
      expect(widget.isDone, isFalse);
      expect(widget.selectedLabels, '(none)');
    });

    group('handleKey', () {
      test('arrowDown moves cursor forward', () {
        final result = widget.handleKey(SpecialKey(Key.arrowDown));
        expect(result, KeyResult.consumed);
        expect(widget.selectedIndex, 1);
      });

      test('arrowUp moves cursor backward', () {
        widget.handleKey(SpecialKey(Key.arrowDown));
        final result = widget.handleKey(SpecialKey(Key.arrowUp));
        expect(result, KeyResult.consumed);
        expect(widget.selectedIndex, 0);
      });

      test('arrowUp at top is ignored', () {
        final result = widget.handleKey(SpecialKey(Key.arrowUp));
        expect(result, KeyResult.ignored);
      });

      test('arrowDown at bottom is ignored', () {
        widget.handleKey(SpecialKey(Key.arrowDown));
        widget.handleKey(SpecialKey(Key.arrowDown));
        final result = widget.handleKey(SpecialKey(Key.arrowDown));
        expect(result, KeyResult.ignored);
      });

      test('space toggles selection on', () {
        final result = widget.handleKey(SpecialKey(Key.space));
        expect(result, KeyResult.consumed);
        expect(widget.value, ['lint']);
      });

      test('space toggles selection off', () {
        widget.handleKey(SpecialKey(Key.space)); // on
        widget.handleKey(SpecialKey(Key.space)); // off
        expect(widget.value, isEmpty);
      });

      test('multiple selections work', () {
        widget.handleKey(SpecialKey(Key.space)); // toggle Lint
        widget.handleKey(SpecialKey(Key.arrowDown));
        widget.handleKey(SpecialKey(Key.arrowDown));
        widget.handleKey(SpecialKey(Key.space)); // toggle CI
        expect(widget.value, ['lint', 'ci']);
        expect(widget.selectedLabels, 'Lint, CI');
      });

      test('enter submits', () {
        widget.handleKey(SpecialKey(Key.space));
        final result = widget.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.done);
        expect(widget.isDone, isTrue);
        expect(widget.value, ['lint']);
      });

      test('unrelated key is ignored', () {
        final result = widget.handleKey(CharKey('z'));
        expect(result, KeyResult.ignored);
      });

      test('enter with failing validator blocks submit', () {
        final w = Multiselect<String>(
          label: 'Pick',
          options: options,
          validator: (v) => v.isEmpty ? 'Select at least one' : null,
        );
        final result = w.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.consumed);
        expect(w.isDone, isFalse);
        expect(w.error, 'Select at least one');
      });
    });

    group('reset', () {
      test('clears all selections', () {
        widget.handleKey(SpecialKey(Key.space));
        widget.handleKey(SpecialKey(Key.arrowDown));
        widget.handleKey(SpecialKey(Key.space));
        widget.handleKey(SpecialKey(Key.enter));
        widget.reset();
        expect(widget.value, isEmpty);
        expect(widget.isDone, isFalse);
        expect(widget.selectedIndex, 0);
      });
    });

    group('render', () {
      test('contains label', () {
        expect(widget.render(), contains('Features'));
      });

      test('contains option labels', () {
        final output = widget.render();
        expect(output, contains('Lint'));
        expect(output, contains('Test'));
        expect(output, contains('CI'));
      });
    });
  });
}
