import 'package:howdy/howdy.dart';

class Theme {
  /// The active theme. Override to customize.
  static const Theme current = Theme();

  const Theme({
    /// Applied to the main prompt or message sent as part of a widget.
    this.label = const TextStyle(bold: true, foreground: Color.purpleLight),

    /// Applied to text within tables by default
    this.body = const TextStyle(),

    /// Applied to default / placeholder values
    this.defaultValue = const TextStyle(foreground: Color.grey, dim: true),

    /// The style applied to usage key glyphs (← / → etc.)
    this.usageKey = const TextStyle(foreground: Color.greyLight),

    /// The style applied to usage action words (select, submit etc.)
    this.usageAction = const TextStyle(foreground: Color.grey, dim: true),

    /// The style applied to the ❯ prompt pointer icon
    this.pointer = const TextStyle(),

    /// Applied to the currently selected/focused option in Select/Multiselect
    this.selected = const TextStyle(foreground: Color.cyan),

    /// Applied to error strings
    this.error = const TextStyle(foreground: Color.red),

    /// Applied to success strings
    this.success = const TextStyle(foreground: Color.green),

    /// Applied to warning strings
    this.warning = const TextStyle(foreground: Color.yellow),

    /// The ❯ prompt pointer icon character. Override to change the glyph.
    this.pointerIcon = Icon.pointer,

    /// Form title text style.
    this.formTitle = const TextStyle(foreground: Color.greyLight),

    /// Left border style for the focused widget in a Form.
    this.focusedBorder = const TextStyle(foreground: Color.white),

    /// Left border style for unfocused widgets in a Form.
    this.unfocusedBorder = const TextStyle(dim: true),

    /// Optional maximum width for the terminal output. If set, content will wrap at this point.
    this.maxWidth,
  });

  /// Optional maximum width for the terminal output.
  final int? maxWidth;

  final TextStyle label;
  final TextStyle body;
  final TextStyle error;
  final TextStyle success;
  final TextStyle warning;
  final TextStyle defaultValue;
  final TextStyle usageKey;
  final TextStyle usageAction;
  final TextStyle pointer;
  final TextStyle selected;
  final TextStyle formTitle;
  final TextStyle focusedBorder;
  final TextStyle unfocusedBorder;

  /// The ❯ prompt pointer icon character.
  final String pointerIcon;
}

/// Build a styled usage hint string from (keys, action) pairs.
///
/// Each pair renders as `[key styled grey-light] [action styled grey-dim]`,
/// joined by a mid-dot separator.
///
/// ```dart
/// usageHint([
///   (keys: '${Icon.arrowLeft} / ${Icon.arrowRight}', action: 'select'),
///   (keys: 'enter', action: 'submit'),
/// ]);
/// ```
String usageHint(List<({String keys, String action})> parts) {
  final t = Theme.current;
  final dot = Icon.dot.style(t.usageAction);
  return parts
      .map(
        (p) => '${p.keys.style(t.usageKey)} ${p.action.style(t.usageAction)}',
      )
      .join('  $dot  ');
}

extension Theming on String {
  String get label => StyledText(this, style: Theme.current.label).render();
  String get body => StyledText(this, style: Theme.current.body).render();
  String get defaultValue =>
      StyledText(this, style: Theme.current.defaultValue).render();
  String get error => StyledText(this, style: Theme.current.error).render();
  String get warning => StyledText(this, style: Theme.current.warning).render();
  String get success => StyledText(this, style: Theme.current.success).render();
  String get selected =>
      StyledText(this, style: Theme.current.selected).render();
}
