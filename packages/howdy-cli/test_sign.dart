import 'package:howdy/howdy.dart';

void main() {
  Sign.send(
    StyledText(
      'Hello Wide World! This is a very long text that ought to be folded around forty characters or so.',
    ).render(),
    width: 40,
  );
}
