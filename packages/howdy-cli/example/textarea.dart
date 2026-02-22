import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Textarea example');
  Text.body('-----------------------');
  terminal.writeln();
  terminal.writeln();

  Textarea.send('Describe your project');
}
