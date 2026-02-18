import 'package:howdy/howdy.dart';

class Theme {
  /// The active theme. Override to customize.
  static const Theme current = Theme();

  const Theme({
    /// Applied to the main prompt or message sent as part of a widget.
    this.label = const TextStyle(
      bold: true,
      foreground: Color.purpleLight,
    ),

    /// Applied to text within tables by default
    this.body = const TextStyle(),

    /// Applied to error strings by default
    this.defaultValue = const TextStyle(foreground: Color.grey, dim: true),

    /// The style applied to usage strings inside widgets
    this.usage = const TextStyle(dim: true),

    this.cursor = const TextStyle(),

    /// Applied to the currently selected/focused option in Select/Multiselect
    this.selected = const TextStyle(foreground: Color.cyan),

    /// Applied to error strings by default
    this.error = const TextStyle(foreground: Color.red),

    /// Applied to error strings by default
    this.success = const TextStyle(foreground: Color.green),

    /// Applied to warning strings by default
    this.warning = const TextStyle(foreground: Color.yellow),
  });

  final TextStyle label;
  final TextStyle body;
  final TextStyle error;
  final TextStyle success;
  final TextStyle warning;
  final TextStyle defaultValue;
  final TextStyle usage;
  final TextStyle cursor;
  final TextStyle selected;
}

extension Theming on String {
  String get label => StyledText(this, style: Theme.current.label).render();
  String get body => StyledText(this, style: Theme.current.body).render();
  String get usage => StyledText(this, style: Theme.current.label).render();
  String get defaultValue =>
      StyledText(this, style: Theme.current.label).render();
  String get error => StyledText(this, style: Theme.current.error).render();
  String get warning => StyledText(this, style: Theme.current.warning).render();
  String get success => StyledText(this, style: Theme.current.success).render();
  String get selected =>
      StyledText(this, style: Theme.current.selected).render();
}
