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
class Multiselect<T> extends InputWidget<List<T>> {
  Multiselect(
    super.title, {
    required this.options,
    MultiSelectKeyMap? keymap,
    super.defaultValue,
    super.help,
    super.validator,
    super.key,
    super.theme,
  }) : keymap = keymap ?? defaultKeyMap.multiSelect {
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
    MultiSelectKeyMap? keymap,
    String? description,
    List<T>? defaultValue,
    Validator<List<T>>? validator,
  }) {
    return Multiselect<T>(
      label,
      options: options,
      keymap: keymap,
      help: description,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  bool _isDone = false;

  @override
  bool get isDone => _isDone;

  @override
  final MultiSelectKeyMap keymap;

  final List<Option<T>> options;

  late List<bool> selected;

  int selectedIndex = 0;

  String get selectedLabels {
    final labels = <String>[];
    for (var i = 0; i < options.length; i++) {
      if (selected[i]) labels.add(options[i].label);
    }
    return labels.isEmpty ? '(none)' : labels.join(', ');
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (keymap.up.matches(event)) {
      if (selectedIndex > 0) {
        selectedIndex--;
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    } else if (keymap.down.matches(event)) {
      if (selectedIndex < options.length - 1) {
        selectedIndex++;
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    } else if (keymap.toggle.matches(event)) {
      selected[selectedIndex] = !selected[selectedIndex];
      return KeyResult.consumed;
    } else if (keymap.submit.matches(event)) {
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

      final prefix = (!isDone && isPointer)
          ? '${Icon.pointer.style(fieldStyle.multiSelect.selector)} '
          : '  ';
      final marker = isDone
          ? (isChecked
                ? Icon.check.style(fieldStyle.multiSelect.selectedPrefix)
                : Icon.optionEmpty.style(
                    fieldStyle.multiSelect.unselectedPrefix,
                  ))
          : (isChecked
                ? Icon.optionFilled.style(fieldStyle.multiSelect.selectedPrefix)
                : Icon.optionEmpty.style(
                    fieldStyle.multiSelect.unselectedPrefix,
                  ));

      buf.write(prefix);
      buf.write(marker);
      buf.write(' ');
      buf.writeln(
        label.style(
          isChecked
              ? fieldStyle.multiSelect.selectedOption
              : fieldStyle.multiSelect.unselectedOption,
        ),
      );
    }
    buf.dedent();
    return buf.toString();
  }

  @override
  void reset() {
    super.reset();
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
    // Title and optional help
    if (title != null) buf.writeln(title!.style(fieldStyle.title));
    if (help != null) buf.writeln(help!.style(fieldStyle.description));

    // Option list — appearance varies by state but is always rendered
    renderOptionsString(buf);

    // Chrome: usage hint + error — only shown when standalone.
    // When inside a form, parent owns this chrome.
    switch (renderState) {
      case RenderState.editing:
      case RenderState.waiting:
      case RenderState.waitingInForm:
      case RenderState.editingInForm:
      case RenderState.completeInForm:
        if (!renderState.isFormElement) {
          buf.writeln();
          buf.writeln(usage.style(theme.help.shortDesc));
          buf.writeln();
          buf.writeln();
        }
      case RenderState.error:
        buf.writeln();
        buf.writeln(usage.style(theme.help.shortDesc));
        buf.writeln('${Icon.error} $error'.style(fieldStyle.errorMessage));
        buf.writeln();
      case RenderState.errorInForm:
        break; // form owns chrome
      case RenderState.verified:
      case RenderState.verifiedInForm:
        break; // form owns chrome
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
