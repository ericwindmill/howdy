import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('EdgeInsets', () {
    test('.all sets all sides equally', () {
      const e = EdgeInsets.all(5);
      expect(e.left, 5);
      expect(e.top, 5);
      expect(e.right, 5);
      expect(e.bottom, 5);
    });

    test('.only sets specified sides', () {
      const e = EdgeInsets.only(left: 1, bottom: 3);
      expect(e.left, 1);
      expect(e.top, 0);
      expect(e.right, 0);
      expect(e.bottom, 3);
    });

    test('.symmetric sets horizontal and vertical pairs', () {
      const e = EdgeInsets.symmetric(horizontal: 2, vertical: 4);
      expect(e.left, 2);
      expect(e.right, 2);
      expect(e.top, 4);
      expect(e.bottom, 4);
    });

    test('.zero has all sides at 0', () {
      expect(EdgeInsets.zero.left, 0);
      expect(EdgeInsets.zero.top, 0);
      expect(EdgeInsets.zero.right, 0);
      expect(EdgeInsets.zero.bottom, 0);
    });

    test('horizontal returns left + right', () {
      const e = EdgeInsets.only(left: 3, right: 7);
      expect(e.horizontal, 10);
    });

    test('vertical returns top + bottom', () {
      const e = EdgeInsets.only(top: 2, bottom: 5);
      expect(e.vertical, 7);
    });
  });
}
