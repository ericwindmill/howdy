import 'package:howdy/howdy.dart';

/// Demonstrates the Form widget — a multi-page form.
///
/// Run: dart run example/form_demo.dart
void main() {
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
      ),
      Select<String>(
        label: 'Language',
        options: [
          Option(label: 'Dart', value: 'dart'),
          Option(label: 'TypeScript', value: 'ts'),
          Option(label: 'Python', value: 'python'),
        ],
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
      ),
      ConfirmInput(label: 'Initialize git?', defaultValue: true),
    ]),
  ], title: 'Create Project');

  final page1 = results[0];
  final page2 = results[1];

  final name = page1[0] as String;
  final lang = page1[1] as String;
  final features = page2[0] as List<String>;
  final useGit = page2[1] as bool;

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
}
