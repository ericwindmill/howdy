import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Select example');
  Text.body('-----------------------');
  terminal.writeln();

  Select.send<String>(
    'Preferred language',
    options: [
      Option(label: 'Dart', value: 'dart'),
      Option(label: 'TypeScript', value: 'ts'),
      Option(label: 'Python', value: 'py'),
      Option(label: 'Go', value: 'go'),
    ],
  );
}
