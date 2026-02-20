// Matches any ANSI escape sequence: ESC [ ... m
final _ansiEscape = RegExp(r'\x1B\[[0-9;]*m');

extension AnsiWrap on String {
  /// The visible (printable) length of this string, ignoring ANSI escapes.
  int get visibleLength => stripAnsi().length;

  /// Strips ANSI escape sequences from [s], returning plain text.
  String stripAnsi() => replaceAll(_ansiEscape, '');

  /// Wraps text to a maximum [width] while ignoring ANSI escape sequences.
  ///
  /// Splits on spaces where possible to keep words whole. Existing
  /// newlines are preserved and reset the line width counter.
  String wordWrap(int width) {
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
