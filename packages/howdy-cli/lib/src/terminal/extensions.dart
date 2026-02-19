import 'dart:math';

import 'package:howdy/howdy.dart';

// Matches any ANSI escape sequence: ESC [ ... m
final _ansiEscape = RegExp(r'\x1B\[[0-9;]*m');

/// Strips ANSI escape sequences from [s], returning plain text.
String stripAnsi(String s) => s.replaceAll(_ansiEscape, '');

extension StringBorderExtension on String {
  /// The visible (printable) length of this string, ignoring ANSI escapes.
  int get visibleLength => stripAnsi(this).length;

  /// Wraps this rendered string in a border.
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
  String withBorder({
    BorderType borderType = BorderType.rounded,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 1),
    TextStyle? borderStyle,
  }) {
    // Split into lines, dropping a single trailing empty line from the
    // final \n that render() always appends.
    final lines = split('\n');
    if (lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();

    // Measure the widest visible line to determine inner content width.
    final innerWidth = lines.isEmpty
        ? 0
        : lines.map((l) => stripAnsi(l).length).reduce(max);

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
      final visible = stripAnsi(line).length;
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
