import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('Prompt (single-line)', () {
    late Prompt widget;

    setUp(() {
      widget = Prompt(label: 'Name');
    });

    test('initial state', () {
      expect(widget.isDone, isFalse);
      expect(widget.hasInput, isFalse);
      expect(widget.value, ''); // no default, no input
    });

    test('value returns defaultValue when no input', () {
      final w = Prompt(label: 'Name', defaultValue: 'cat');
      expect(w.value, 'cat');
    });

    group('handleKey', () {
      test('character input appends to buffer', () {
        widget.handleKey(CharKey('h'));
        widget.handleKey(CharKey('i'));
        expect(widget.value, 'hi');
        expect(widget.hasInput, isTrue);
      });

      test('backspace removes last character', () {
        widget.handleKey(CharKey('a'));
        widget.handleKey(CharKey('b'));
        final result = widget.handleKey(SpecialKey(Key.backspace));
        expect(result, KeyResult.consumed);
        expect(widget.value, 'a');
      });

      test('backspace on empty is ignored', () {
        final result = widget.handleKey(SpecialKey(Key.backspace));
        expect(result, KeyResult.ignored);
      });

      test('enter submits', () {
        widget.handleKey(CharKey('x'));
        final result = widget.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.done);
        expect(widget.isDone, isTrue);
        expect(widget.value, 'x');
      });

      test('ctrlD does not submit single-line prompt', () {
        widget.handleKey(CharKey('x'));
        final result = widget.handleKey(SpecialKey(Key.ctrlD));
        expect(result, KeyResult.ignored);
        expect(widget.isDone, isFalse);
      });

      test('enter with failing validator blocks submit', () {
        final w = Prompt(
          label: 'Q',
          validator: (v) => v.isEmpty ? 'Required' : null,
        );
        final result = w.handleKey(SpecialKey(Key.enter));
        expect(result, KeyResult.consumed);
        expect(w.isDone, isFalse);
        expect(w.error, 'Required');
      });

      test('enter clears error on successful validation', () {
        final w = Prompt(
          label: 'Q',
          validator: (v) => v.isEmpty ? 'Required' : null,
        );
        // First fail
        w.handleKey(SpecialKey(Key.enter));
        expect(w.hasError, isTrue);
        // Then type and succeed
        w.handleKey(CharKey('a'));
        w.handleKey(SpecialKey(Key.enter));
        expect(w.isDone, isTrue);
        expect(w.hasError, isFalse);
      });

      test('character input clears error', () {
        final w = Prompt(
          label: 'Q',
          validator: (v) => v.isEmpty ? 'Required' : null,
        );
        w.handleKey(SpecialKey(Key.enter));
        expect(w.hasError, isTrue);
        w.handleKey(CharKey('a'));
        expect(w.hasError, isFalse);
      });

      test('unrelated special keys are ignored', () {
        expect(
          widget.handleKey(SpecialKey(Key.arrowUp)),
          KeyResult.ignored,
        );
      });
    });

    group('reset', () {
      test('clears input and done state', () {
        widget.handleKey(CharKey('a'));
        widget.handleKey(SpecialKey(Key.enter));
        widget.reset();
        expect(widget.isDone, isFalse);
        expect(widget.hasInput, isFalse);
        expect(widget.value, '');
      });
    });

    group('render', () {
      test('contains label', () {
        expect(widget.render(), contains('Name'));
      });

      test('contains pointer icon when not done', () {
        expect(widget.render(), contains(Icon.question));
      });

      test('contains default value as placeholder', () {
        final w = Prompt(label: 'Q', defaultValue: 'cat');
        expect(w.render(), contains('cat'));
      });
    });
  });
}
