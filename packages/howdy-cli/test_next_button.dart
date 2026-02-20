import 'package:howdy/howdy.dart';

void main() {
  final btn = NextButton(label: 'Next');
  btn.isFocused = true;
  print("Rendered: ${btn.render().replaceAll('\x1b', '\\x1b')}");
}
