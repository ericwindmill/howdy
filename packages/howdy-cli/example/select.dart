import 'package:howdy/howdy.dart';

void main() {
  terminal.writeln('Select demo\n');

  // 1. Basic Single-choice list
  terminal.writeln('1. Basic Select:');
  final lang = Select.send<String>(
    label: 'Preferred language',
    options: [
      Option(label: 'Dart', value: 'dart'),
      Option(label: 'TypeScript', value: 'ts'),
      Option(label: 'Python', value: 'py'),
      Option(label: 'Go', value: 'go'),
    ],
  );

  Text.success('You chose: $lang');
  terminal.writeln();

  // 2. Select with default value and help text
  terminal.writeln('2. Select with default and help:');
  final theme = Select.send<String>(
    label: 'Theme',
    options: [
      Option(label: 'Light', value: 'light'),
      Option(label: 'Dark', value: 'dark'),
      Option(label: 'System', value: 'system'),
    ],
  );

  Text.success('Theme set to: $theme');
}
