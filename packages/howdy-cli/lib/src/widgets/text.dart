import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';
import 'package:howdy/src/terminal/theme.dart';

class Text extends DisplayWidget {
  Text(
    this.label, {
    this.leading = '',
    this.style = const TextStyle(),
    this.newline = true,
  });

  final String label;
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
      style: Theme.current.warning,
    ).write();
  }

  static void error(String input) {
    Text(
      input,
      leading: Icon.error + ' ',
      style: Theme.current.error,
    ).write();
  }

  static void success(String input) {
    Text(
      input,
      leading: Icon.check + ' ',
      style: Theme.current.success,
    ).write();
  }

  @override
  String build(IndentedStringBuffer buf) {
    final buffer = StringBuffer();
    final spans = [
      if (leading.isNotEmpty) StyledText(leading, style: style),
      StyledText(label, style: style),
    ];
    newline ? buffer.writeSpansLn(spans) : buffer.writeSpans(spans);
    return buffer.toString();
  }

  bool get isDone => true;

  @override
  void write() {
    terminal.write(render());
  }
}
