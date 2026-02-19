import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('TableStyle', () {
    test('rounded hasBorders', () {
      expect(TableStyle.rounded.hasBorders, isTrue);
    });

    test('sharp hasBorders', () {
      expect(TableStyle.sharp.hasBorders, isTrue);
    });

    test('ascii hasBorders', () {
      expect(TableStyle.ascii.hasBorders, isTrue);
    });

    test('none has no borders', () {
      expect(TableStyle.none.hasBorders, isFalse);
    });
  });
}
