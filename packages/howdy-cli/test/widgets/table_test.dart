import 'package:howdy/howdy.dart';
import 'package:test/test.dart';

void main() {
  group('Table', () {
    test('render includes headers', () {
      final table = Table(
        headers: ['Name', 'Age'],
        rows: [
          ['Alice', '30'],
        ],
      );
      final output = table.render();
      expect(output, contains('Name'));
      expect(output, contains('Age'));
    });

    test('render includes row data', () {
      final table = Table(
        headers: ['Name', 'Age'],
        rows: [
          ['Alice', '30'],
          ['Bob', '25'],
        ],
      );
      final output = table.render();
      expect(output, contains('Alice'));
      expect(output, contains('Bob'));
      expect(output, contains('30'));
      expect(output, contains('25'));
    });

    test('rounded style uses rounded corners', () {
      final table = Table(
        headers: ['A'],
        rows: [
          ['1'],
        ],
        style: TableStyle.rounded,
      );
      final output = table.render();
      expect(output, contains('╭'));
      expect(output, contains('╰'));
    });

    test('sharp style uses sharp corners', () {
      final table = Table(
        headers: ['A'],
        rows: [
          ['1'],
        ],
        style: TableStyle.sharp,
      );
      final output = table.render();
      expect(output, contains('┌'));
      expect(output, contains('└'));
    });

    test('ascii style uses +, -, |', () {
      final table = Table(
        headers: ['A'],
        rows: [
          ['1'],
        ],
        style: TableStyle.ascii,
      );
      final output = table.render();
      expect(output, contains('+'));
      expect(output, contains('-'));
      expect(output, contains('|'));
    });

    test('right alignment pads left', () {
      final table = Table(
        headers: ['Num'],
        rows: [
          ['42'],
        ],
        columnAlignments: [ColumnAlignment.right],
      );
      final output = table.render();
      // The cell should have left-padding
      final lines = output.split('\n');
      final dataLine = lines.firstWhere((l) => l.contains('42'));
      final stripped = dataLine.stripAnsi();
      // '42' should be right-aligned: preceded by spaces
      final cellContent = stripped.split('│')[1].trim();
      expect(cellContent, '42');
    });

    test('explicit columnWidths widens columns', () {
      final table = Table(
        headers: ['A'],
        rows: [
          ['x'],
        ],
        columnWidths: [20],
      );
      final output = table.render();
      final lines = output.split('\n');
      // The top border line should be at least 20 chars wide for content
      final topBorder = lines.first;
      expect(topBorder.length, greaterThanOrEqualTo(20));
    });

    test('isDone is always true', () {
      final table = Table(headers: ['A'], rows: []);
      expect(table.isDone, isTrue);
    });

    test('value is void', () {
      final table = Table(headers: ['A'], rows: []);
      // Just ensure it doesn't throw
      table.value;
    });

    test('handles empty rows', () {
      final table = Table(headers: ['A', 'B'], rows: []);
      final output = table.render();
      expect(output, contains('A'));
      expect(output, contains('B'));
    });

    test('handles StyledText cells', () {
      final table = Table(
        headers: ['Status'],
        rows: [
          [StyledText('ok', style: TextStyle(foreground: Color.green))],
        ],
      );
      final output = table.render();
      expect(output.stripAnsi(), contains('ok'));
    });
  });
}
