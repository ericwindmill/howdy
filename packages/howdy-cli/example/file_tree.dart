import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('FileTree example');
  Text.body('-----------------------');
  terminal.writeln();

  FileTree.send('example');
}
