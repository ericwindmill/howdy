import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('Group', () {
    late Page group;
    late ConfirmInput confirm;
    late Select<String> select;

    setUp(() {
      confirm = ConfirmInput(label: 'Ok?', key: 'ok');
      select = Select<String>(
        label: 'Lang',
        key: 'lang',
        options: [
          Option(label: 'Dart', value: 'dart'),
          Option(label: 'Go', value: 'go'),
        ],
      );
      group = Page([confirm, select]);
    });

    test('initial state: first widget is focused', () {
      expect(group.focusIndex, 0);
      expect(group.isDone, isFalse);
    });

    test('delegates key to focused widget', () {
      // Confirm is focused; y should set it to Yes
      group.handleKey(CharKey('y'));
      expect(confirm.value, isTrue);
    });

    test('enter on focused widget advances focus', () {
      // Submit confirm → focus moves to select
      group.handleKey(CharKey('y'));
      final result = group.handleKey(SpecialKey(Key.enter));
      expect(result, KeyResult.consumed); // consumed, not done — more widgets
      expect(group.focusIndex, 1);
    });

    test('completing last widget sets group done', () {
      // Complete confirm
      group.handleKey(CharKey('y'));
      group.handleKey(SpecialKey(Key.enter));

      // Complete select
      final result = group.handleKey(SpecialKey(Key.enter));
      expect(result, KeyResult.done);
      expect(group.isDone, isTrue);
    });

    test('shift+tab moves focus back', () {
      // Advance to select
      group.handleKey(CharKey('y'));
      group.handleKey(SpecialKey(Key.enter));
      expect(group.focusIndex, 1);

      // Shift+tab goes back
      final result = group.handleKey(SpecialKey(Key.shiftTab));
      expect(result, KeyResult.consumed);
      expect(group.focusIndex, 0);
    });

    test('shift+tab at first widget is ignored', () {
      final result = group.handleKey(SpecialKey(Key.shiftTab));
      expect(result, KeyResult.ignored);
      expect(group.focusIndex, 0);
    });

    test('value aggregates child results', () {
      // Complete both
      group.handleKey(CharKey('y'));
      group.handleKey(SpecialKey(Key.enter));
      group.handleKey(SpecialKey(Key.enter));

      final results = group.value;
      expect(results['ok'], isTrue);
      expect(results['lang'], 'dart');
    });

    test('reset restores all children and focus', () {
      group.handleKey(CharKey('y'));
      group.handleKey(SpecialKey(Key.enter));
      group.handleKey(SpecialKey(Key.enter));
      expect(group.isDone, isTrue);

      group.reset();
      expect(group.isDone, isFalse);
      expect(group.focusIndex, 0);
      expect(confirm.isDone, isFalse);
      expect(select.isDone, isFalse);
    });

    test('render contains all widget labels', () {
      final output = group.render();
      expect(output, contains('Ok?'));
      expect(output, contains('Lang'));
    });
  });
}
