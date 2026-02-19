import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('ConfirmInput', () {
    late ConfirmInput widget;

    setUp(() {
      widget = ConfirmInput(label: 'Delete?');
    });

    test('initial value defaults to false', () {
      expect(widget.value, isFalse);
      expect(widget.isDone, isFalse);
    });

    test('initial value respects defaultValue: true', () {
      final w = ConfirmInput(label: 'Ok?', defaultValue: true);
      expect(w.value, isTrue);
    });

    group('handleKey', () {
      test('arrowLeft sets value to true (Yes)', () {
        final result = widget.handleKey(SpecialKey(Key.arrowLeft));
        expect(result, KeyResult.consumed);
        expect(widget.value, isTrue);
      });

      test('arrowRight sets value to false (No)', () {
        widget.handleKey(SpecialKey(Key.arrowLeft)); // first set to Yes
        final result = widget.handleKey(SpecialKey(Key.arrowRight));
        expect(result, KeyResult.consumed);
        expect(widget.value, isFalse);
      });

      test('y sets value to true', () {
        final result = widget.handleKey(CharKey('y'));
        expect(result, KeyResult.consumed);
        expect(widget.value, isTrue);
      });

      test('Y sets value to true', () {
        final result = widget.handleKey(CharKey('Y'));
        expect(result, KeyResult.consumed);
        expect(widget.value, isTrue);
      });

      test('n sets value to false', () {
        widget.handleKey(CharKey('y'));
        final result = widget.handleKey(CharKey('n'));
        expect(result, KeyResult.consumed);
        expect(widget.value, isFalse);
      });

      test('N sets value to false', () {
        widget.handleKey(CharKey('y'));
        final result = widget.handleKey(CharKey('N'));
        expect(result, KeyResult.consumed);
        expect(widget.value, isFalse);
      });

      test('enter submits and sets isDone', () {
        widget.handleKey(CharKey('y'));
        final result = widget.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.done);
        expect(widget.isDone, isTrue);
        expect(widget.value, isTrue);
      });

      test('unrelated key is ignored', () {
        final result = widget.handleKey(CharKey('x'));
        expect(result, KeyResult.ignored);
      });

      test('enter with failing validator sets error and returns consumed', () {
        final w = ConfirmInput(
          label: 'Ok?',
          validator: (v) => v ? 'Cannot be yes' : null,
        );
        w.handleKey(CharKey('y'));
        final result = w.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.consumed);
        expect(w.isDone, isFalse);
        expect(w.hasError, isTrue);
        expect(w.error, 'Cannot be yes');
      });

      test('enter with passing validator completes', () {
        final w = ConfirmInput(
          label: 'Ok?',
          validator: (v) => v ? null : 'Must be yes',
        );
        w.handleKey(CharKey('y'));
        final result = w.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.done);
        expect(w.isDone, isTrue);
        expect(w.hasError, isFalse);
      });
    });

    group('reset', () {
      test('restores default state', () {
        widget.handleKey(CharKey('y'));
        widget.handleKey(SpecialKey(Key.enter));
        expect(widget.isDone, isTrue);
        expect(widget.value, isTrue);

        widget.reset();
        expect(widget.isDone, isFalse);
        expect(widget.value, isFalse); // default was false
      });

      test('restores to custom default', () {
        final w = ConfirmInput(label: 'X', defaultValue: true);
        w.handleKey(CharKey('n'));
        w.reset();
        expect(w.value, isTrue);
      });
    });

    group('render', () {
      test('contains label', () {
        final output = widget.render();
        expect(output, contains('Delete?'));
      });

      test('contains Yes and No when not done', () {
        final output = widget.render();
        expect(output, contains('Yes'));
        expect(output, contains('No'));
      });
    });
  });
}
