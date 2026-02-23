import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Multiselect example');
  Text.body('-----------------------');
  terminal.writeln();

  Multiselect.send<String>(
    'Features',
    options: [
      Option(label: 'Linting', value: 'lint'),
      Option(label: 'Testing', value: 'test'),
      Option(label: 'CI/CD', value: 'ci'),
      Option(label: 'Docker', value: 'docker'),
      Option(label: 'Logging', value: 'logging'),
    ],
  );
}
