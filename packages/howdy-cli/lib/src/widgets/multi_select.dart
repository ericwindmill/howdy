import 'package:howdy/howdy.dart';

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
    super.key,
    super.theme,
  }) {
    selected = List<bool>.filled(options.length, false);
  }

  final List<Option<T>> options;
  late final List<bool> selected;

  int selectedIndex = 0;
  bool _isDone = false;

  @override
  String get usage => usageHint([
    (keys: '${Icon.arrowUp} / ${Icon.arrowDown}', action: 'navigate'),
    (keys: 'space', action: 'toggle'),
    (keys: 'enter', action: 'submit'),
  ]);

  @override
  void reset() {
    super.reset();
    selected = List<bool>.filled(options.length, false);
    selectedIndex = 0;
    _isDone = false;
  }

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
  String renderOptionsString(IndentedStringBuffer buf) {
    for (var i = 0; i < options.length; i++) {
      final isPointer = i == selectedIndex;
      final isChecked = selected[i];
      final label = options[i].label;

      if (!isDone) {
        final prefix = isPointer ? '${Icon.pointer} ' : '  ';
        final marker = isChecked
            ? Icon.optionFilled.selected
            : Icon.optionEmpty.body;
        buf.write(prefix);
        buf.write(marker);
        buf.writeln(' ${label.style(isChecked ? theme.selected : theme.body)}');
      } else {
        final prefix = '  ';
        final marker = isChecked ? Icon.check.success : Icon.optionEmpty.body;
        buf.write(prefix);
        buf.write(marker);
        buf.writeln(' ${label.style(isChecked ? theme.success : theme.body)}');
      }
    }
    buf.dedent();
    return buf.toString();
  }

  @override
  String build(IndentedStringBuffer buf) {
    // The prompt label (with hint for multiselect)
    buf.writeln(label.style(theme.label));

    // Optional help text
    if (help != null) buf.writeln(help!.style(theme.body));

    // The result / option list
    buf.indent();
    renderOptionsString(buf);

    if (isStandalone) {
      buf.writeln();
      buf.writeln(usage.dim);
      hasError ? buf.writeln('${Icon.error} $error'.style(theme.error)) : '';
      buf.writeln();
    }
    buf.dedent();
    return buf.toString();
  }

  String get selectedLabels {
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
            this.error = error;
            return KeyResult.consumed;
          }
        }
        error = null;
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
