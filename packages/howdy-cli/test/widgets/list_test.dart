import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('BulletList', () {
    test('renders title when provided', () {
      final widget = BulletList(items: ['a', 'b'], title: 'My Title');
      final output = widget.render().stripAnsi();
      expect(output, contains('My Title'));
    });

    test('renders items with dot marker', () {
      final widget = BulletList(items: ['Alpha', 'Beta', 'Gamma']);
      final output = widget.render().stripAnsi();
      expect(output, contains('· Alpha'));
      expect(output, contains('· Beta'));
      expect(output, contains('· Gamma'));
    });

    test('renders (empty) when items list is empty', () {
      final widget = BulletList(items: []);
      final output = widget.render().stripAnsi();
      expect(output, contains('(empty)'));
    });

    test('respects maxVisibleRows — only N items visible', () {
      final widget = BulletList(
        items: ['1', '2', '3', '4', '5'],
        maxVisibleRows: 3,
      );
      final output = widget.render().stripAnsi();
      expect(output, contains('· 1'));
      expect(output, contains('· 2'));
      expect(output, contains('· 3'));
      expect(output, isNot(contains('· 4')));
      expect(output, isNot(contains('· 5')));
    });

    test('shows ellipsis below when items overflow visible window', () {
      final widget = BulletList(
        items: ['1', '2', '3', '4', '5'],
        maxVisibleRows: 3,
      );
      final output = widget.render().stripAnsi();
      expect(output, contains('...'));
    });

    test('does not show ellipsis when all items fit', () {
      final widget = BulletList(
        items: ['a', 'b', 'c'],
        maxVisibleRows: 10,
      );
      final output = widget.render().stripAnsi();
      expect(output, isNot(contains('...')));
    });

    test('handleKey arrowDown scrolls offset down', () {
      final widget = BulletList(
        items: ['1', '2', '3', '4', '5'],
        maxVisibleRows: 3,
      );

      // Initial: shows 1, 2, 3
      expect(widget.render().stripAnsi(), contains('· 1'));

      widget.handleKey(const SpecialKey(Key.arrowDown));

      // After scroll: offset is 1, shows 2, 3, 4
      final output = widget.render().stripAnsi();
      expect(output, isNot(contains('· 1')));
      expect(output, contains('· 2'));
      expect(output, contains('· 4'));
    });

    test('handleKey arrowUp scrolls offset up', () {
      final widget = BulletList(
        items: ['1', '2', '3', '4', '5'],
        maxVisibleRows: 3,
      );

      widget.handleKey(const SpecialKey(Key.arrowDown));
      widget.handleKey(const SpecialKey(Key.arrowDown));
      widget.handleKey(const SpecialKey(Key.arrowUp));

      // offset should be 1 now
      final output = widget.render().stripAnsi();
      expect(output, contains('· 2'));
    });

    test('handleKey arrowUp does not scroll below 0', () {
      final widget = BulletList(
        items: ['a', 'b', 'c', 'd', 'e'],
        maxVisibleRows: 3,
      );

      // Press up when already at top — should be a no-op
      widget.handleKey(const SpecialKey(Key.arrowUp));
      final output = widget.render().stripAnsi();
      expect(output, contains('· a'));
    });

    test('shows ellipsis above when scrolled down', () {
      final widget = BulletList(
        items: ['1', '2', '3', '4', '5'],
        maxVisibleRows: 3,
      );

      widget.handleKey(const SpecialKey(Key.arrowDown));
      final output = widget.render().stripAnsi();
      expect(output, contains('...'));
    });
  });
}
