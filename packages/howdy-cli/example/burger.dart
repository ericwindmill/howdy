import 'package:howdy/howdy.dart';

void main() async {
  terminal.eraseScreen();
  terminal.cursorHome();

  final results = Form.send([
    Note([
      Text(
        '\n🍔 Charmburger\n',
        style: TextStyle(
          bold: true,
          foreground: Color.cyan,
        ), // approximate to 212
      ),
      Text('Welcome to _Charmburger™_\n\nHow may we take your order?\n'),
    ], next: true),
    Page([
      Select<String>(
        label: 'Choose your burger',
        help: 'At Charm we truly have a burger for everyone.',
        options: [
          Option(label: 'Charmburger Classic', value: 'Charmburger Classic'),
          Option(label: 'Chickwich', value: 'Chickwich'),
          Option(label: 'Fishburger', value: 'Fishburger'),
          Option(
            label: 'Charmpossible™ Burger',
            value: 'Charmpossible™ Burger',
          ),
        ],
        validator: (v) => v == 'Fishburger' ? 'no fish today, sorry' : null,
        key: 'burger',
      ),
      Multiselect<String>(
        label: 'Toppings',
        help: 'Choose up to 4.',
        options: [
          Option(label: 'Lettuce', value: 'Lettuce'),
          Option(label: 'Tomatoes', value: 'Tomatoes'),
          Option(label: 'Charm Sauce', value: 'Charm Sauce'),
          Option(label: 'Jalapeños', value: 'Jalapeños'),
          Option(label: 'Cheese', value: 'Cheese'),
          Option(label: 'Vegan Cheese', value: 'Vegan Cheese'),
          Option(label: 'Nutella', value: 'Nutella'),
        ],
        defaultValue: ['Lettuce', 'Tomatoes'],
        validator: (v) {
          if (v.isEmpty) return 'at least one topping is required';
          if (v.length > 4) return 'Maximum 4 toppings allowed';
          return null;
        },
        key: 'toppings',
      ),
    ]),
    Page([
      Select<String>(
        label: 'Spice level',
        options: [
          Option(label: 'Mild', value: 'Mild'),
          Option(label: 'Medium-Spicy', value: 'Medium'),
          Option(label: 'Spicy-Hot', value: 'Hot'),
        ],
        defaultValue: 'Mild',
        key: 'spice',
      ),
      Select<String>(
        label: 'Sides',
        help: 'You get one free side with this order.',
        options: [
          Option(label: 'Fries', value: 'Fries'),
          Option(label: 'Disco Fries', value: 'Disco Fries'),
          Option(label: 'R&B Fries', value: 'R&B Fries'),
          Option(label: 'Carrots', value: 'Carrots'),
        ],
        key: 'side',
      ),
    ]),
    Page([
      Prompt(
        label: "What's your name?",
        help: 'For when your order is ready.',
        defaultValue: 'Margaret Thatcher',
        validator: (v) =>
            v.toLowerCase() == 'frank' ? 'no franks, sorry' : null,
        key: 'name',
      ),
      Textarea(
        label: 'Special Instructions',
        help: 'Anything we should know?',
        defaultValue: 'Just put it in the mailbox please',
        key: 'instructions',
      ),
      ConfirmInput(
        label: 'Would you like 15% off?',
        defaultValue: false,
        key: 'discount',
      ),
    ]),
  ]);

  await SpinnerTask.send<void>(
    label: 'Preparing your burger...',
    task: () async => await Future.delayed(Duration(seconds: 2)),
  );

  final burger = results['burger'] as String;
  final toppings = results['toppings'] as List<String>;
  final spice = results['spice'] as String;
  final side = results['side'] as String;
  final name = results['name'] as String;
  final instructions = results['instructions'] as String;
  final discount = results['discount'] as bool;

  // Draw bordered box
  String keyword(String s) =>
      StyledText(s, style: TextStyle(foreground: Color.cyan)).render();

  terminal.eraseScreen();
  terminal.cursorHome();

  final receiptBuf = StringBuffer();
  receiptBuf.writeln(
    StyledText('BURGER RECEIPT', style: TextStyle(bold: true)).render(),
  );
  receiptBuf.writeln();
  receiptBuf.writeln(
    'One ${keyword(spice)} ${keyword(burger)}, topped with ${keyword(toppings.join(', '))} with ${keyword(side)} on the side.',
  );
  receiptBuf.writeln(
    'Thanks for your order${name.isNotEmpty ? ', $name' : ''}!',
  );
  if (instructions.isNotEmpty) {
    receiptBuf.writeln('Instructions: ${keyword(instructions)}');
  }
  if (discount) {
    receiptBuf.writeln('Enjoy 15% off.');
  }

  Sign.send(
    receiptBuf.toString().trimRight(),
    borderType: BorderType.rounded,
    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
    borderStyle: TextStyle(foreground: Color.purpleLight),
    width: 40,
  );
}
