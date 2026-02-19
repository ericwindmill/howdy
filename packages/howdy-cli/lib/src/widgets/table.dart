import 'dart:math';

import 'package:howdy/howdy.dart';

/// A formatted table for terminal output.
///
/// Renders tabular data with configurable borders, column alignment,
/// and per-cell styling.
///
/// **Column widths** can be controlled two ways:
///
/// 1. **Per-column**: `columnWidths: [12, 20]` — explicit character widths
///    (content is still padded to at least the measured minimum so nothing
///    is clipped).
/// 2. **Total width**: `totalWidth: 60` — the table fills exactly [totalWidth]
///    columns, distributing any surplus evenly across all columns.
///
/// Both parameters are optional; omitting both auto-sizes from content.
///
/// ```dart
/// // Auto-sized (default)
/// Table(headers: ['Name', 'Status'], rows: [...]).render();
///
/// // Per-column widths
/// Table(headers: ['Name', 'Status'], rows: [...],
///       columnWidths: [20, 10]).render();
///
/// // Fixed total width (columns share evenly)
/// Table(headers: ['Name', 'Status'], rows: [...],
///       totalWidth: 50).render();
/// ```
class Table extends DisplayWidget {
  Table({
    required this.headers,
    required this.rows,
    this.style = TableStyle.rounded,
    this.headerStyle = const TextStyle(bold: true),
    this.columnAlignments,
    this.columnWidths,
    this.totalWidth,
  });

  /// Convenience method for quick table output.
  static void send({
    required List<String> headers,
    required List<List<Object>> rows,
    TableStyle style = TableStyle.rounded,
    TextStyle headerStyle = const TextStyle(bold: true),
    List<ColumnAlignment>? columnAlignments,
    List<int>? columnWidths,
    int? totalWidth,
  }) {
    Table(
      headers: headers,
      rows: rows,
      style: style,
      headerStyle: headerStyle,
      columnAlignments: columnAlignments,
      columnWidths: columnWidths,
      totalWidth: totalWidth,
    ).write();
  }

  /// Per-column alignment. If `null` or shorter than the number
  /// of columns, missing columns default to [ColumnAlignment.left].
  final List<ColumnAlignment>? columnAlignments;

  /// Explicit per-column character widths (content padding only — no border).
  ///
  /// Each entry overrides the auto-measured minimum for that column.
  /// Omit or set to `null` to auto-size. Shorter lists leave trailing
  /// columns auto-sized.
  final List<int>? columnWidths;

  /// Column header labels.
  final List<String> headers;

  /// Style applied to header cells. Defaults to bold.
  final TextStyle headerStyle;

  /// Table data rows. Each cell can be a [String] or [StyledText].
  final List<List<Object>> rows;

  /// Border style to use. Defaults to [TableStyle.rounded].
  final TableStyle style;

  /// Target total character width of the entire table (borders included).
  ///
  /// When set, extra space beyond the content minimum is distributed evenly
  /// across all columns. Ignored if [columnWidths] already satisfies the
  /// total.
  final int? totalWidth;

  @override
  bool get isDone => true;

  @override
  void get value {}

  /// Get the alignment for column [index].
  ColumnAlignment _alignmentFor(int index) {
    if (columnAlignments == null || index >= columnAlignments!.length) {
      return ColumnAlignment.left;
    }
    return columnAlignments![index];
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

  /// Center a string within [width].
  static String _centerPad(String text, int width) {
    final totalPad = width - text.length;
    if (totalPad <= 0) return text;
    final left = totalPad ~/ 2;
    final right = totalPad - left;
    return '${' ' * left}$text${' ' * right}';
  }

  /// Compute final column widths, respecting [columnWidths] and [totalWidth].
  List<int> _computeWidths(int colCount, List<List<StyledText>> resolved) {
    // Step 1: content-measured minimums.
    final minimums = _measureWidths(colCount, resolved);

    // Step 2: apply explicit per-column overrides (must be >= minimum).
    final widths = List<int>.generate(colCount, (i) {
      final explicit = (columnWidths != null && i < columnWidths!.length)
          ? columnWidths![i]
          : null;
      return explicit != null ? max(explicit, minimums[i]) : minimums[i];
    });

    // Step 3: if totalWidth is set, distribute surplus evenly.
    if (totalWidth != null) {
      // Current rendered width: borders + padding (2 per cell) + widths.
      // Border chars: 1 left + (colCount-1) middles + 1 right = colCount+1.
      final borderChars = style.hasBorders ? colCount + 1 : 0;
      final paddingChars = colCount * 2; // 1 space each side per cell
      final contentTotal = widths.fold(0, (a, b) => a + b);
      final currentTotal = borderChars + paddingChars + contentTotal;
      final surplus = totalWidth! - currentTotal;
      if (surplus > 0) {
        // Distribute surplus, one extra char per column round-robin.
        final perCol = surplus ~/ colCount;
        final remainder = surplus % colCount;
        for (var i = 0; i < colCount; i++) {
          widths[i] += perCol + (i < remainder ? 1 : 0);
        }
      }
    }

    return widths;
  }

  /// Compute the display width of each column from content only.
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

  @override
  String build(IndentedStringBuffer _) {
    final colCount = headers.length;
    final resolvedRows = _resolveRows(colCount);
    final widths = _computeWidths(colCount, resolvedRows);
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
  void write() {
    terminal.write(render());
  }
}
