import 'dart:io';

import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/wrap.dart';
import 'package:path/path.dart' as p;

void main() async {
  terminal.eraseScreen();
  terminal.cursorHome();

  final results = Form.send(title: 'Charmburger ordering', [
    Note(
      children: [
        Text(
          '\n🍔 Charmburger\n',
          style: TextStyle(
            bold: true,
            foreground: Color.cyan,
          ), // approximate to 212
        ),
        Text('Welcome to _Charmburger™_\n\nHow may we take your order?\n'),
      ],
      next: true,
    ),
    Page(
      children: [
        Select<String>(
          'Choose your burger',
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
          validator: (v) => v == 'Chickwich' ? 'no chicken today, sorry' : null,
          key: 'burger',
        ),
        Multiselect<String>(
          'Toppings',
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
      ],
    ),
    Page(
      children: [
        Select<String>(
          'Spice level',
          options: [
            Option(label: 'Mild', value: 'Mild'),
            Option(label: 'Medium-Spicy', value: 'Medium'),
            Option(label: 'Spicy-Hot', value: 'Hot'),
          ],
          defaultValue: 'Mild',
          key: 'spice',
        ),
        Select<String>(
          'Sides',
          help: 'You get one free side with this order.',
          options: [
            Option(label: 'Fries', value: 'Fries'),
            Option(label: 'Disco Fries', value: 'Disco Fries'),
            Option(label: 'R&B Fries', value: 'R&B Fries'),
            Option(label: 'Carrots', value: 'Carrots'),
          ],
          key: 'side',
        ),
      ],
    ),
    Page(
      children: [
        Prompt(
          "What's your name?",
          help: 'For when your order is ready.',
          defaultValue: 'Big Rick',
          validator: (v) =>
              v.toLowerCase() == 'frank' ? 'no franks, sorry' : null,
          key: 'name',
        ),
        Textarea(
          'Special Instructions',
          help: 'Anything we should know?',
          defaultValue: 'Danimal style?',
          key: 'instructions',
        ),
        ConfirmInput(
          'Would you like 15% off?',
          defaultValue: false,
          key: 'discount',
        ),
      ],
    ),
    Page(
      children: [
        FilePicker(
          'Where would like the burger delivered?',
          initialDirectory: '../',
          help: 'Please enter the relative directions to your burger storage.',
          key: 'location',
        ),
      ],
    ),
  ]);

  final receiptBuf = _buildReceipt(results);

  final delivered = await SpinnerTask<bool>(
    'Preparing your burger...',
    task: () async {
      await Future.delayed(Duration(seconds: 2));
      try {
        final location = results['location'] as FileSystemEntity;

        String? fullPath;
        if (location is File) {
          fullPath = p.join(location.parent.path, 'burger-receipt.md');
        } else if (location is Directory) {
          fullPath = p.join(location.path, 'burger-receipt.md');
        }
        if (fullPath != null) {
          final File f = File(fullPath);

          await SpinnerTask<void>(
            'Delivering your burger...',
            task: () async {
              await Future.delayed(Duration(seconds: 2));
              f.writeAsString(receiptBuf.toString().stripAnsi());
            },
          ).write();
        }
        return true;
      } catch (e) {
        rethrow;
      }
    },
  ).write();

  terminal.eraseScreen();
  terminal.cursorHome();

  Sign.send(
    receiptBuf.toString().trimRight(),
    borderType: BorderType.rounded,
    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
    margin: EdgeInsets.all(2),
    borderStyle: TextStyle(foreground: Color.purpleLight),
    width: 50,
  );

  if (delivered) Text.success("Burger delivered to ${results['location']}");
}

StringBuffer _buildReceipt(MultiWidgetResults results) {
  final receiptBuf = StringBuffer();
  final burger = results['burger'] as String;
  final toppings = results['toppings'] as List<String>;
  final spice = results['spice'] as String;
  final side = results['side'] as String;
  final name = results['name'] as String;
  final instructions = results['instructions'] as String;
  final discount = results['discount'] as bool;
  final location = results['location'] as FileSystemEntity;

  // Draw bordered box
  String keyword(String s) =>
      StyledText(s, style: TextStyle(foreground: Color.cyan)).render();

  receiptBuf.writeln(
    StyledText('BURGER RECEIPT', style: TextStyle(bold: true)).render(),
  );
  receiptBuf.writeln();
  receiptBuf.writeln(
    'One ${keyword(spice)} ${keyword(burger)}, topped with ${keyword(toppings.join(', '))} with ${keyword(side)} on the side.',
  );
  receiptBuf.writeln();
  receiptBuf.writeln(
    'Thanks for your order${name.isNotEmpty ? ', $name' : ''}!',
  );

  receiptBuf.writeln();
  receiptBuf.writeln('Instructions:');
  receiptBuf.writeln('${Icon.dot} ${keyword(instructions)}');
  receiptBuf.writeln('${Icon.dot} Delivered to ${keyword(location.path)}');

  if (discount) {
    receiptBuf.writeln('Enjoy 15% off.');
  } else {
    receiptBuf.writeln("You didn't take the 15% off?");
  }

  return receiptBuf;
}
