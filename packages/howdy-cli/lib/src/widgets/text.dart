import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';

class Text extends DisplayWidget {
  Text(
    this.input, {
    this.leading = '',
    this.style = const TextStyle(),
    this.newline = true,
  });

  final String input;
  final String leading;
  final TextStyle style;
  final bool newline;

  static void body(String input) {
    Text(input).write();
  }

  static void warning(String input) {
    Text(
      input,
      leading: Icon.warning + ' ',
      style: TextStyle(foreground: Color.yellow),
    ).write();
  }

  static void error(String input) {
    Text(
      input,
      leading: Icon.error + ' ',
      style: TextStyle(foreground: Color.red),
    ).write();
  }

  static void success(String input) {
    Text(
      input,
      leading: Icon.check + ' ',
      style: TextStyle(foreground: Color.green),
    ).write();
  }

  @override
  String build(StringBuffer buf) {
    final buffer = StringBuffer();
    final spans = [
      if (leading.isNotEmpty) StyledText(leading, style: style),
      StyledText(input, style: style),
    ];
    newline ? buffer.writeSpansLn(spans) : buffer.writeSpans(spans);
    return buffer.toString();
  }

  @override
  bool get isDone => true;

  @override
  void write() {
    terminal.write(render());
  }
}
