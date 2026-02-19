import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';

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

  /// Convenience method — renders and writes a Sign immediately.
  static void send(
    List<StyledText> content, {
    SignStyle style = SignStyle.rounded,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 1),
    EdgeInsets margin = EdgeInsets.zero,
    int? width,
    TextStyle? borderStyle,
  }) {
    Sign(
      content: content,
      style: style,
      padding: padding,
      margin: margin,
      width: width,
      borderStyle: borderStyle,
    ).write();
  }

  @override
  String build(IndentedStringBuffer buf) {
    final innerWidth = _resolveInnerWidth();

    // Top margin.
    for (var i = 0; i < margin.top; i++) {
      buf.writeln();
    }

    // Render each StyledText span with word-wrap into a plain string,
    // then delegate all border drawing to withBorder.
    final contentBuf = StringBuffer();
    for (final span in content) {
      for (final line in wordWrap(span.text, innerWidth)) {
        contentBuf.writeln(StyledText(line, style: span.style).render());
      }
    }

    final leftMarginStr = ' ' * margin.left;
    final bordered = contentBuf.toString().withBorder(
      style: style,
      padding: padding,
      borderStyle: borderStyle,
    );

    // Prepend left margin to every line.
    for (final line in bordered.split('\n')) {
      if (line.isEmpty) continue; // skip the trailing empty from split
      buf.writeln('$leftMarginStr$line');
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
