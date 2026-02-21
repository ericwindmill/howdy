import 'package:howdy/howdy.dart';

void main() {
  Text.body('Scrollable list example');

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
      'Sodium',
      'Magnesium',
      'Aluminium',
      'Silicon',
      'Phosphorus',
    ],
    title: 'First 15 elements',
    maxVisibleRows: 7,
  );
}
