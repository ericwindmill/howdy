import 'package:howdy/howdy.dart';

void main(List<String> args) {
  Multiselect<String>(
    label: 'Features',
    options: [
      Option(label: 'Linting', value: 'lint'),
      Option(label: 'Testing', value: 'test'),
      Option(label: 'CI/CD', value: 'ci'),
      Option(label: 'Docker', value: 'docker'),
      Option(label: 'Logging', value: 'logging'),
      Option(label: 'Crash Reporting', value: 'crash'),
      Option(label: 'Storage', value: 'storage'),
      Option(label: 'A home for all the cats', value: 'cats'),
    ],
    validator: (v) => v.isEmpty ? 'Select at least one' : null,
    key: 'features',
  ).write();
}
