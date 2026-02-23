import 'dart:async';

import 'package:howdy/howdy.dart';

Future<void> main() async {
  terminal.eraseScreen();
  terminal.cursorHome();

  Text.body('SpinnerTask example');
  Text.body('-----------------------');
  terminal.writeln();

  final version = await SpinnerTask.send<String>(
    label: 'Fetching dependencies',
    task: () async {
      await Future.delayed(Duration(seconds: 2));
      return 'v2.4.1';
    },
  );

  Text.body('Downloaded version $version');
}
