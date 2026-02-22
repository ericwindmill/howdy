import 'package:howdy/src/framework/themes/theme.dart';
import 'package:howdy/src/terminal/text_style.dart';

/// A standard theme using base terminal colors. Maps to ThemeBase() in huh.
///  Theme.standard() {
const standardTheme = Theme(
  focused: FieldStyles(
    errorIndicator: TextStyle(foreground: Color.red),
    errorMessage: TextStyle(foreground: Color.red),
    select: SelectStyles(
      selector: TextStyle(foreground: Color.purpleLight),
    ),
    multiSelect: MultiSelectStyles(
      selector: TextStyle(foreground: Color.purpleLight),
      selectedPrefix: TextStyle(foreground: Color.green),
      unselectedPrefix: TextStyle(dim: true),
    ),
    text: TextStyles(
      placeholder: TextStyle(foreground: Color.grey, dim: true),
    ),
    confirm: ConfirmStyles(
      focusedButton: TextStyle(
        foreground: Color.black,
        background: Color.white,
      ),
      blurredButton: TextStyle(
        foreground: Color.white,
        background: Color.black,
      ),
    ),
  ),
  blurred: FieldStyles(
    base: TextStyle(dim: true),
    title: TextStyle(dim: true),
    multiSelect: MultiSelectStyles(
      selector: TextStyle(dim: true),
      selectedPrefix: TextStyle(dim: true),
      selectedOption: TextStyle(dim: true),
      unselectedPrefix: TextStyle(dim: true),
      unselectedOption: TextStyle(dim: true),
    ),
  ),
);
