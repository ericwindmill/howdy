import 'package:howdy/howdy.dart';

/// Showcases every howdy widget in a realistic "create project" flow.
void main() async {
  // ── Text ──────────────────────────────────────────────
  Text(
    '\n🎉 Welcome to the Howdy CLI Demo!\n',
    style: TextStyle(bold: true, foreground: Color.cyan),
  ).write();

  Text.body('This example walks through every widget in the library.');
  Text.warning('Some widgets require keyboard input.');
  print('');

  // ── Prompt ────────────────────────────────────────────
  final projectName = Prompt.send('Project name', defaultValue: 'my_app');

  // ── ConfirmInput ──────────────────────────────────────
  final useGit = ConfirmInput.send(
    'Initialize a git repository?',
    defaultValue: true,
  );

  // ── Select ────────────────────────────────────────────
  final language = Select.send<String>(
    label: 'Pick a language',
    options: [
      Option(label: 'Dart', value: 'dart'),
      Option(label: 'TypeScript', value: 'ts'),
      Option(label: 'Python', value: 'python'),
      Option(label: 'Go', value: 'go'),
    ],
  );

  // ── Multiselect ───────────────────────────────────────
  final features = Multiselect.send<String>(
    label: 'Select features to enable',
    options: [
      Option(label: 'Linting', value: 'lint'),
      Option(label: 'Testing', value: 'test'),
      Option(label: 'CI/CD', value: 'ci'),
      Option(label: 'Docker', value: 'docker'),
    ],
  );

  // ── SpinnerTask ───────────────────────────────────────
  await SpinnerTask.send<void>(
    label: 'Creating project files...',
    task: () => Future.delayed(Duration(seconds: 1)),
  );

  await SpinnerTask.send<void>(
    label: 'Installing dependencies...',
    task: () => Future.delayed(Duration(milliseconds: 1500)),
  );

  if (useGit) {
    await SpinnerTask.send<void>(
      label: 'Initializing git repository...',
      task: () => Future.delayed(Duration(milliseconds: 800)),
    );
  }

  // ── Table ─────────────────────────────────────────────
  print('');
  Text.body('Project summary:');
  print('');

  Table.send(
    headers: ['Setting', 'Value'],
    rows: [
      ['Project', projectName],
      ['Language', language],
      [
        'Features',
        StyledText(
          features.isEmpty ? '(none)' : features.join(', '),
          style: TextStyle(foreground: Color.cyan),
        ),
      ],
      [
        'Git',
        useGit
            ? StyledText('yes', style: TextStyle(foreground: Color.green))
            : StyledText('no', style: TextStyle(foreground: Color.red)),
      ],
    ],
  );

  print('');
  Text.success('Project "$projectName" created successfully!');
}
