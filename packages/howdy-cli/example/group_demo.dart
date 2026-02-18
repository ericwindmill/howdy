import 'package:howdy/howdy.dart';

/// Demonstrates the Group widget with validation.
///
/// Run: dart run example/group_demo.dart
void main() {
  Text(
    '\n📋 Project Setup (Group Demo)\n',
    style: TextStyle(bold: true, foreground: Color.cyan),
  ).write();

  Text.body(
    'All fields are shown together. '
    'Use Tab/Enter to advance, Shift+Tab to go back.\n',
  );

  final results = Group.send([
    Prompt(
      label: 'Project name',
      defaultValue: 'my_app',
      validator: (value) {
        if (value.isEmpty) return 'Name is required';
        if (value.contains(' ')) return 'Name cannot contain spaces';
        return null;
      },
      key: 'name',
    ),
    Select<String>(
      label: 'Language',
      options: [
        Option(label: 'Dart', value: 'dart'),
        Option(label: 'TypeScript', value: 'ts'),
        Option(label: 'Python', value: 'python'),
      ],
      key: 'lang',
    ),
    Multiselect<String>(
      label: 'Features',
      options: [
        Option(label: 'Linting', value: 'lint'),
        Option(label: 'Testing', value: 'test'),
        Option(label: 'CI/CD', value: 'ci'),
        Option(label: 'Docker', value: 'docker'),
      ],
      validator: (selected) {
        if (selected.isEmpty) return 'Select at least one feature';
        return null;
      },
      key: 'features',
    ),
    ConfirmInput(label: 'Initialize git?', defaultValue: true, key: 'git'),
  ]);

  final name = results['name'] as String;
  final lang = results['lang'] as String;
  final features = results['features'] as List<String>;
  final useGit = results['git'] as bool;

  print('');
  Table.send(
    headers: ['Setting', 'Value'],
    rows: [
      ['Project', name],
      ['Language', lang],
      ['Features', features.isEmpty ? '(none)' : features.join(', ')],
      [
        'Git',
        useGit
            ? StyledText('yes', style: TextStyle(foreground: Color.green))
            : StyledText('no', style: TextStyle(foreground: Color.red)),
      ],
    ],
  );

  print('');
  Text.success('Done!');
}
