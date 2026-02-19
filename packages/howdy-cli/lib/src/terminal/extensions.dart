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

  /// Wraps text to a maximum [width] while ignoring ANSI escape sequences.
  ///
  /// Splits on spaces where possible to keep words whole. Existing
  /// newlines are preserved and reset the line width counter.
  String wrapAnsi(int width) {
    if (width <= 0) return this;

    final result = StringBuffer();
    final currentLineChars = <String>[];
    int visibleLength = 0;

    void flushLine() {
      result.write(currentLineChars.join());
      result.write('\n');
      currentLineChars.clear();
      visibleLength = 0;
    }

    // A RegExp that finds either:
    // 1. An ANSI escape sequence (captured in group 1)
    // 2. A single character (captured in group 2)
    final regex = RegExp(r'(\x1B\[[0-9;]*m)|([\s\S])');

    for (final match in regex.allMatches(this)) {
      final ansi = match.group(1);
      final char = match.group(2);

      if (ansi != null) {
        // ANSI codes take 0 visible width.
        currentLineChars.add(ansi);
      } else if (char != null) {
        if (char == '\n') {
          // Explicit newline resets the count.
          currentLineChars.add(char);
          result.write(currentLineChars.join());
          currentLineChars.clear();
          visibleLength = 0;
        } else {
          currentLineChars.add(char);
          visibleLength++;

          if (visibleLength > width) {
            // Reached max width. Try to backtrack and wrap at the last space.
            // Look for a space in the current line buffer.
            int? lastSpaceIndex;
            for (var i = currentLineChars.length - 1; i >= 0; i--) {
              final checkChar = currentLineChars[i];
              // Simple space check. If we wanted to ignore ANSI we just look
              // for actual ' ' strings.
              if (checkChar == ' ') {
                lastSpaceIndex = i;
                break;
              }
            }

            if (lastSpaceIndex != null) {
              // Found a space. Split the line there.
              // Everything up to (but not including) the space goes on this line.
              final beforeSpace = currentLineChars.sublist(0, lastSpaceIndex);
              // Everything after the space wraps to the next line.
              final afterSpace = currentLineChars.sublist(lastSpaceIndex + 1);

              result.write(beforeSpace.join());
              result.write('\n');

              currentLineChars.clear();
              currentLineChars.addAll(afterSpace);
              // Recalculate visible length for the wrapped portion.
              visibleLength = currentLineChars
                  .where((c) => !c.startsWith('\x1B['))
                  .length;
            } else {
              // No space found (a single word longer than max width).
              // We must hard-wrap exactly at the current character.
              // The current character is the one that tipped us OVER the limit,
              // so it belongs on the NEXT line.
              final charToMove = currentLineChars.removeLast();
              flushLine();
              currentLineChars.add(charToMove);
              visibleLength = 1;
            }
          }
        }
      }
    }

    // Flush any remaining characters
    if (currentLineChars.isNotEmpty) {
      result.write(currentLineChars.join());
    }

    // updateScreen expects trailing strings to not accidentally gain newlines
    // unless the original had them or we wrapped. Our logic above might end up
    // perfectly matching max width without an extra char. But StringBuffer
    // writes as needed.
    return result.toString();
  }
}
