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
    super.defaultValue,
    super.help,
    super.validator,
    super.key,
    super.theme,
  }) {
    selected = List<bool>.filled(options.length, false);
    if (defaultValue != null) {
      for (var i = 0; i < options.length; i++) {
        if (defaultValue!.contains(options[i].value)) {
          selected[i] = true;
        }
      }
    }
  }

  /// Convenience factory, uses active theme values.
  static List<T> send<T>({
    required String label,
    required List<Option<T>> options,
    String? description,
    List<T>? defaultValue,
    Validator<List<T>>? validator,
  }) {
    return Multiselect<T>(
      label: label,
      options: options,
      help: description,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  final List<Option<T>> options;
  late List<bool> selected;

  int selectedIndex = 0;
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

  String get selectedLabels {
    final labels = <String>[];
    for (var i = 0; i < options.length; i++) {
      if (selected[i]) labels.add(options[i].label);
    }
    return labels.isEmpty ? '(none)' : labels.join(', ');
  }

  @override
  String get usage => usageHint([
    (keys: '${Icon.arrowUp} / ${Icon.arrowDown}', action: 'navigate'),
    (keys: 'space', action: 'toggle'),
    (keys: 'enter', action: 'submit'),
  ]);

  @override
  KeyResult handleKey(KeyEvent event) {
    if (defaultKeyMap.multiSelect.prev.matches(event)) {
      if (selectedIndex > 0) {
        selectedIndex--;
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    } else if (defaultKeyMap.multiSelect.next.matches(event)) {
      if (selectedIndex < options.length - 1) {
        selectedIndex++;
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    } else if (defaultKeyMap.multiSelect.toggle.matches(event)) {
      selected[selectedIndex] = !selected[selectedIndex];
      return KeyResult.consumed;
    } else if (defaultKeyMap.multiSelect.submit.matches(event)) {
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
    }
    return KeyResult.ignored;
  }

  /// Build the option list string.
  String renderOptionsString(IndentedStringBuffer buf) {
    for (var i = 0; i < options.length; i++) {
      final isPointer = i == selectedIndex;
      final isChecked = selected[i];
      final label = options[i].label;

      if (!isDone) {
        final prefix = isPointer
            ? '${Icon.pointer.style(fieldStyle.multiSelect.selector)} '
            : '  ';
        final marker = isChecked
            ? Icon.optionFilled.style(fieldStyle.multiSelect.selectedPrefix)
            : Icon.optionEmpty.style(fieldStyle.multiSelect.unselectedPrefix);
        buf.write(prefix);
        buf.write(marker);
        buf.write(' ');
        buf.writeln(
          label.style(
            isChecked ? fieldStyle.multiSelect.selectedOption : fieldStyle.base,
          ),
        );
      } else {
        final prefix = '  ';
        final marker = isChecked ? Icon.check.success : Icon.optionEmpty.body;
        buf.write(prefix);
        buf.write(marker);
        buf.write(' ');
        buf.writeln(
          label.style(
            isChecked ? fieldStyle.multiSelect.selectedOption : fieldStyle.base,
          ),
        );
      }
    }
    buf.dedent();
    return buf.toString();
  }

  @override
  void reset() {
    super.reset();
    selected = List<bool>.filled(options.length, false);
    selectedIndex = 0;
    _isDone = false;
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
  String build(IndentedStringBuffer buf) {
    // The prompt label (with hint for multiselect)
    buf.writeln(label.style(fieldStyle.title));

    // Optional help text
    if (help != null) buf.writeln(help!.style(fieldStyle.description));

    // The result / option list

    renderOptionsString(buf);

    if (isStandalone) {
      buf.writeln();
      buf.writeln(usage.style(theme.help.shortDesc));
      hasError
          ? buf.writeln(
              '${Icon.error} $error'.style(fieldStyle.errorMessage),
            )
          : '';
      buf.writeln();
    }
    buf.dedent();
    return buf.toString();
  }

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
