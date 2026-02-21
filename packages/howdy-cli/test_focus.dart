import 'package:howdy/howdy.dart';

void main() {
  final note = Note([Text('Hello')], next: true);
  print('Focus Index: ${note.focusIndex}');
  print('Widget count: ${note.children.length}');
}
