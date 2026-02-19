import 'package:howdy/howdy.dart';

class Text extends DisplayWidget {
  Text(
    this.label, {
    this.leading = '',
    this.style = const TextStyle(),
    this.newline = true,
  });

  static void body(String input) {
    Text(input).write();
  }

  static void error(String input) {
    Text(
      input,
      leading: Icon.error + ' ',
      style: Theme.current.focused.errorMessage,
    ).write();
  }

  /// Convenience factory — renders a [Text] with a custom [style] and optional [leading].
  static void send(
    String input, {
    String leading = '',
    TextStyle style = const TextStyle(),
    bool newline = true,
  }) {
    Text(input, leading: leading, style: style, newline: newline).write();
  }

  static void success(String input) {
    Text(
      input,
      leading: Icon.check + ' ',
      style: Theme.current.focused.successMessage,
    ).write();
  }

  static void warning(String input) {
    Text(
      input,
      leading: Icon.warning + ' ',
      style: Theme.current.focused.warningMessage,
    ).write();
  }

  final String label;
  final String leading;
  final bool newline;
  final TextStyle style;

  @override
  bool get isDone => true;

  @override
  String build(IndentedStringBuffer buf) {
    final buffer = StringBuffer();
    final spans = [
      if (leading.isNotEmpty) StyledText(leading, style: style),
      StyledText(label, style: style),
    ];
    newline
        ? buffer.writeln(renderSpans(spans))
        : buffer.write(renderSpans(spans));
    return buffer.toString();
  }

  @override
  void write() {
    terminal.write(render());
  }
}
