import 'package:howdy/howdy.dart';

void main() {
  Text.body('Prompt demo');
  Text.body('');

  Prompt(
    label:
        'What is your favorite animal? What is your favorite animal? What is your favorite animal? What is your favorite animal?',
    help:
        'This is important information for our database. This is important information for our database. This is important information for our database. This is important information for our database. This is important information for our database.',
    defaultValue: 'cat',
    validator: (value) {
      if (value != 'cat') {
        return "Are you sure it isn't cat?";
      }
      return null;
    },
  ).write();
}
