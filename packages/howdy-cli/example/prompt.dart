import 'package:howdy/howdy.dart';

void main() {
  Text.body('Prompt demo');
  Text.body('');

  terminal.maxWidth = 40;

  Prompt.send(
    '1. What is your name?',
    help:
        'Please enter your full name as it appears on your birth certificate or driver\'s license. This helps us verify your identity securely and accurately.',
    defaultValue: 'John Doe',
    validator: (value) {
      if (value != 'cat') {
        return "Are you sure it isn't cat?";
      }
      return null;
    },
  );

  Text.body('');

  Prompt.textarea(
    label: 'Describe your project',
    help: 'A brief summary — press Enter for new lines, Ctrl+D to submit.',
    defaultValue: 'My awesome project...',
  ).write();
}
