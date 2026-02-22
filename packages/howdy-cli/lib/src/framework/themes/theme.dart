import 'package:howdy/howdy.dart';
import 'package:howdy/src/framework/themes/base16.dart';
import 'package:howdy/src/framework/themes/catppuccin.dart';
import 'package:howdy/src/framework/themes/charm.dart';
import 'package:howdy/src/framework/themes/dracula.dart';
import 'package:howdy/src/framework/themes/standard.dart';

/// A collection of styles for components of the form.
class Theme {
  /// The active theme. Override to customize.
  static Theme current = Theme.charm();

  const Theme({
    this.form = const FormStyles(),
    this.group = const GroupStyles(),
    this.focused = const FieldStyles(),
    this.blurred = const FieldStyles(),
    this.help = const HelpStyles(),
  });

  /// Styles for forms
  final FormStyles form;
  final GroupStyles group;

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

  factory Theme.standard() => standardTheme;

  /// ThemeCharm returns a new theme based on the Charm color scheme.
  factory Theme.charm() => charmTheme;

  /// A theme based on the Dracula color scheme.
  factory Theme.dracula() => draculaTheme;

  /// A theme based on the base16 color scheme (standard 16-color ANSI palette).
  factory Theme.base16() => base16Theme;

  /// A theme based on the Catppuccin Mocha color scheme.
  factory Theme.catppuccin() => catppuccinTheme;

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
