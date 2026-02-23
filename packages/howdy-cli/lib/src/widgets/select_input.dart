import 'package:howdy/howdy.dart';

/// A single-choice select list.
///
/// Arrow keys navigate, Enter confirms.
///
///```txt
/// Pick a language
///   ❯ Dart
///     Go
///     Rust
///```
///
/// ```dart
/// final lang = Select.send<String>(
///   label: 'Pick a language',
///   options: [
///     Option(label: 'Dart', value: 'dart'),
///     Option(label: 'Go',   value: 'go'),
///   ],
/// );
/// ```
class Select<T> extends InputWidget<T> {
  Select(
    super.title, {
    required this.options,
    ListSelectKeyMap? keymap,
    super.defaultValue,
    super.key,
    super.help,
    super.validator,
    super.theme,
  }) : keymap = keymap ?? defaultKeyMap.select {
    if (defaultValue != null) {
      final idx = options.indexWhere((opt) => opt.value == defaultValue);
      if (idx != -1) {
        selectedIndex = idx;
      }
    }
  }

  /// Convenience factory, uses active theme values.
  static T send<T>({
    required String label,
    required List<Option<T>> options,
    ListSelectKeyMap? keymap,
    String? help,
    T? defaultValue,
    Validator<T>? validator,
  }) {
    return Select<T>(
      label,
      options: options,
      keymap: keymap,
      help: help,
      defaultValue: defaultValue,
      validator: validator,
    ).write();
  }

  final List<Option<T>> options;
  @override
  final ListSelectKeyMap keymap;

  int selectedIndex = 0;
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

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
      final isSelected = i == selectedIndex;
      final option = options[i];
      final style = option.textStyle.hasStyle
          ? option.textStyle
          : fieldStyle.base;

      if (isSelected && !isDone && isFocused) {
        buf.writeln(
          '${Icon.pointer.style(fieldStyle.select.selector)} ${option.label.style(fieldStyle.select.option)}',
        );
      } else if (isSelected && isDone) {
        buf.writeln(
          '${Icon.check} ${option.label}'.style(fieldStyle.successMessage),
        );
      } else {
        buf.writeln('  ${option.label.style(style)}');
        buf.dedent();
      }
    }
    return buf.toString();
  }

  @override
  void reset() {
    super.reset();
    selectedIndex = 0;
    _isDone = false;
  }

  @override
  T get value => options[selectedIndex].value;

  @override
  String build(IndentedStringBuffer buf) {
    // The prompt label
    if (title != null) buf.writeln(title!.style(fieldStyle.title));

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
  T write() {
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
