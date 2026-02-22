import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();
  Text.body('Confirm example');
  Text.body('-----------------------');
  terminal.writeln();

  ConfirmInput.send(
    'Are you sure?',
    help: "You should be ${'very'.italic} sure.",
  );
}
