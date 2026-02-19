import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('CharKey', () {
    test('equality for same char', () {
      expect(CharKey('a'), equals(CharKey('a')));
    });

    test('inequality for different chars', () {
      expect(CharKey('a'), isNot(equals(CharKey('b'))));
    });

    test('hashCode is consistent', () {
      expect(CharKey('x').hashCode, CharKey('x').hashCode);
    });

    test('toString contains the char', () {
      expect(CharKey('z').toString(), 'CharKey(z)');
    });
  });

  group('SpecialKey', () {
    test('equality for same key', () {
      expect(SpecialKey(Key.enter), equals(SpecialKey(Key.enter)));
    });

    test('inequality for different keys', () {
      expect(
        SpecialKey(Key.enter),
        isNot(equals(SpecialKey(Key.backspace))),
      );
    });

    test('hashCode is consistent', () {
      expect(
        SpecialKey(Key.arrowUp).hashCode,
        SpecialKey(Key.arrowUp).hashCode,
      );
    });

    test('toString contains key name', () {
      expect(SpecialKey(Key.escape).toString(), 'SpecialKey(escape)');
    });
  });

  group('KeyEvent subtype checks', () {
    test('CharKey is a KeyEvent', () {
      expect(CharKey('a'), isA<KeyEvent>());
    });

    test('SpecialKey is a KeyEvent', () {
      expect(SpecialKey(Key.enter), isA<KeyEvent>());
    });

    test('CharKey is not a SpecialKey', () {
      expect(CharKey('a'), isNot(isA<SpecialKey>()));
    });
  });
}
