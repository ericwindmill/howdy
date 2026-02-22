import 'package:howdy/src/framework/themes/theme.dart';
import 'package:howdy/src/terminal/text_style.dart';

const _indigo = Color.purpleLight;
const _fuchsia = Color.magentaLight;
const _green = Color.greenLight;
const _red = Color.redLight;

const charmTheme = Theme(
  group: GroupStyles(
    title: TextStyle(foreground: _indigo, bold: true),
    description: TextStyle(foreground: Color.white),
  ),
  focused: FieldStyles(
    base: TextStyle(),
    title: TextStyle(foreground: _indigo, bold: true),
    description: TextStyle(foreground: Color.greyLight, dim: true),
    errorIndicator: TextStyle(foreground: _red),
    errorMessage: TextStyle(foreground: _red),
    successMessage: TextStyle(foreground: _green),
    warningMessage: TextStyle(foreground: Color.yellow),
    select: SelectStyles(
      selector: TextStyle(foreground: _fuchsia),
      option: TextStyle(),
    ),
    multiSelect: MultiSelectStyles(
      selector: TextStyle(foreground: _fuchsia),
      selectedOption: TextStyle(foreground: _green),
      selectedPrefix: TextStyle(foreground: _green),
      unselectedPrefix: TextStyle(dim: true),
    ),
    text: TextStyles(
      cursor: TextStyle(background: _indigo),
      placeholder: TextStyle(foreground: Color.grey, dim: true),
      prompt: TextStyle(foreground: _fuchsia),
    ),
    confirm: ConfirmStyles(
      focusedButton: TextStyle(
        foreground: Color.white,
        background: _fuchsia,
      ),
      blurredButton: TextStyle(
        foreground: Color.white,
        background: Color.greyDark,
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
    shortKey: TextStyle(foreground: Color.greyLight, dim: true),
    shortDesc: TextStyle(foreground: Color.grey, dim: true),
  ),
);
