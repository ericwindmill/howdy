import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('BulletList example');
  Text.body('-----------------------');
  terminal.writeln();
  terminal.writeln();

  BulletList.send(
    [
      'Hydrogen',
      'Helium',
      'Lithium',
      'Beryllium',
      'Boron',
      'Carbon',
      'Nitrogen',
      'Oxygen',
      'Fluorine',
      'Neon',
    ],
    title: 'First 10 elements',
    maxVisibleRows: 7,
  );
}
