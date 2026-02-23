import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Text example');
  Text.body('-----------------------');
  terminal.writeln();

  Text.body('This is a plain body line.');
  Text.success('This is success text.');
  Text.warning('This is warning text.');
  Text.error('This is error text.');

  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
  terminal.writeln();
}
