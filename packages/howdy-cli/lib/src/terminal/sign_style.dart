/// Border character sets for [Sign] rendering and [String.withBorder].
///
/// Defines the characters needed to draw a box border, plus per-side
/// flags that control which edges are actually rendered.
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
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.left = true,
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

  /// Whether to draw the top border edge.
  final bool top;

  /// Whether to draw the right border edge.
  final bool right;

  /// Whether to draw the bottom border edge.
  final bool bottom;

  /// Whether to draw the left border edge.
  final bool left;

  /// Returns a copy of this style with the given sides overridden.
  SignStyle copyWith({
    bool? top,
    bool? right,
    bool? bottom,
    bool? left,
  }) {
    return SignStyle(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      horizontal: horizontal,
      vertical: vertical,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
    );
  }

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
    top: false,
    right: false,
    bottom: false,
    left: true,
  );

  /// Whether this style draws a full enclosing box (all four sides).
  bool get hasBox => top && right && bottom && left;
}
