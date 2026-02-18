/// Border character sets for table rendering.
///
/// Each style defines the characters used for corners, edges,
/// and intersections when drawing a table border.
///
/// ```dart
/// Table(
///   headers: ['Name', 'Age'],
///   rows: [['Alice', '30']],
///   style: TableStyle.rounded,
/// ).render();
/// ```
class TableStyle {
  /// Top-left corner character.
  final String topLeft;

  /// Top-right corner character.
  final String topRight;

  /// Bottom-left corner character.
  final String bottomLeft;

  /// Bottom-right corner character.
  final String bottomRight;

  /// Horizontal line character.
  final String horizontal;

  /// Vertical separator character.
  final String vertical;

  /// Left T-junction (row separator meets left edge).
  final String leftT;

  /// Right T-junction (row separator meets right edge).
  final String rightT;

  /// Top T-junction (header separator meets top edge).
  final String topT;

  /// Bottom T-junction (bottom edge meets column separator).
  final String bottomT;

  /// Cross-junction (row and column separators intersect).
  final String cross;

  const TableStyle({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
    required this.leftT,
    required this.rightT,
    required this.topT,
    required this.bottomT,
    required this.cross,
  });

  /// Rounded Unicode borders.
  ///
  /// ```
  /// ╭───────┬─────╮
  /// │ Name  │ Age │
  /// ├───────┼─────┤
  /// │ Alice │  30 │
  /// ╰───────┴─────╯
  /// ```
  static const rounded = TableStyle(
    topLeft: '╭',
    topRight: '╮',
    bottomLeft: '╰',
    bottomRight: '╯',
    horizontal: '─',
    vertical: '│',
    leftT: '├',
    rightT: '┤',
    topT: '┬',
    bottomT: '┴',
    cross: '┼',
  );

  /// Sharp Unicode borders.
  ///
  /// ```
  /// ┌───────┬─────┐
  /// │ Name  │ Age │
  /// ├───────┼─────┤
  /// │ Alice │  30 │
  /// └───────┴─────┘
  /// ```
  static const sharp = TableStyle(
    topLeft: '┌',
    topRight: '┐',
    bottomLeft: '└',
    bottomRight: '┘',
    horizontal: '─',
    vertical: '│',
    leftT: '├',
    rightT: '┤',
    topT: '┬',
    bottomT: '┴',
    cross: '┼',
  );

  /// ASCII-only borders.
  ///
  /// ```
  /// +-------+-----+
  /// | Name  | Age |
  /// +-------+-----+
  /// | Alice |  30 |
  /// +-------+-----+
  /// ```
  static const ascii = TableStyle(
    topLeft: '+',
    topRight: '+',
    bottomLeft: '+',
    bottomRight: '+',
    horizontal: '-',
    vertical: '|',
    leftT: '+',
    rightT: '+',
    topT: '+',
    bottomT: '+',
    cross: '+',
  );

  /// No visible borders — columns are separated by whitespace.
  ///
  /// ```
  ///  Name    Age
  ///  Alice    30
  /// ```
  static const none = TableStyle(
    topLeft: '',
    topRight: '',
    bottomLeft: '',
    bottomRight: '',
    horizontal: '',
    vertical: ' ',
    leftT: '',
    rightT: '',
    topT: '',
    bottomT: '',
    cross: '',
  );

  /// Whether this style draws visible border lines.
  bool get hasBorders => horizontal.isNotEmpty;
}

/// Column text alignment within a table cell.
enum ColumnAlignment {
  /// Align text to the left (default).
  left,

  /// Center text horizontally.
  center,

  /// Align text to the right.
  right,
}
