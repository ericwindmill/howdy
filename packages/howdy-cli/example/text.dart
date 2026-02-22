import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Text example');
  Text.body('-----------------------');
  terminal.writeln();
  terminal.writeln();

  Text.send('This is a plain body line.');
}
