import 'package:howdy/howdy.dart';

void main() {
  // 1. Default rounded border with horizontal padding
  Sign(
    content:
        StyledText(
          'Title',
          style: TextStyle(bold: true, foreground: Color.purpleLight),
        ).render() +
        '\n\nThis is a sign widget. It wraps text automatically relative to '
            'the inner content width, respecting padding and margin.',
    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
    margin: const EdgeInsets.only(left: 2),
    width: 40,
  ).write();

  // 2. Colored border
  Sign(
    content:
        StyledText(
          'Warning',
          style: TextStyle(foreground: Color.yellow, bold: true),
        ).render() +
        '\n\nSomething important happened that you should know about.',
    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
    margin: const EdgeInsets.only(left: 2),
    width: 40,
    borderStyle: const TextStyle(foreground: Color.yellow),
  ).write();

  // 3. Left-only style
  Sign(
    content:
        StyledText('Note', style: TextStyle(bold: true)).render() +
        '\n\nThis uses the leftOnly style — just a vertical bar on the left, '
            'no enclosing box.',
    borderType: BorderType.leftOnly,
    padding: const EdgeInsets.only(left: 1),
    margin: const EdgeInsets.only(left: 2),
    width: 40,
    borderStyle: const TextStyle(foreground: Color.cyan),
  ).write();

  // 4. Sharp style, full terminal width
  Sign(
    content:
        StyledText('Full width sign', style: TextStyle(bold: true)).render() +
        '\n\nThis sign uses the full terminal width (minus margin). '
            'The text wraps automatically to fit.',
    borderType: BorderType.sharp,
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
    margin: const EdgeInsets.symmetric(horizontal: 2),
  ).write();
}
