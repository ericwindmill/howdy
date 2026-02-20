import 'package:howdy/howdy.dart';

void main() {
  final picked = FilePicker.send(
    label: 'Select a file to process:',
    initialDirectory: 'lib',
  );
  Text.success('You picked: ${picked.path}');
}
