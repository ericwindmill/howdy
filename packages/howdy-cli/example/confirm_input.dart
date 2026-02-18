import 'package:howdy/howdy.dart';

void main() {
  Text.body('Prompt demo');
  Text.body('');

  ConfirmInput(
    label: 'Are you sure?',
    help: 'Really?',
    defaultValue: true,
  ).write();
}
