import 'package:howdy/howdy.dart';

/// A collection of styles for components of the form.
class Theme {
  /// The active theme. Override to customize.
  static Theme current = Theme.charm();

  const Theme({
    this.form = const FormStyles(),
    this.group = const GroupStyles(),
    this.fieldSeparator = '\n\n',
    this.focused = const FieldStyles(),
    this.blurred = const FieldStyles(),
    this.help = const HelpStyles(),
  });

  final FormStyles form;
  final GroupStyles group;
  final String fieldSeparator;
  final FieldStyles focused;
  final FieldStyles blurred;
  final HelpStyles help;

  /// Returns a new base theme with general styles to be inherited by other themes.
  /// TODO: Not currently used
  factory Theme.base() {
    return const Theme(
      focused: FieldStyles(
        base: TextStyle(
          bold: false,
        ), // Placeholder for actual base logic if needed
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
          placeholder: TextStyle(dim: true, foreground: Color.grey),
          prompt: TextStyle(bold: true),
        ),
      ),
      blurred: FieldStyles(
        base: TextStyle(dim: true),
      ),
    );
  }

  /// ThemeCharm returns a new theme based on the Charm color scheme.
  factory Theme.charm() {
    const indigo = Color.purpleLight;
    const fuchsia = Color.magentaLight;
    const green = Color.greenLight;
    const red = Color.redLight;

    return Theme(
      form: const FormStyles(),
      group: const GroupStyles(
        title: TextStyle(foreground: indigo, bold: true),
        description: TextStyle(foreground: Color.white),
      ),
      focused: const FieldStyles(
        base: TextStyle(),
        title: TextStyle(foreground: indigo, bold: true),
        description: TextStyle(foreground: Color.greyLight, dim: true),
        errorIndicator: TextStyle(foreground: red),
        errorMessage: TextStyle(foreground: red),
        successMessage: TextStyle(foreground: green),
        warningMessage: TextStyle(foreground: Color.yellow),
        select: SelectStyles(
          selector: TextStyle(foreground: fuchsia),
          option: TextStyle(),
        ),
        multiSelect: MultiSelectStyles(
          selector: TextStyle(foreground: fuchsia),
          selectedOption: TextStyle(foreground: green),
          selectedPrefix: TextStyle(foreground: green),
          unselectedPrefix: TextStyle(dim: true),
        ),
        text: TextStyles(
          cursor: TextStyle(foreground: green),
          placeholder: TextStyle(foreground: Color.grey, dim: true),
          prompt: TextStyle(foreground: fuchsia),
        ),
        confirm: ConfirmStyles(
          focusedButton: TextStyle(
            foreground: Color.white,
            background: fuchsia,
          ),
          blurredButton: TextStyle(
            foreground: Color.white,
            background: Color.greyDark,
          ),
        ),
      ),
      blurred: FieldStyles(
        base: const TextStyle(dim: true),
        title: const TextStyle(dim: true),
        description: const TextStyle(dim: true),
        select: const SelectStyles(
          selector: TextStyle(dim: true),
        ),
        multiSelect: const MultiSelectStyles(
          selector: TextStyle(dim: true),
          selectedPrefix: TextStyle(dim: true),
          selectedOption: TextStyle(dim: true),
          unselectedPrefix: TextStyle(dim: true),
          unselectedOption: TextStyle(dim: true),
        ),
        text: TextStyles(
          prompt: const TextStyle(dim: true),
          placeholder: const TextStyle(dim: true),
        ),
      ),
      help: const HelpStyles(
        shortKey: TextStyle(foreground: Color.greyLight, dim: true),
        shortDesc: TextStyle(foreground: Color.grey, dim: true),
      ),
    );
  }

  /// A standard theme using base terminal colors. Maps to ThemeBase() in huh.
  factory Theme.standard() {
    return const Theme(
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
  }

  /// A theme based on the Dracula color scheme.
  factory Theme.dracula() {
    const purple = Color.draculaPurple;
    const yellow = Color.draculaYellow;
    const green = Color.draculaGreen;
    const red = Color.draculaRed;
    const comment = Color.draculaComment;
    const foreground = Color.draculaForeground;
    const background = Color.draculaBackground;

    return Theme(
      group: const GroupStyles(
        title: TextStyle(foreground: purple),
        description: TextStyle(foreground: comment),
      ),
      focused: const FieldStyles(
        title: TextStyle(foreground: purple),
        description: TextStyle(foreground: comment),
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
          unselectedPrefix: TextStyle(foreground: comment),
        ),
        text: TextStyles(
          cursor: TextStyle(foreground: yellow),
          placeholder: TextStyle(foreground: comment),
          prompt: TextStyle(foreground: yellow),
        ),
        confirm: ConfirmStyles(
          focusedButton: TextStyle(
            foreground: yellow,
            background: purple,
            bold: true,
          ),
          blurredButton: TextStyle(
            foreground: foreground,
            background: background,
          ),
        ),
      ),
      blurred: FieldStyles(
        base: const TextStyle(dim: true),
        title: const TextStyle(dim: true),
        description: const TextStyle(dim: true),
        select: const SelectStyles(
          selector: TextStyle(dim: true),
        ),
        multiSelect: const MultiSelectStyles(
          selector: TextStyle(dim: true),
          selectedPrefix: TextStyle(dim: true),
          selectedOption: TextStyle(dim: true),
          unselectedPrefix: TextStyle(dim: true),
          unselectedOption: TextStyle(dim: true),
        ),
        text: TextStyles(
          prompt: const TextStyle(dim: true),
          placeholder: const TextStyle(dim: true),
        ),
      ),
      help: const HelpStyles(
        shortKey: TextStyle(foreground: comment),
        shortDesc: TextStyle(foreground: Color.draculaSelection),
      ),
    );
  }

  /// A theme based on the base16 color scheme (standard 16-color ANSI palette).
  factory Theme.base16() {
    const cyan = Color.ansi6;
    const yellow = Color.ansi3;
    const green = Color.ansi2;
    const magenta = Color.ansi5;
    const red = Color.ansi9;
    const grey = Color.ansi8;
    const lightGrey = Color.ansi7;
    const black = Color.ansi0;

    return Theme(
      group: const GroupStyles(
        title: TextStyle(foreground: cyan),
        description: TextStyle(foreground: grey),
      ),
      focused: const FieldStyles(
        title: TextStyle(foreground: cyan),
        description: TextStyle(foreground: grey),
        errorIndicator: TextStyle(foreground: red),
        errorMessage: TextStyle(foreground: red),
        select: SelectStyles(
          selector: TextStyle(foreground: yellow),
          option: TextStyle(foreground: lightGrey),
        ),
        multiSelect: MultiSelectStyles(
          selector: TextStyle(foreground: yellow),
          selectedOption: TextStyle(foreground: green),
          selectedPrefix: TextStyle(foreground: green),
          unselectedOption: TextStyle(foreground: lightGrey),
        ),
        text: TextStyles(
          cursor: TextStyle(foreground: magenta),
          placeholder: TextStyle(foreground: grey),
          prompt: TextStyle(foreground: yellow),
        ),
        confirm: ConfirmStyles(
          focusedButton: TextStyle(
            foreground: lightGrey,
            background: magenta,
          ),
          blurredButton: TextStyle(
            foreground: lightGrey,
            background: black,
          ),
        ),
      ),
      blurred: FieldStyles(
        base: const TextStyle(dim: true),
        title: const TextStyle(foreground: grey),
        select: const SelectStyles(
          selector: TextStyle(dim: true),
        ),
        multiSelect: const MultiSelectStyles(
          selector: TextStyle(dim: true),
          selectedPrefix: TextStyle(dim: true),
          selectedOption: TextStyle(dim: true),
          unselectedPrefix: TextStyle(dim: true),
          unselectedOption: TextStyle(dim: true),
        ),
        text: TextStyles(
          prompt: const TextStyle(foreground: grey),
          text: const TextStyle(foreground: lightGrey),
          placeholder: const TextStyle(dim: true),
        ),
      ),
    );
  }

  /// A theme based on the Catppuccin Mocha color scheme.
  factory Theme.catppuccin() {
    const base = Color.catBase;
    const text = Color.catText;
    const subtext0 = Color.catSubtext0;
    const overlay0 = Color.catOverlay0;
    const overlay1 = Color.catOverlay1;
    const green = Color.catGreen;
    const red = Color.catRed;
    const pink = Color.catPink;
    const mauve = Color.catMauve;
    const rosewater = Color.catRosewater;

    return Theme(
      group: const GroupStyles(
        title: TextStyle(foreground: mauve),
        description: TextStyle(foreground: subtext0),
      ),
      focused: const FieldStyles(
        title: TextStyle(foreground: mauve),
        description: TextStyle(foreground: subtext0),
        errorIndicator: TextStyle(foreground: red),
        errorMessage: TextStyle(foreground: red),
        select: SelectStyles(
          selector: TextStyle(foreground: pink),
          option: TextStyle(foreground: text),
        ),
        multiSelect: MultiSelectStyles(
          selector: TextStyle(foreground: pink),
          selectedOption: TextStyle(foreground: green),
          selectedPrefix: TextStyle(foreground: green),
          unselectedOption: TextStyle(foreground: text),
          unselectedPrefix: TextStyle(foreground: text),
        ),
        text: TextStyles(
          cursor: TextStyle(foreground: rosewater),
          placeholder: TextStyle(foreground: overlay0),
          prompt: TextStyle(foreground: pink),
        ),
        confirm: ConfirmStyles(
          focusedButton: TextStyle(
            foreground: base,
            background: pink,
          ),
          blurredButton: TextStyle(
            foreground: text,
            background: base,
          ),
        ),
      ),
      blurred: FieldStyles(
        base: const TextStyle(dim: true),
        title: const TextStyle(dim: true),
        description: const TextStyle(dim: true),
        select: const SelectStyles(
          selector: TextStyle(dim: true),
        ),
        multiSelect: const MultiSelectStyles(
          selector: TextStyle(dim: true),
          selectedPrefix: TextStyle(dim: true),
          selectedOption: TextStyle(dim: true),
          unselectedPrefix: TextStyle(dim: true),
          unselectedOption: TextStyle(dim: true),
        ),
        text: TextStyles(
          prompt: const TextStyle(dim: true),
          placeholder: const TextStyle(dim: true),
        ),
      ),
      help: const HelpStyles(
        ellipsis: TextStyle(foreground: subtext0),
        shortKey: TextStyle(foreground: subtext0),
        shortDesc: TextStyle(foreground: overlay1),
        shortSeparator: TextStyle(foreground: subtext0),
        fullKey: TextStyle(foreground: subtext0),
        fullDesc: TextStyle(foreground: overlay1),
        fullSeparator: TextStyle(foreground: subtext0),
      ),
    );
  }

  /// The ❯ prompt pointer icon character.
  String get pointerIcon => Icon.pointer;
}

/// FormStyles are the styles for a form.
class FormStyles {
  const FormStyles({
    this.base = const TextStyle(),
  });
  final TextStyle base;
}

/// GroupStyles are the styles for a group.
class GroupStyles {
  const GroupStyles({
    this.base = const TextStyle(),
    this.title = const TextStyle(),
    this.description = const TextStyle(),
  });
  final TextStyle base;
  final TextStyle title;
  final TextStyle description;
}

/// FieldStyles are the styles for [Input]
class FieldStyles {
  const FieldStyles({
    this.base = const TextStyle(),
    this.title = const TextStyle(),
    this.description = const TextStyle(),
    this.errorIndicator = const TextStyle(),
    this.errorMessage = const TextStyle(),
    this.successMessage = const TextStyle(),
    this.warningMessage = const TextStyle(),
    this.select = const SelectStyles(),
    this.multiSelect = const MultiSelectStyles(),
    this.text = const TextStyles(),
    this.confirm = const ConfirmStyles(),
  });

  final TextStyle base;
  final TextStyle title;
  final TextStyle description;
  final TextStyle errorIndicator;
  final TextStyle errorMessage;
  final TextStyle successMessage;
  final TextStyle warningMessage;

  final SelectStyles select;
  final MultiSelectStyles multiSelect;
  final TextStyles text;
  final ConfirmStyles confirm;
}

/// SelectStyles are the styles for [Select], [MultiSelect], and [List].
class SelectStyles {
  const SelectStyles({
    this.selector = const TextStyle(),
    this.option = const TextStyle(),
    this.nextIndicator = const TextStyle(),
    this.prevIndicator = const TextStyle(),
  });

  final TextStyle selector;
  final TextStyle option;
  final TextStyle nextIndicator;
  final TextStyle prevIndicator;
}

/// MultiSelectStyles are the styles for multi-select fields.
class MultiSelectStyles {
  const MultiSelectStyles({
    this.selector = const TextStyle(),
    this.selectedOption = const TextStyle(),
    this.selectedPrefix = const TextStyle(),
    this.unselectedOption = const TextStyle(),
    this.unselectedPrefix = const TextStyle(),
  });

  final TextStyle selector;
  final TextStyle selectedOption;
  final TextStyle selectedPrefix;
  final TextStyle unselectedOption;
  final TextStyle unselectedPrefix;
}

/// TextStyles are the styles for text inputs.
class TextStyles {
  const TextStyles({
    this.cursor = const TextStyle(),
    this.cursorText = const TextStyle(),
    this.placeholder = const TextStyle(),
    this.prompt = const TextStyle(),
    this.text = const TextStyle(),
  });

  final TextStyle cursor;
  final TextStyle cursorText;
  final TextStyle placeholder;
  final TextStyle prompt;
  final TextStyle text;
}

/// ConfirmStyles are the styles for confirm fields.
class ConfirmStyles {
  const ConfirmStyles({
    this.focusedButton = const TextStyle(),
    this.blurredButton = const TextStyle(),
  });

  final TextStyle focusedButton;
  final TextStyle blurredButton;
}

/// HelpStyles are the styles for help/usage hints.
class HelpStyles {
  const HelpStyles({
    this.shortKey = const TextStyle(),
    this.shortDesc = const TextStyle(),
    this.shortSeparator = const TextStyle(),
    this.ellipsis = const TextStyle(),
    this.fullKey = const TextStyle(),
    this.fullDesc = const TextStyle(),
    this.fullSeparator = const TextStyle(),
  });

  final TextStyle shortKey;
  final TextStyle shortDesc;
  final TextStyle shortSeparator;
  final TextStyle ellipsis;
  final TextStyle fullKey;
  final TextStyle fullDesc;
  final TextStyle fullSeparator;
}

/// Build a styled usage hint string from (keys, action) pairs.
String usageHint(List<({String keys, String action})> parts) {
  final t = Theme.current;
  final dot = Icon.dot.style(t.help.shortSeparator);
  return parts
      .map(
        (p) =>
            '${p.keys.style(t.help.shortKey)} ${p.action.style(t.help.shortDesc)}',
      )
      .join(' $dot ');
}

/// TODO: Add more of these or remove altogether
extension Theming on String {
  String get label =>
      StyledText(this, style: Theme.current.focused.title).render();
  String get body =>
      StyledText(this, style: Theme.current.focused.base).render();
  String get defaultValue =>
      StyledText(this, style: Theme.current.focused.text.placeholder).render();
  String get error =>
      StyledText(this, style: Theme.current.focused.errorMessage).render();
  String get warning =>
      StyledText(this, style: Theme.current.focused.warningMessage).render();
  String get success =>
      StyledText(this, style: Theme.current.focused.successMessage).render();
  String get selected =>
      StyledText(this, style: Theme.current.focused.select.selector).render();
}
