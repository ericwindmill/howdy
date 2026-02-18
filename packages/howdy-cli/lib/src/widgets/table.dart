import 'package:howdy/howdy.dart';

/// A formatted table for terminal output.
///
/// Renders tabular data with configurable borders, column alignment,
/// and per-cell styling.
///
/// Cells can be plain [String]s or [StyledText] for colored output:
///
/// ```dart
/// Table(
///   headers: ['Name', 'Status'],
///   rows: [
///     ['auth-service', StyledText('running', style: TextStyle(foreground: AnsiColor.green))],
///     ['db-worker', StyledText('stopped', style: TextStyle(foreground: AnsiColor.red))],
///   ],
///   style: TableStyle.rounded,
/// ).render();
/// ```
///
/// Output:
/// ```
/// ╭──────────────┬─────────╮
/// │ Name         │ Status  │
/// ├──────────────┼─────────┤
/// │ auth-service │ running │
/// │ db-worker    │ stopped │
/// ╰──────────────┴─────────╯
/// ```
class Table extends DisplayWidget {
  Table({
    required this.headers,
    required this.rows,
    this.style = TableStyle.rounded,
    this.headerStyle = const TextStyle(bold: true),
    this.columnAlignments,
  });

  /// Column header labels.
  final List<String> headers;

  /// Table data rows. Each cell can be a [String] or [StyledText].
  final List<List<Object>> rows;

  /// Border style to use. Defaults to [TableStyle.rounded].
  final TableStyle style;

  /// Style applied to header cells. Defaults to bold.
  final TextStyle headerStyle;

  /// Per-column alignment. If `null` or shorter than the number
  /// of columns, missing columns default to [ColumnAlignment.left].
  final List<ColumnAlignment>? columnAlignments;

  /// Convenience method for quick table output.
  static void send({
    required List<String> headers,
    required List<List<Object>> rows,
    TableStyle style = TableStyle.rounded,
    TextStyle headerStyle = const TextStyle(bold: true),
    List<ColumnAlignment>? columnAlignments,
  }) {
    Table(
      headers: headers,
      rows: rows,
      style: style,
      headerStyle: headerStyle,
      columnAlignments: columnAlignments,
    ).write();
  }

  @override
  String build(StringBuffer buf) {
    final colCount = headers.length;
    final resolvedRows = _resolveRows(colCount);
    final widths = _measureWidths(colCount, resolvedRows);
    final buf = StringBuffer();

    if (style.hasBorders) {
      buf.writeln(
        _buildLine(style.topLeft, style.topT, style.topRight, widths),
      );
    }

    buf.writeln(
      _buildRow([
        for (final h in headers) StyledText(h, style: headerStyle),
      ], widths),
    );

    if (style.hasBorders) {
      buf.writeln(_buildLine(style.leftT, style.cross, style.rightT, widths));
    }

    for (final row in resolvedRows) {
      buf.writeln(_buildRow(row, widths));
    }

    if (style.hasBorders) {
      buf.writeln(
        _buildLine(style.bottomLeft, style.bottomT, style.bottomRight, widths),
      );
    }

    return buf.toString();
  }

  @override
  void get value {}

  bool get isDone => true;

  @override
  void write() {
    terminal.write(render());
  }

  /// Normalize all cells to [StyledText] and pad rows to [colCount].
  List<List<StyledText>> _resolveRows(int colCount) {
    return rows.map((row) {
      return List.generate(colCount, (i) {
        if (i >= row.length) return const StyledText('');
        final cell = row[i];
        if (cell is StyledText) return cell;
        return StyledText(cell.toString());
      });
    }).toList();
  }

  /// Compute the display width of each column.
  List<int> _measureWidths(int colCount, List<List<StyledText>> resolved) {
    final widths = List.generate(colCount, (i) => headers[i].length);
    for (final row in resolved) {
      for (var i = 0; i < colCount; i++) {
        if (row[i].length > widths[i]) {
          widths[i] = row[i].length;
        }
      }
    }
    return widths;
  }

  /// Build a horizontal border line string.
  String _buildLine(String left, String mid, String right, List<int> widths) {
    final segments = widths.map((w) => style.horizontal * (w + 2));
    return '$left${segments.join(mid)}$right';
  }

  /// Build a data row string with cell padding and alignment.
  String _buildRow(List<StyledText> cells, List<int> widths) {
    final parts = <String>[];
    for (var i = 0; i < cells.length; i++) {
      final align = _alignmentFor(i);
      parts.add(' ${_padCell(cells[i], widths[i], align)} ');
    }
    return '${style.vertical}${parts.join(style.vertical)}${style.vertical}';
  }

  /// Get the alignment for column [index].
  ColumnAlignment _alignmentFor(int index) {
    if (columnAlignments == null || index >= columnAlignments!.length) {
      return ColumnAlignment.left;
    }
    return columnAlignments![index];
  }

  /// Pad a cell's text to [width] preserving ANSI styling.
  String _padCell(StyledText cell, int width, ColumnAlignment alignment) {
    final raw = cell.text;
    final padded = switch (alignment) {
      ColumnAlignment.left => raw.padRight(width),
      ColumnAlignment.right => raw.padLeft(width),
      ColumnAlignment.center => _centerPad(raw, width),
    };
    return cell.style.apply(padded);
  }

  /// Center a string within [width].
  static String _centerPad(String text, int width) {
    final totalPad = width - text.length;
    if (totalPad <= 0) return text;
    final left = totalPad ~/ 2;
    final right = totalPad - left;
    return '${' ' * left}$text${' ' * right}';
  }
}
