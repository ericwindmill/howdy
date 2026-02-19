import 'package:howdy/howdy.dart';

void main() {
  terminal.writeln('Table demo\n');

  // ── Auto-sized (default) ───────────────────────────────────────────────────
  terminal.writeln('Auto-sized:');
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

  terminal.writeln();

  // ── Per-column widths ─────────────────────────────────────────────────────
  terminal.writeln('columnWidths: [20, 12, 10]:');
  Table(
    headers: ['Service', 'Status', 'Uptime'],
    rows: [
      ['auth-service', 'running', '14d 3h'],
      ['db-worker', 'stopped', '—'],
    ],
    columnWidths: [20, 12, 10],
  ).write();

  terminal.writeln();

  // ── Fixed total width ─────────────────────────────────────────────────────
  terminal.writeln('totalWidth: 60 (columns share evenly):');
  Table(
    headers: ['Setting', 'Value'],
    rows: [
      ['Project name', 'my-app'],
      ['Language', 'Dart'],
      ['Git', 'yes'],
    ],
    totalWidth: 60,
    columnAlignments: [ColumnAlignment.left, ColumnAlignment.right],
  ).write();
}
