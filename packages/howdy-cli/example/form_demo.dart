import 'package:howdy/howdy.dart';

/// Demonstrates the Form widget — a multi-page form.
///
/// Run: dart run example/form_demo.dart
void main() {
  Theme.current = Theme.standard();

  Text(
    '\n🧙 Project Wizard (Form Demo)\n',
    style: TextStyle(bold: true, foreground: Color.magenta),
  ).write();

  final results = Form.send([
    // Page 1: Basics
    Group([
      Prompt(
        label: 'Project name',
        validator: (v) => v.isEmpty ? 'Name is required' : null,
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
    ]),

    // Page 2: Configuration
    Group([
      Multiselect<String>(
        label: 'Features',
        options: [
          Option(label: 'Linting', value: 'lint'),
          Option(label: 'Testing', value: 'test'),
          Option(label: 'CI/CD', value: 'ci'),
          Option(label: 'Docker', value: 'docker'),
        ],
        validator: (v) => v.isEmpty ? 'Select at least one' : null,
        key: 'features',
      ),
      ConfirmInput(label: 'Initialize git?', defaultValue: true, key: 'git'),
    ]),
  ], title: 'Create Project');

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
      ['Features', features.join(', ')],
      [
        'Git',
        useGit
            ? StyledText('yes', style: TextStyle(foreground: Color.green))
            : StyledText('no', style: TextStyle(foreground: Color.red)),
      ],
    ],
  );

  print('');
  Text.success('Project "$name" created successfully!');

  terminal.writeln();
  terminal.eraseScreen();

  // 2. A single-page form
  Text(
    '\n🧙 Quick Survey (Form Demo 2)\n',
    style: TextStyle(bold: true, foreground: Color.magenta),
  ).write();

  final surveyResults = Form.send(title: 'Survey', [
    Group([
      Prompt(
        label: 'How did you hear about us?',
        key: 'source',
      ),
      ConfirmInput(
        label: 'Subscribe to newsletter?',
        defaultValue: false,
        key: 'newsletter',
      ),
    ]),
  ]);

  print('');
  if (surveyResults['newsletter'] == true) {
    Text.success('Thanks for subscribing!');
  } else {
    Text.success('Survey completed.');
  }
}
