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
    this.borderType = BorderType.rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 1),
    this.margin = EdgeInsets.zero,
    this.width,
    this.borderStyle,
    super.key,
    super.theme,
  });

  /// Convenience method — renders and writes a Sign immediately.
  static void send(
    List<StyledText> content, {
    BorderType borderType = BorderType.rounded,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 1),
    EdgeInsets margin = EdgeInsets.zero,
    int? width,
    TextStyle? borderStyle,
  }) {
    Sign(
      content: content,
      borderType: borderType,
      padding: padding,
      margin: margin,
      width: width,
      borderStyle: borderStyle,
    ).write();
  }

  /// Border character set. Defaults to [BorderType.rounded].
  final BorderType borderType;

  /// Optional style applied to border characters.
  final TextStyle? borderStyle;

  /// The content to display inside the sign.
  final List<StyledText> content;

  /// Outer margin around the entire sign.
  ///
  /// Left/right margin reduces the sign width. Top/bottom margin
  /// adds blank lines above and below.
  final EdgeInsets margin;

  /// Inner padding between the border and the content.
  final EdgeInsets padding;

  /// Explicit inner content width in characters.
  ///
  /// If null, the width is derived from the terminal width minus
  /// margin, border, and padding.
  final int? width;

  @override
  String build(IndentedStringBuffer buf) {
    // Top margin.
    for (var i = 0; i < margin.top; i++) {
      buf.writeln();
    }

    // Render each StyledText span into a plain string,
    // then delegate all border drawing to withBorder.
    final contentBuf = StringBuffer();
    for (final span in content) {
      for (final line in span.text.split('\n')) {
        contentBuf.writeln(StyledText(line, style: span.style).render());
      }
    }

    final leftMarginStr = ' ' * margin.left;
    final bordered = contentBuf.toString().withBorder(
      borderStyle: borderStyle,
      padding: padding,
      borderType: borderType,
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

  @override
  void write() {
    terminal.write(render());
  }
}
