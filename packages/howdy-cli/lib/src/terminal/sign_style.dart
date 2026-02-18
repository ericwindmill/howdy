/// Border character sets for [Sign] rendering.
///
/// Defines the 6 characters needed to draw a box border.
///
/// ```dart
/// Sign(
///   content: [StyledText('Hello')],
///   style: SignStyle.rounded,
/// ).write();
/// ```
class SignStyle {
  const SignStyle({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
  });

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

  /// Vertical line character.
  final String vertical;

  /// Rounded Unicode box.
  ///
  /// ```
  /// ╭─────────╮
  /// │ content │
  /// ╰─────────╯
  /// ```
  static const rounded = SignStyle(
    topLeft: '╭',
    topRight: '╮',
    bottomLeft: '╰',
    bottomRight: '╯',
    horizontal: '─',
    vertical: '│',
  );

  /// Sharp Unicode box.
  ///
  /// ```
  /// ┌─────────┐
  /// │ content │
  /// └─────────┘
  /// ```
  static const sharp = SignStyle(
    topLeft: '┌',
    topRight: '┐',
    bottomLeft: '└',
    bottomRight: '┘',
    horizontal: '─',
    vertical: '│',
  );

  /// ASCII-only box.
  ///
  /// ```
  /// +---------+
  /// | content |
  /// +---------+
  /// ```
  static const ascii = SignStyle(
    topLeft: '+',
    topRight: '+',
    bottomLeft: '+',
    bottomRight: '+',
    horizontal: '-',
    vertical: '|',
  );

  /// Left border only — no top, right, or bottom.
  ///
  /// ```
  /// │ content
  /// │ more
  /// ```
  static const leftOnly = SignStyle(
    topLeft: '',
    topRight: '',
    bottomLeft: '',
    bottomRight: '',
    horizontal: '',
    vertical: '│',
  );

  /// Whether this style draws a full enclosing box.
  bool get hasBox => horizontal.isNotEmpty;
}
