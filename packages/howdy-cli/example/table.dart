import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('Table example');
  Text.body('-----------------------');
  terminal.writeln();
  terminal.writeln();

  Table(
    headers: ['Service', 'Status', 'Uptime'],
    rows: [
      [
        'auth-service',
        StyledText('running', style: TextStyle(foreground: Color.green)),
        '14d 3h',
      ],
      [
        'db-worker',
        StyledText('stopped', style: TextStyle(foreground: Color.red)),
        '—',
      ],
      [
        'cache',
        StyledText('running', style: TextStyle(foreground: Color.green)),
        '6h 12m',
      ],
    ],
  ).write();
}
