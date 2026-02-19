import 'dart:async';

import 'package:howdy/howdy.dart';

Future<void> main() async {
  terminal.writeln('SpinnerTask demo\n');

  // ── Successful task ───────────────────────────────────────────────────────
  final result = await SpinnerTask.send<String>(
    label: 'Fetching dependencies',
    task: () async {
      await Future.delayed(Duration(seconds: 2));
      return 'v2.4.1';
    },
  );
  Text.success('Resolved version $result');

  // ── Task that throws ──────────────────────────────────────────────────────
  try {
    await SpinnerTask.send<void>(
      label: 'Connecting to registry',
      task: () async {
        await Future.delayed(Duration(milliseconds: 800));
        throw Exception('connection refused');
      },
    );
  } catch (e) {
    Text.error('Failed: $e');
  }
}
