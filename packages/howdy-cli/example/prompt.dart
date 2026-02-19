import 'package:howdy/howdy.dart';

void main() {
  Text.body('Prompt demo');
  Text.body('');

  terminal.maxWidth = 80;

  // 1. Basic Prompt with default and validation
  terminal.writeln('1. Prompt with default and validation:');
  Prompt.send(
    'What is your name?',
    help:
        'Please enter your full name. This helps us verify your identity securely and accurately.',
    defaultValue: 'John Doe',
    validator: (value) {
      if (value.trim().isEmpty) return 'Name is required';
      if (value != 'cat') {
        return "Are you sure it isn't cat?";
      }
      return null;
    },
  );

  terminal.writeln();

  // 2. Simple Prompt with no default
  terminal.writeln('2. Simple Prompt:');
  Prompt.send('What is your favorite color?');

  terminal.writeln();

  // 3. Prompt within a Group
  terminal.writeln('3. Prompt in a Group:');
  Group.send([
    Text('Profile Setup'),
    Prompt(
      label: 'Username',
      validator: (v) => v.isEmpty ? 'Required' : null,
    ),
    Prompt(
      label: 'City',
    ),
  ]);
}
