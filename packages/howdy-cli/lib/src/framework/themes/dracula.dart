import 'package:howdy/src/framework/themes/theme.dart';
import 'package:howdy/src/terminal/text_style.dart';

const yellow = Color.draculaYellow;
const green = Color.draculaGreen;
const red = Color.draculaRed;
const foreground = Color.draculaForeground;
const background = Color.draculaBackground;

const draculaTheme = Theme(
  group: GroupStyles(
    title: TextStyle(foreground: Color.draculaPurple),
    description: TextStyle(foreground: Color.draculaComment),
  ),
  focused: FieldStyles(
    title: TextStyle(foreground: Color.draculaPurple),
    description: TextStyle(foreground: Color.draculaComment),
    errorIndicator: TextStyle(foreground: red),
    errorMessage: TextStyle(foreground: red),
    select: SelectStyles(
      selector: TextStyle(foreground: yellow),
      option: TextStyle(foreground: foreground),
    ),
    multiSelect: MultiSelectStyles(
      selector: TextStyle(foreground: yellow),
      selectedOption: TextStyle(foreground: green),
      selectedPrefix: TextStyle(foreground: green),
      unselectedOption: TextStyle(foreground: foreground),
      unselectedPrefix: TextStyle(foreground: Color.draculaComment),
    ),
    text: TextStyles(
      cursor: TextStyle(foreground: yellow),
      placeholder: TextStyle(foreground: Color.draculaComment),
      prompt: TextStyle(foreground: yellow),
    ),
    confirm: ConfirmStyles(
      focusedButton: TextStyle(
        foreground: yellow,
        background: Color.draculaPurple,
        bold: true,
      ),
      blurredButton: TextStyle(
        foreground: foreground,
        background: background,
      ),
    ),
  ),
  blurred: FieldStyles(
    base: TextStyle(dim: true),
    title: TextStyle(dim: true),
    description: TextStyle(dim: true),
    select: SelectStyles(
      selector: TextStyle(dim: true),
    ),
    multiSelect: MultiSelectStyles(
      selector: TextStyle(dim: true),
      selectedPrefix: TextStyle(dim: true),
      selectedOption: TextStyle(dim: true),
      unselectedPrefix: TextStyle(dim: true),
      unselectedOption: TextStyle(dim: true),
    ),
    text: TextStyles(
      prompt: TextStyle(dim: true),
      placeholder: TextStyle(dim: true),
    ),
  ),
  help: HelpStyles(
    shortKey: TextStyle(foreground: Color.draculaComment),
    shortDesc: TextStyle(foreground: Color.draculaSelection),
  ),
);
