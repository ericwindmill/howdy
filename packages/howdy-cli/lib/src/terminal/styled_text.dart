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
}

/// Render a list of [StyledText] spans into a single string.
///
/// Each span is styled independently, then concatenated.
String renderSpans(List<StyledText> spans) {
  return spans.map((s) => s.render()).join();
}

extension StyledString on String {
  String style(TextStyle style) {
    final span = StyledText(this, style: style);
    return span.render();
  }

  String get dim {
    return StyledText(this, style: TextStyle(dim: true)).render();
  }

  String get extraDim {
    return StyledText(
      this,
      style: TextStyle(dim: true, foreground: Color.grey),
    ).render();
  }

  String get red {
    return StyledText(
      this,
      style: TextStyle(foreground: Color.red),
    ).render();
  }

  String get green {
    return StyledText(
      this,
      style: TextStyle(foreground: Color.green),
    ).render();
  }
}
