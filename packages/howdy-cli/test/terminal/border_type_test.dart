import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('BorderType', () {
    test('rounded has all four sides', () {
      expect(BorderType.rounded.hasBox, isTrue);
    });

    test('sharp has all four sides', () {
      expect(BorderType.sharp.hasBox, isTrue);
    });

    test('ascii has all four sides', () {
      expect(BorderType.ascii.hasBox, isTrue);
    });

    test('leftOnly does not have a full box', () {
      expect(BorderType.leftOnly.hasBox, isFalse);
    });

    test('copyWith toggles sides', () {
      final partial = BorderType.rounded.copyWith(top: false, right: false);
      expect(partial.top, isFalse);
      expect(partial.right, isFalse);
      expect(partial.bottom, isTrue);
      expect(partial.left, isTrue);
      expect(partial.hasBox, isFalse);
    });

    test('copyWith preserves characters', () {
      final partial = BorderType.rounded.copyWith(top: false);
      expect(partial.topLeft, '╭');
      expect(partial.horizontal, '─');
      expect(partial.vertical, '│');
    });
  });
}
