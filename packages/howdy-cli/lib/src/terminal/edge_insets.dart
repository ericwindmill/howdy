/// Describes offsets from each edge — used for padding and margin in [Sign].
class EdgeInsets {
  const EdgeInsets.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  const EdgeInsets.all(int value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  const EdgeInsets.symmetric({int horizontal = 0, int vertical = 0})
    : left = horizontal,
      top = vertical,
      right = horizontal,
      bottom = vertical;

  /// No insets on any side.
  static const EdgeInsets zero = EdgeInsets.all(0);

  final int left;
  final int top;
  final int right;
  final int bottom;

  /// Total horizontal inset (left + right).
  int get horizontal => left + right;

  /// Total vertical inset (top + bottom).
  int get vertical => top + bottom;
}
