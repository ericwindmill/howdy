import 'package:howdy/src/framework/themes/theme.dart';
import 'package:howdy/src/terminal/text_style.dart';

const _base = Color.catBase;
const _text = Color.catText;
const _subtext0 = Color.catSubtext0;
const _overlay0 = Color.catOverlay0;
const _overlay1 = Color.catOverlay1;
const _green = Color.catGreen;
const _red = Color.catRed;
const _pink = Color.catPink;
const _mauve = Color.catMauve;
const _rosewater = Color.catRosewater;

const catppuccinTheme = Theme(
  group: GroupStyles(
    title: TextStyle(foreground: _mauve),
    description: TextStyle(foreground: _subtext0),
  ),
  focused: FieldStyles(
    title: TextStyle(foreground: _mauve),
    description: TextStyle(foreground: _subtext0),
    errorIndicator: TextStyle(foreground: _red),
    errorMessage: TextStyle(foreground: _red),
    select: SelectStyles(
      selector: TextStyle(foreground: _pink),
      option: TextStyle(foreground: _text),
    ),
    multiSelect: MultiSelectStyles(
      selector: TextStyle(foreground: _pink),
      selectedOption: TextStyle(foreground: _green),
      selectedPrefix: TextStyle(foreground: _green),
      unselectedOption: TextStyle(foreground: _text),
      unselectedPrefix: TextStyle(foreground: _text),
    ),
    text: TextStyles(
      cursor: TextStyle(foreground: _rosewater),
      placeholder: TextStyle(foreground: _overlay0),
      prompt: TextStyle(foreground: _pink),
    ),
    confirm: ConfirmStyles(
      focusedButton: TextStyle(
        foreground: _base,
        background: _pink,
      ),
      blurredButton: TextStyle(
        foreground: _text,
        background: _base,
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
    ellipsis: TextStyle(foreground: _subtext0),
    shortKey: TextStyle(foreground: _subtext0),
    shortDesc: TextStyle(foreground: _overlay1),
    shortSeparator: TextStyle(foreground: _subtext0),
    fullKey: TextStyle(foreground: _subtext0),
    fullDesc: TextStyle(foreground: _overlay1),
    fullSeparator: TextStyle(foreground: _subtext0),
  ),
);
