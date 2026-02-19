import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('MultiWidgetResults', () {
    test('set and get values by key', () {
      final results = MultiWidgetResults();
      results['name'] = 'Alice';
      results['age'] = 30;
      expect(results['name'], 'Alice');
      expect(results['age'], 30);
    });

    test('returns null for unknown key', () {
      final results = MultiWidgetResults();
      expect(results['missing'], isNull);
    });

    test('keys returns all set keys', () {
      final results = MultiWidgetResults();
      results['a'] = 1;
      results['b'] = 2;
      expect(results.keys, containsAll(['a', 'b']));
    });

    test('overwriting a key updates the value', () {
      final results = MultiWidgetResults();
      results['x'] = 'old';
      results['x'] = 'new';
      expect(results['x'], 'new');
    });

    test('supports null values', () {
      final results = MultiWidgetResults();
      results['nullable'] = null;
      expect(results.keys, contains('nullable'));
      expect(results['nullable'], isNull);
    });
  });
}
