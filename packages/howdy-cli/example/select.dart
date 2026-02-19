import 'package:howdy/howdy.dart';

void main() {
  terminal.writeln('Select demo\n');

  // Single-choice list
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
}
