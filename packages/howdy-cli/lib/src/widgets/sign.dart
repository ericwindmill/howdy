import 'package:howdy/howdy.dart';

/// A widget that wraps [List<StyledText>] content in a configurable border.
///
/// Supports padding, margin, automatic word-wrap relative to the inner
/// content width, and optional border coloring.
///
/// ```dart
/// Sign(
///   content: [
///     StyledText('Title', style: TextStyle(bold: true)),
///     StyledText('Some longer text that will wrap automatically.'),
///   ],
///   padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
/// ).write();
/// ```
///
/// Output:
/// ```
/// ╭──────────────────────╮
/// │                      │
/// │ Title                │
/// │ Some longer text     │
/// │ that will wrap       │
/// │ automatically.       │
/// │                      │
/// ╰──────────────────────╯
/// ```
class Sign extends DisplayWidget {
  Sign({
    required this.content,
    this.style = SignStyle.rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 1),
    this.margin = EdgeInsets.zero,
    this.width,
    this.borderStyle,
    super.key,
    super.theme,
  });

  /// The content to display inside the sign.
  final List<StyledText> content;

  /// Border character set. Defaults to [SignStyle.rounded].
  final SignStyle style;

  /// Inner padding between the border and the content.
  final EdgeInsets padding;

  /// Outer margin around the entire sign.
  ///
  /// Left/right margin reduces the sign width. Top/bottom margin
  /// adds blank lines above and below.
  final EdgeInsets margin;

  /// Explicit inner content width in characters.
  ///
  /// If null, the width is derived from the terminal width minus
  /// margin, border, and padding.
  final int? width;

  /// Optional style applied to border characters.
  final TextStyle? borderStyle;

  @override
  String build(IndentedStringBuffer buf) {
    final innerWidth = _resolveInnerWidth();
    final outerWidth = innerWidth + padding.horizontal;

    // Helper: render a border character (optionally styled).
    String b(String char) {
      if (char.isEmpty) return '';
      final bs = borderStyle;
      return bs != null ? StyledText(char, style: bs).render() : char;
    }

    // Top margin.
    for (var i = 0; i < margin.top; i++) {
      buf.writeln();
    }

    final leftMarginStr = ' ' * margin.left;

    // Top border.
    if (style.hasBox) {
      buf.writeln(
        '$leftMarginStr'
        '${b(style.topLeft)}'
        '${b(style.horizontal) * outerWidth}'
        '${b(style.topRight)}',
      );
    }

    // Top padding rows.
    for (var i = 0; i < padding.top; i++) {
      buf.writeln(
        '$leftMarginStr'
        '${b(style.vertical)}'
        '${' ' * outerWidth}'
        '${style.hasBox ? b(style.vertical) : ''}',
      );
    }

    // Content rows — word-wrap each StyledText paragraph.
    for (final span in content) {
      final lines = wordWrap(span.text, innerWidth);
      for (final line in lines) {
        final paddedLine = line.padRight(innerWidth);
        final styledLine = StyledText(paddedLine, style: span.style).render();
        buf.writeln(
          '$leftMarginStr'
          '${b(style.vertical)}'
          '${' ' * padding.left}'
          '$styledLine'
          '${' ' * padding.right}'
          '${style.hasBox ? b(style.vertical) : ''}',
        );
      }
    }

    // Bottom padding rows.
    for (var i = 0; i < padding.bottom; i++) {
      buf.writeln(
        '$leftMarginStr'
        '${b(style.vertical)}'
        '${' ' * outerWidth}'
        '${style.hasBox ? b(style.vertical) : ''}',
      );
    }

    // Bottom border.
    if (style.hasBox) {
      buf.writeln(
        '$leftMarginStr'
        '${b(style.bottomLeft)}'
        '${b(style.horizontal) * outerWidth}'
        '${b(style.bottomRight)}',
      );
    }

    // Bottom margin.
    for (var i = 0; i < margin.bottom; i++) {
      buf.writeln();
    }

    return buf.toString();
  }

  /// Compute the inner content width (excluding padding and border).
  int _resolveInnerWidth() {
    if (width != null) return width!;
    final borderWidth = style.hasBox ? 2 : 1; // left + right border chars
    final available =
        terminal.columns - margin.horizontal - borderWidth - padding.horizontal;
    return available.clamp(1, terminal.columns);
  }

  @override
  void write() {
    terminal.write(render());
  }
}
