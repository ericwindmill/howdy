import 'package:howdy/howdy.dart';

void main(List<String> args) {
  // 1. Basic Multiselect with validation
  terminal.writeln('1. Project Features (with validation):');
  Multiselect.send<String>(
    label: 'Features',
    options: [
      Option(label: 'Linting', value: 'lint'),
      Option(label: 'Testing', value: 'test'),
      Option(label: 'CI/CD', value: 'ci'),
      Option(label: 'Docker', value: 'docker'),
      Option(label: 'Logging', value: 'logging'),
    ],
    validator: (v) => v.isEmpty ? 'Select at least one feature' : null,
  );

  terminal.writeln();

  // 2. Multiselect with default values
  terminal.writeln('2. Target Platforms (with defaults):');
  Multiselect.send<String>(
    label: 'Platforms',
    options: [
      Option(label: 'iOS', value: 'ios'),
      Option(label: 'Android', value: 'android'),
      Option(label: 'Web', value: 'web'),
      Option(label: 'Windows', value: 'windows'),
      Option(label: 'macOS', value: 'macos'),
      Option(label: 'Linux', value: 'linux'),
    ],
  );
}
