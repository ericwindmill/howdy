import 'package:howdy/howdy.dart';

void main() {
  Text.body('Textarea demo\n');

  terminal.maxWidth = 80;

  // 1. Basic Textarea with default value
  terminal.writeln('1. Textarea with default value:');
  Textarea.send(
    'Describe your project',
    help: 'A brief summary — press Enter for new lines, Ctrl+D to submit.',
    defaultValue: 'My awesome project...',
  );

  terminal.writeln();

  // 2. Textarea with validation
  terminal.writeln('2. Textarea with validation (must be non-empty):');
  Textarea.send(
    'Meeting notes',
    help: 'Required field. Enter notes and hit Ctrl+D.',
    validator: (v) {
      if (v.trim().isEmpty) {
        return 'Notes cannot be empty';
      }
      return null;
    },
  );
}
