import 'package:howdy/howdy.dart';

void main() {
  confirmInput();
}

void confirmInput() {
  terminal.writeln();
  terminal.eraseScreen();

  ConfirmInput(
    label: 'Are you sure?',
    help: 'Really?',
    defaultValue: true,
  ).write();

  terminal.writeln();

  ConfirmInput.send('REALLY?');

  ConfirmInput.send(
    'REALLY?',
    validator: (value) {
      if (value) {
        return 'Value must be false.';
      }

      return null;
    },
  );

  terminal.writeln();
  terminal.eraseScreen();

  Page.send([
    Text('HOWDY!'),
    ConfirmInput(label: 'You good?', help: "Tell us how you're doing."),
    Text('Good.'),
  ]);

  terminal.writeln();
  terminal.eraseScreen();
  Form.send(title: 'Greeter', [
    Page([
      Text('HOWDY!'),
      ConfirmInput(
        label: 'You good?',
        validator: (bool value) {
          if (!value) {
            return 'You must be good.';
          }
          return null;
        },
      ),
      Text('Good.'),
    ]),
    ConfirmInput(
      label: 'Do you want to exit?',
      help: "Yes to exit, no to stay.",
      validator: (bool value) {
        if (!value) {
          return 'Value must be true';
        }

        return null;
      },
    ),
  ]);
}

void confirmInputGroup() {}

void confirmInputForm() {}
