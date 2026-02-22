import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('FilePicker example');
  Text.body('-----------------------');
  terminal.writeln();
  terminal.writeln();

  FilePicker.send(title: 'Select a file to process:', initialDirectory: 'lib');
}
