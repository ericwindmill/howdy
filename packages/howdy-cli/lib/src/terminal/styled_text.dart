import 'package:howdy/src/terminal/text_style.dart';

/// A piece of text paired with a [TextStyle].
///
/// [StyledText] is the terminal equivalent of Flutter's `TextSpan` —
/// it combines content with formatting. Compose multiple spans into
/// a single line using [Terminal.writeSpans] or [renderSpans]:
///
/// ```dart
/// terminal.writeSpans([
///   StyledText('? ', style: TextStyle(foreground: AnsiColor.cyan)),
///   StyledText('Project name: ', style: TextStyle(bold: true)),
/// ]);
/// ```
class StyledText {
  /// The text content.
  final String text;

  /// The style to apply when rendering.
  final TextStyle style;

  const StyledText(this.text, {this.style = const TextStyle()});

  /// Render this span as a styled string (with ANSI escapes).
  String render() => style.apply(text);

  /// The raw length of [text] (without ANSI escape sequences).
  int get length => text.length;

  @override
  String toString() => render();

  /// Render a list of [StyledText] spans into a single string.
  ///
  /// Each span is styled independently, then concatenated.
  static String renderSpans(List<StyledText> spans) {
    return spans.map((s) => s.render()).join();
  }
}

extension StyledString on String {
  /// Apply an arbitrary [TextStyle] to this string.
  String style(TextStyle style) => StyledText(this, style: style).render();

  // ── Attributes ────────────────────────────────────────────────────────────

  /// Render this string in **bold**.
  String get bold => style(const TextStyle(bold: true));

  /// Render this string dimmed / faint.
  String get dim => style(const TextStyle(dim: true));

  /// Render this string in _italic_.
  String get italic => style(const TextStyle(italic: true));

  /// Render this string with an underline.
  String get underline => style(const TextStyle(underline: true));

  /// Render this string with a ~~strikethrough~~.
  String get strikethrough => style(const TextStyle(strikethrough: true));

  // ── Greyscale ─────────────────────────────────────────────────────────────

  /// Render this string in white.
  String get white => style(const TextStyle(foreground: Color.white));

  /// Render this string in light grey.
  String get greyLight => style(const TextStyle(foreground: Color.greyLight));

  /// Render this string in grey.
  String get grey => style(const TextStyle(foreground: Color.grey));

  /// Render this string in dark grey.
  String get greyDark => style(const TextStyle(foreground: Color.greyDark));

  /// Render this string in black.
  String get black => style(const TextStyle(foreground: Color.black));

  // ── Red ───────────────────────────────────────────────────────────────────

  /// Render this string in light red.
  String get redLight => style(const TextStyle(foreground: Color.redLight));

  /// Render this string in red.
  String get red => style(const TextStyle(foreground: Color.red));

  /// Render this string in dark red.
  String get redDark => style(const TextStyle(foreground: Color.redDark));

  // ── Orange ────────────────────────────────────────────────────────────────

  /// Render this string in light orange.
  String get orangeLight =>
      style(const TextStyle(foreground: Color.orangeLight));

  /// Render this string in orange.
  String get orange => style(const TextStyle(foreground: Color.orange));

  /// Render this string in dark orange.
  String get orangeDark => style(const TextStyle(foreground: Color.orangeDark));

  // ── Yellow ────────────────────────────────────────────────────────────────

  /// Render this string in light yellow.
  String get yellowLight =>
      style(const TextStyle(foreground: Color.yellowLight));

  /// Render this string in yellow.
  String get yellow => style(const TextStyle(foreground: Color.yellow));

  /// Render this string in dark yellow.
  String get yellowDark => style(const TextStyle(foreground: Color.yellowDark));

  // ── Green ─────────────────────────────────────────────────────────────────

  /// Render this string in light green.
  String get greenLight => style(const TextStyle(foreground: Color.greenLight));

  /// Render this string in green.
  String get green => style(const TextStyle(foreground: Color.green));

  /// Render this string in dark green.
  String get greenDark => style(const TextStyle(foreground: Color.greenDark));

  // ── Blue ──────────────────────────────────────────────────────────────────

  /// Render this string in light blue.
  String get blueLight => style(const TextStyle(foreground: Color.blueLight));

  /// Render this string in blue.
  String get blue => style(const TextStyle(foreground: Color.blue));

  /// Render this string in dark blue.
  String get blueDark => style(const TextStyle(foreground: Color.blueDark));

  // ── Purple ────────────────────────────────────────────────────────────────

  /// Render this string in light purple.
  String get purpleLight =>
      style(const TextStyle(foreground: Color.purpleLight));

  /// Render this string in purple.
  String get purple => style(const TextStyle(foreground: Color.purple));

  /// Render this string in dark purple.
  String get purpleDark => style(const TextStyle(foreground: Color.purpleDark));

  // ── Magenta ───────────────────────────────────────────────────────────────

  /// Render this string in light magenta.
  String get magentaLight =>
      style(const TextStyle(foreground: Color.magentaLight));

  /// Render this string in magenta.
  String get magenta => style(const TextStyle(foreground: Color.magenta));

  /// Render this string in dark magenta.
  String get magentaDark =>
      style(const TextStyle(foreground: Color.magentaDark));

  // ── Teal ──────────────────────────────────────────────────────────────────

  /// Render this string in light teal.
  String get tealLight => style(const TextStyle(foreground: Color.tealLight));

  /// Render this string in teal.
  String get teal => style(const TextStyle(foreground: Color.teal));

  /// Render this string in dark teal.
  String get tealDark => style(const TextStyle(foreground: Color.tealDark));

  // ── Cyan ──────────────────────────────────────────────────────────────────

  /// Render this string in light cyan.
  String get cyanLight => style(const TextStyle(foreground: Color.cyanLight));

  /// Render this string in cyan.
  String get cyan => style(const TextStyle(foreground: Color.cyan));

  /// Render this string in dark cyan.
  String get cyanDark => style(const TextStyle(foreground: Color.cyanDark));
}
