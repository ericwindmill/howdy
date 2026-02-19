import 'package:howdy/howdy.dart';

void main() {
  Text.body('Prompt demo');
  Text.body('');

  Prompt(
    label: 'What is your favorite animal?',
    help: 'This is important information for our database.',
    defaultValue: 'cat',
    validator: (value) {
      if (value != 'cat') {
        return "Are you sure it isn't cat?";
      }
      return null;
    },
  ).write();

  Text.body('');

  Prompt.textarea(
    label: 'Describe your project',
    help: 'A brief summary — press Enter for new lines, Ctrl+D to submit.',
    defaultValue: 'My awesome project...',
  ).write();
}
