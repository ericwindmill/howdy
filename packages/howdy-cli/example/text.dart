import 'package:howdy/howdy.dart';

void main() {
  terminal.writeln('Text demo\n');

  // Plain body
  Text.body('This is a plain body line.');

  // Semantic helpers
  Text.success('Build succeeded in 1.2s');
  Text.warning('pubspec.lock is out of date');
  Text.error('Could not resolve package:foo');

  // Custom style
  Text(
    'Deployment target: production',
    leading: '${Icon.pointer} ',
    style: TextStyle(foreground: Color.cyan, bold: true),
  ).write();

  // No trailing newline (inline)
  Text('Count: ', newline: false).write();
  Text('42', style: TextStyle(foreground: Color.yellow, bold: true)).write();
}
