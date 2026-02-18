import 'dart:math';

import 'package:howdy/howdy.dart';

extension Spans on StringBuffer {
  void writeSpan(StyledText span) {
    final rendered = renderSpans([span]);
    write(rendered);
  }

  void writeSpanLn(StyledText span) {
    final rendered = renderSpans([span]);
    writeln(rendered);
  }

  void writeSpans(List<StyledText> spans) {
    final rendered = renderSpans(spans);
    write(rendered);
  }

  void writeSpansLn(List<StyledText> spans) {
    final rendered = renderSpans(spans);
    writeln(rendered);
  }
}

// Matches any ANSI escape sequence: ESC [ ... m
final _ansiEscape = RegExp(r'\x1B\[[0-9;]*m');

/// Strips ANSI escape sequences from [s], returning plain text.
String stripAnsi(String s) => s.replaceAll(_ansiEscape, '');

extension StringBorderExtension on String {
  /// The visible (printable) length of this string, ignoring ANSI escapes.
  int get visibleLength => stripAnsi(this).length;

  /// Wraps this rendered string in a border.
  ///
  /// Which edges are drawn is controlled by the [SignStyle] flags
  /// ([SignStyle.top], [SignStyle.right], [SignStyle.bottom], [SignStyle.left]).
  /// Use [SignStyle.copyWith] to draw only specific sides:
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
    SignStyle style = SignStyle.rounded,
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
    final leftEdge = style.left ? b(style.vertical) : '';
    final rightEdge = style.right ? b(style.vertical) : '';

    // Corner characters — fall back to the horizontal/vertical char when the
    // adjacent side isn't drawn, so partial borders look clean.
    String topLeftChar() {
      if (!style.top && !style.left) return '';
      if (!style.top) return leftEdge;
      if (!style.left) return b(style.horizontal);
      return b(style.topLeft);
    }

    String topRightChar() {
      if (!style.top && !style.right) return '';
      if (!style.top) return rightEdge;
      if (!style.right) return b(style.horizontal);
      return b(style.topRight);
    }

    String bottomLeftChar() {
      if (!style.bottom && !style.left) return '';
      if (!style.bottom) return leftEdge;
      if (!style.left) return b(style.horizontal);
      return b(style.bottomLeft);
    }

    String bottomRightChar() {
      if (!style.bottom && !style.right) return '';
      if (!style.bottom) return rightEdge;
      if (!style.right) return b(style.horizontal);
      return b(style.bottomRight);
    }

    final buf = StringBuffer();

    // Top border.
    if (style.top) {
      buf.writeln(
        '${topLeftChar()}'
        '${b(style.horizontal) * outerWidth}'
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
    if (style.bottom) {
      buf.writeln(
        '${bottomLeftChar()}'
        '${b(style.horizontal) * outerWidth}'
        '${bottomRightChar()}',
      );
    }

    return buf.toString();
  }
}
