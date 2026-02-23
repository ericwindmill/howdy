import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Textarea example');
  Text.body('-----------------------');
  terminal.writeln();
  terminal.writeln();

  Textarea.send('Tell me about yourself.');

  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
}
