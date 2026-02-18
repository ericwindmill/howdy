import 'package:howdy/howdy.dart';

class Theme {
  /// The active theme. Override to customize.
  static Theme current = Theme();
  const Theme({
    this.title = const TextStyle(
      bold: true,
      foreground: Color.purple,
    ),
    this.body = const TextStyle(),
    this.error = const TextStyle(foreground: Color.red),
    this.success = const TextStyle(foreground: Color.green),
    this.warning = const TextStyle(foreground: Color.yellow),
    this.label = const TextStyle(dim: true),
  });

  final TextStyle title;
  final TextStyle body;
  final TextStyle error;
  final TextStyle success;
  final TextStyle warning;
  final TextStyle label;
}

extension Theming on String {
  String get title => StyledText(this, style: Theme.current.title).render();
  String get body => StyledText(this, style: Theme.current.body).render();
  String get label => StyledText(this, style: Theme.current.label).render();
  String get error => StyledText(this, style: Theme.current.error).render();
  String get warning => StyledText(this, style: Theme.current.warning).render();
  String get success => StyledText(this, style: Theme.current.success).render();
}
