/// Splits [text] into lines of at most [maxWidth] characters,
/// breaking only at whitespace boundaries.
///
/// If a single word is longer than [maxWidth], it is placed on its
/// own line without splitting (no mid-word breaks).
///
/// ```dart
/// wordWrap('The quick brown fox jumped over the lazy dog', 20);
/// // → ['The quick brown fox', 'jumped over the lazy', 'dog']
/// ```
List<String> wordWrap(String text, int maxWidth) {
  assert(maxWidth > 0, 'maxWidth must be positive');

  final lines = <String>[];
  // Process each hard newline separately.
  for (final paragraph in text.split('\n')) {
    if (paragraph.isEmpty) {
      lines.add('');
      continue;
    }

    final words = paragraph.split(' ');
    final current = StringBuffer();

    for (final word in words) {
      if (word.isEmpty) continue;

      if (current.isEmpty) {
        // First word on this line — always place it, even if over limit.
        current.write(word);
      } else if (current.length + 1 + word.length <= maxWidth) {
        // Word fits on the current line.
        current.write(' $word');
      } else {
        // Word doesn't fit — flush current line and start a new one.
        lines.add(current.toString());
        current.clear();
        current.write(word);
      }
    }

    if (current.isNotEmpty) lines.add(current.toString());
  }

  return lines;
}
