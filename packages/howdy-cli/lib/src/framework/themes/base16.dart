import 'package:howdy/src/framework/themes/theme.dart';
import 'package:howdy/src/terminal/text_style.dart';

const _cyan = Color.ansi6;
const _yellow = Color.ansi3;
const _green = Color.ansi2;
const _magenta = Color.ansi5;
const _red = Color.ansi9;
const _grey = Color.ansi8;
const _lightGrey = Color.ansi7;
const _black = Color.ansi0;

const base16Theme = Theme(
  group: GroupStyles(
    title: TextStyle(foreground: _cyan),
    description: TextStyle(foreground: _grey),
  ),
  focused: FieldStyles(
    title: TextStyle(foreground: _cyan),
    description: TextStyle(foreground: _grey),
    errorIndicator: TextStyle(foreground: _red),
    errorMessage: TextStyle(foreground: _red),
    select: SelectStyles(
      selector: TextStyle(foreground: _yellow),
      option: TextStyle(foreground: _lightGrey),
    ),
    multiSelect: MultiSelectStyles(
      selector: TextStyle(foreground: _yellow),
      selectedOption: TextStyle(foreground: _green),
      selectedPrefix: TextStyle(foreground: _green),
      unselectedOption: TextStyle(foreground: _lightGrey),
    ),
    text: TextStyles(
      cursor: TextStyle(foreground: _magenta),
      placeholder: TextStyle(foreground: _grey),
      prompt: TextStyle(foreground: _yellow),
    ),
    confirm: ConfirmStyles(
      focusedButton: TextStyle(
        foreground: _lightGrey,
        background: _magenta,
      ),
      blurredButton: TextStyle(
        foreground: _lightGrey,
        background: _black,
      ),
    ),
  ),
  blurred: FieldStyles(
    base: TextStyle(dim: true),
    title: TextStyle(foreground: _grey),
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
      prompt: TextStyle(foreground: _grey),
      text: TextStyle(foreground: _lightGrey),
      placeholder: TextStyle(dim: true),
    ),
  ),
);
