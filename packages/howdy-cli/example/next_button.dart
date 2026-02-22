import 'package:howdy/howdy.dart';

void main() {
  terminal.eraseScreen();
  terminal.cursorHome();

  Form.send([
    Page([
      Text('''   ____  _   _ ______ 
  / __ \\| \\ | |  ____|
 | |  | |  \\| | |__   
 | |  | | . ` |  __|  
 | |__| | |\\  | |____ 
  \\____/|_| \\_|______|
'''),
      NextButton('Continue'),
    ]),
    Page([
      Text(r'''  _                 
 | |                
 | |___      _____  
 | __\ \ /\ / / _ \ 
 | |_ \ V  V / (_) |
  \__| \_/\_/ \___/                
'''),
    ]),
  ], title: 'Form next button');
}
