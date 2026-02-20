import 'dart:math';

import 'package:howdy/src/framework/edge_insets.dart';
import 'package:howdy/src/terminal/styled_text.dart';
import 'package:howdy/src/terminal/text_style.dart';
import 'package:howdy/src/terminal/wrap.dart';

class Border {
  const Border({
    this.borderType = BorderType.rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 1),
    this.borderStyle = const TextStyle(),
  });

  final BorderType borderType;
  final EdgeInsets padding;
  final TextStyle borderStyle;

  /// Wraps a string in a border.
  ///
  /// Which edges are drawn is controlled by the [BorderType] flags
  /// ([BorderType.top], [BorderType.right], [BorderType.bottom], [BorderType.left]).
  /// Use [BorderType.copyWith] to draw only specific sides:
  ///
  /// ```dart
  /// // Full box (default)
  /// terminal.write(myWidget.render().withBorder());
  ///
  /// // Left side only
  /// terminal.write(myWidget.render().withBorder(style: SignStyle.leftOnly));
  ///
  /// // Top + bottom only (no left/right)
  /// terminal.write(myWidget.render().withBorder(
  ///   style: SignStyle.rounded.copyWith(left: false, right: false),
  /// ));
  /// ```
  ///
  /// The string may contain ANSI escape sequences — width is measured on
  /// the stripped text so styling doesn't affect layout.
  static String wrap(
    String content, {
    BorderType borderType = BorderType.rounded,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 1),
    TextStyle? borderStyle,
  }) {
    // Split into lines, dropping a single trailing empty line from the
    // final \n that render() always appends.
    final lines = content.split('\n');
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();

    // Measure the widest visible line to determine inner content width.
    final innerWidth = lines.isEmpty
        ? 0
        : lines.map((l) => content.stripAnsi().length).reduce(max);

    // Total width inside the border (content + horizontal padding).
    final outerWidth = innerWidth + padding.horizontal;

    // Helper: optionally style a border character.
    String b(String char) {
      if (char.isEmpty) return '';
      return borderStyle != null
          ? StyledText(char, style: borderStyle).render()
          : char;
    }

    // Left/right edge characters for content rows.
    final leftEdge = borderType.left ? b(borderType.vertical) : '';
    final rightEdge = borderType.right ? b(borderType.vertical) : '';

    // Corner characters — fall back to the horizontal/vertical char when the
    // adjacent side isn't drawn, so partial borders look clean.
    String topLeftChar() {
      if (!borderType.top && !borderType.left) return '';
      if (!borderType.top) return leftEdge;
      if (!borderType.left) return b(borderType.horizontal);
      return b(borderType.topLeft);
    }

    String topRightChar() {
      if (!borderType.top && !borderType.right) return '';
      if (!borderType.top) return rightEdge;
      if (!borderType.right) return b(borderType.horizontal);
      return b(borderType.topRight);
    }

    String bottomLeftChar() {
      if (!borderType.bottom && !borderType.left) return '';
      if (!borderType.bottom) return leftEdge;
      if (!borderType.left) return b(borderType.horizontal);
      return b(borderType.bottomLeft);
    }

    String bottomRightChar() {
      if (!borderType.bottom && !borderType.right) return '';
      if (!borderType.bottom) return rightEdge;
      if (!borderType.right) return b(borderType.horizontal);
      return b(borderType.bottomRight);
    }

    final buf = StringBuffer();

    // Top border.
    if (borderType.top) {
      buf.writeln(
        '${topLeftChar()}'
        '${b(borderType.horizontal) * outerWidth}'
        '${topRightChar()}',
      );
    }

    // Top padding rows.
    for (var i = 0; i < padding.top; i++) {
      buf.writeln('$leftEdge${' ' * outerWidth}$rightEdge');
    }

    // Content rows — pad each line to innerWidth (visible chars only).
    for (final line in lines) {
      final visible = line.stripAnsi().length;
      final rightPad = ' ' * (innerWidth - visible);
      buf.writeln(
        '$leftEdge'
        '${' ' * padding.left}'
        '$line'
        '$rightPad'
        '${' ' * padding.right}'
        '$rightEdge',
      );
    }

    // Bottom padding rows.
    for (var i = 0; i < padding.bottom; i++) {
      buf.writeln('$leftEdge${' ' * outerWidth}$rightEdge');
    }

    // Bottom border.
    if (borderType.bottom) {
      buf.writeln(
        '${bottomLeftChar()}'
        '${b(borderType.horizontal) * outerWidth}'
        '${bottomRightChar()}',
      );
    }

    return buf.toString();
  }
}

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
class BorderType {
  const BorderType({
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
  BorderType copyWith({
    bool? top,
    bool? right,
    bool? bottom,
    bool? left,
  }) {
    return BorderType(
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
  static const rounded = BorderType(
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
  static const sharp = BorderType(
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
  static const ascii = BorderType(
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
  static const leftOnly = BorderType(
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
