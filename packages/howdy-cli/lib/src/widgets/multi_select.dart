import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/theme.dart';

/// A multi-choice select list.
///
/// Arrow keys navigate, Space toggles, Enter confirms.
///
///```txt
/// Pick features  (space to toggle, enter to confirm)
///   ❯ ◉ Linting
///     ◯ Testing
///     ◯ CI/CD
///```
///
/// ```dart
/// final features = Multiselect.send<String>(
///   label: 'Pick features',
///   options: [
///     Option(label: 'Linting', value: 'lint'),
///     Option(label: 'Testing', value: 'test'),
///   ],
/// );
/// ```
class Multiselect<T> extends InteractiveWidget<List<T>> {
  Multiselect({
    required super.label,
    required this.options,
    super.help,
    super.validator,
    TextStyle? labelStyle,
    TextStyle? helpStyle,
    TextStyle? selectedStyle,
    TextStyle? optionStyle,
    TextStyle? successStyle,
    TextStyle? errorStyle,
  }) : labelStyle = labelStyle ?? Theme.current.title,
       helpStyle = helpStyle ?? Theme.current.label,
       selectedStyle = selectedStyle ?? const TextStyle(foreground: Color.cyan),
       optionStyle = optionStyle ?? Theme.current.body,
       successStyle = successStyle ?? Theme.current.success,
       errorStyle = errorStyle ?? Theme.current.error {
    selected = List<bool>.filled(options.length, false);
  }

  final List<Option<T>> options;
  late final List<bool> selected;

  final TextStyle labelStyle;
  final TextStyle helpStyle;
  final TextStyle selectedStyle;
  final TextStyle optionStyle;
  final TextStyle successStyle;
  final TextStyle errorStyle;

  int selectedIndex = 0;
  bool _isDone = false;
  String? _error;

  /// Convenience factory, uses active theme values.
  static List<T> send<T>({
    required String label,
    required List<Option<T>> options,
    String? description,
    Validator<List<T>>? validator,
  }) {
    return Multiselect<T>(
      label: label,
      options: options,
      help: description,
      validator: validator,
    ).write();
  }

  /// Build the option list string.
  String renderOptionsString() {
    final buf = StringBuffer();
    for (var i = 0; i < options.length; i++) {
      final isCursor = i == selectedIndex;
      final isChecked = selected[i];
      final marker = isChecked ? Icon.optionFilled : Icon.optionEmpty;
      final prefix = isCursor ? '${Icon.cursor} ' : '  ';

      if (isCursor) {
        buf.writeln(
          '  $prefix$marker ${options[i].label}'.style(selectedStyle),
        );
      } else {
        buf.writeln('  $prefix$marker ${options[i].label}'.style(optionStyle));
      }
    }
    return buf.toString();
  }

  @override
  String renderCompact() {
    final buf = StringBuffer();
    buf.writeln(label.style(labelStyle));
    return buf.toString();
  }

  @override
  String build(StringBuffer buf) {
    final parts = [
      // The prompt label (with hint for multiselect)
      '${label.style(labelStyle)}  ${'(space to toggle, enter to confirm)'.dim}',

      // Optional help text
      if (help != null) help!.style(helpStyle),

      // The result / option list
      if (isDone)
        '${Icon.check} $_selectedLabels'.success
      else
        renderOptionsString(),

      // Reserve a line for the error
      _error != null ? '${Icon.error} $_error'.style(errorStyle) : '',
    ];

    buf.writeAll(parts, '\n');
    return buf.toString();
  }

  String get _selectedLabels {
    final labels = <String>[];
    for (var i = 0; i < options.length; i++) {
      if (selected[i]) labels.add(options[i].label);
    }
    return labels.isEmpty ? '(none)' : labels.join(', ');
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    switch (event) {
      case SpecialKey(key: Key.arrowUp):
        if (selectedIndex > 0) {
          selectedIndex--;
          return KeyResult.consumed;
        }
        return KeyResult.ignored;
      case SpecialKey(key: Key.arrowDown):
        if (selectedIndex < options.length - 1) {
          selectedIndex++;
          return KeyResult.consumed;
        }
        return KeyResult.ignored;
      case SpecialKey(key: Key.space):
        selected[selectedIndex] = !selected[selectedIndex];
        return KeyResult.consumed;
      case SpecialKey(key: Key.enter):
        if (validator != null) {
          final error = validator!(value);
          if (error != null) {
            _error = error;
            return KeyResult.consumed;
          }
        }
        _error = null;
        _isDone = true;
        return KeyResult.done;
      default:
        return KeyResult.ignored;
    }
  }

  @override
  List<T> get value {
    final results = <T>[];
    for (var i = 0; i < options.length; i++) {
      if (selected[i]) results.add(options[i].value);
    }
    return results;
  }

  @override
  bool get isDone => _isDone;

  @override
  List<T> write() {
    terminal.cursorHide();
    terminal.updateScreen(render());

    terminal.runRawModeSync<void>(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);

        if (keyResult == KeyResult.done) {
          return;
        }

        if (keyResult == KeyResult.consumed) {
          terminal.updateScreen(render());
        }
      }
    });

    // Show done state — render() handles isDone, use clearScreen + write
    // so the completed line persists (isn't erased by the next widget).
    terminal.clearScreen();
    terminal.write(render());
    terminal.cursorShow();

    return value;
  }
}
