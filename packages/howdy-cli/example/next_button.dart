import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Form.send(
    title: 'Form next button',
    children: [
      Page(
        children: [
          Text('''   ____  _   _ ______ 
  / __ \\| \\ | |  ____|
 | |  | |  \\| | |__   
 | |  | | . ` |  __|  
 | |__| | |\\  | |____ 
  \\____/|_| \\_|______|
'''),
          NextButton('Continue'),
        ],
      ),
      Page(
        children: [
          Text(r'''  _                 
 | |                
 | |___      _____  
 | __\ \ /\ / / _ \ 
 | |_ \ V  V / (_) |
  \__| \_/\_/ \___/                
'''),
        ],
      ),
    ],
  );
}
