/// Named colors using 24-bit RGB values.
///
/// Uses true-color ANSI escape sequences (`38;2;r;g;b` for fg,
/// `48;2;r;g;b` for bg), which are supported by virtually all
/// modern terminals.
///
/// Add new named colors by adding enum values with RGB tuples.
enum Color {
  // Standard colors (approximate RGB equivalents)
  black(0, 0, 0),
  red(204, 0, 0),
  green(78, 154, 6),
  yellow(196, 160, 0),
  blue(52, 101, 164),
  magenta(117, 80, 123),
  cyan(6, 152, 154),
  purpleLight(114, 70, 235),
  purple(69, 9, 235),
  white(211, 215, 207),

  // Bright colors
  brightBlack(85, 87, 83),
  brightRed(239, 41, 41),
  brightGreen(138, 226, 52),
  brightYellow(252, 233, 79),
  brightBlue(114, 159, 207),
  brightMagenta(173, 127, 168),
  brightCyan(52, 226, 226),
  brightWhite(238, 238, 236),
  ;

  final int r;
  final int g;
  final int b;

  const Color(this.r, this.g, this.b);

  /// ANSI true-color foreground sequence parameter.
  String get fgCode => '38;2;$r;$g;$b';

  /// ANSI true-color background sequence parameter.
  String get bgCode => '48;2;$r;$g;$b';
}

/// Composable text styling using ANSI escape codes.
///
/// Modeled after Flutter's `TextStyle` — combine styles with [copyWith]
/// or the `+` operator:
///
/// ```dart
/// final style = TextStyle(bold: true, foreground: AnsiColor.cyan);
/// final emphatic = style + TextStyle(italic: true);
/// print(style.apply('Hello, world!'));
/// ```
class TextStyle {
  /// Whether to render text in bold.
  final bool bold;

  /// Whether to render text dimmed.
  final bool dim;

  /// Whether to render text in italic.
  final bool italic;

  /// Whether to render text underlined.
  final bool underline;

  /// Whether to render text with a strikethrough.
  final bool strikethrough;

  /// The foreground (text) color.
  final Color? foreground;

  /// The background color.
  final Color? background;

  const TextStyle({
    this.bold = false,
    this.dim = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.foreground,
    this.background,
  });

  /// Create a new [TextStyle] by overriding individual properties.
  TextStyle copyWith({
    bool? bold,
    bool? dim,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    Color? foreground,
    Color? background,
  }) {
    return TextStyle(
      bold: bold ?? this.bold,
      dim: dim ?? this.dim,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
    );
  }

  /// Merge two styles. [other]'s non-default values take precedence.
  TextStyle operator +(TextStyle other) {
    return TextStyle(
      bold: other.bold || bold,
      dim: other.dim || dim,
      italic: other.italic || italic,
      underline: other.underline || underline,
      strikethrough: other.strikethrough || strikethrough,
      foreground: other.foreground ?? foreground,
      background: other.background ?? background,
    );
  }

  /// Whether this style has any formatting applied.
  bool get hasStyle =>
      bold ||
      dim ||
      italic ||
      underline ||
      strikethrough ||
      foreground != null ||
      background != null;

  /// Generate the ANSI SGR escape sequence for this style.
  ///
  /// Returns an empty string if no styles are set.
  String get openSequence {
    if (!hasStyle) return '';
    final parts = <String>[];
    if (bold) parts.add('1');
    if (dim) parts.add('2');
    if (italic) parts.add('3');
    if (underline) parts.add('4');
    if (strikethrough) parts.add('9');
    if (foreground != null) parts.add(foreground!.fgCode);
    if (background != null) parts.add(background!.bgCode);
    return '\x1B[${parts.join(";")}m';
  }

  /// The ANSI reset sequence.
  static const String resetSequence = '\x1B[0m';

  /// Apply this style to [text].
  ///
  /// Wraps [text] in the open sequence and a reset sequence.
  /// If no style is set, returns [text] unchanged.
  String apply(String text) {
    if (!hasStyle) return text;
    return '$openSequence$text$resetSequence';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextStyle &&
          bold == other.bold &&
          dim == other.dim &&
          italic == other.italic &&
          underline == other.underline &&
          strikethrough == other.strikethrough &&
          foreground == other.foreground &&
          background == other.background;

  @override
  int get hashCode => Object.hash(
    bold,
    dim,
    italic,
    underline,
    strikethrough,
    foreground,
    background,
  );

  @override
  String toString() {
    final parts = <String>[];
    if (bold) parts.add('bold');
    if (dim) parts.add('dim');
    if (italic) parts.add('italic');
    if (underline) parts.add('underline');
    if (strikethrough) parts.add('strikethrough');
    if (foreground != null) parts.add('fg:${foreground!.name}');
    if (background != null) parts.add('bg:${background!.name}');
    return 'TextStyle(${parts.join(', ')})';
  }
}
