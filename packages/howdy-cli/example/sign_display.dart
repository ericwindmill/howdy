import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Sign example');
  Text.body('-----------------------');
  terminal.writeln();
  terminal.writeln();

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
}
