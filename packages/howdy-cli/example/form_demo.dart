import 'package:howdy/howdy.dart';

/// Demonstrates the Form widget — a multi-page form.
///
/// Run: dart run example/form_demo.dart
void main() async {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text(
    '\n🧙 Project Wizard (Form Demo)\n',
    style: TextStyle(bold: true, foreground: Color.magenta),
  ).write();

  final results = Form.send([
    // Page 1: Basics
    Page(
      children: [
        Prompt(
          'Project name',
          validator: (v) => v.isEmpty ? 'Name is required' : null,
          key: 'name',
        ),
        Select<String>(
          'Language',
          options: [
            Option(label: 'Dart', value: 'dart'),
            Option(label: 'TypeScript', value: 'ts'),
            Option(label: 'Python', value: 'python'),
          ],
          key: 'lang',
        ),
      ],
    ),

    // Page 2: Configuration
    Page(
      children: [
        Multiselect<String>(
          'Features',
          options: [
            Option(label: 'Linting', value: 'lint'),
            Option(label: 'Testing', value: 'test'),
            Option(label: 'CI/CD', value: 'ci'),
            Option(label: 'Docker', value: 'docker'),
          ],
          validator: (v) => v.isEmpty ? 'Select at least one' : null,
          key: 'features',
        ),
        ConfirmInput('Initialize git?', defaultValue: true, key: 'git'),
      ],
    ),
  ], title: 'Create Project');

  final name = results['name'] as String;

  // ── Successful task ───────────────────────────────────────────────────────
  await SpinnerTask.send<String>(
    'Creating project...',
    task: () async {
      await Future.delayed(Duration(seconds: 2));
      return 'v2.4.1';
    },
  );

  await SpinnerTask.send<String>(
    'Initializing dependendencies...',
    task: () async {
      await Future.delayed(Duration(seconds: 1));
      return 'v2.4.1';
    },
  );

  await SpinnerTask.send<String>(
    'Tinkering....',
    task: () async {
      await Future.delayed(Duration(seconds: 1));
      return 'v2.4.1';
    },
  );

  Text.success('Project "$name" created successfully!');
}
