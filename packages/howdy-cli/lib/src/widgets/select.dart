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
class Select<T> extends InteractiveWidget<T> {
  Select({
    required super.label,
    required this.options,
    super.key,
    super.help,
    super.validator,
    super.theme,
  });

  final List<Option<T>> options;

  int selectedIndex = 0;
  bool _isDone = false;

  @override
  String get usage => usageHint([
    (keys: '${Icon.arrowUp} / ${Icon.arrowDown}', action: 'select'),
    (keys: 'enter', action: 'submit'),
  ]);

  @override
  void reset() {
    super.reset();
    selectedIndex = 0;
    _isDone = false;
  }

  /// Convenience factory, uses active theme values.
  static T send<T>({
    required String label,
    required List<Option<T>> options,
    String? help,
    Validator<T>? validator,
  }) {
    return Select<T>(
      label: label,
      options: options,
      help: help,
      validator: validator,
    ).write();
  }

  /// Build the option list string.
  String renderOptionsString(IndentedStringBuffer buf) {
    for (var i = 0; i < options.length; i++) {
      final isSelected = i == selectedIndex;
      final option = options[i];
      final style = option.textStyle.hasStyle ? option.textStyle : theme.body;

      if (isSelected && !isDone) {
        buf.writeln(
          '${Icon.pointer} ${option.label}'.style(theme.selected),
        );
      } else if (isSelected && isDone) {
        buf.writeln(
          '${Icon.check} ${option.label}'.style(theme.success),
        );
      } else {
        buf.indent();
        buf.writeln(option.label.style(style));
        buf.dedent();
      }
    }
    return buf.toString();
  }

  @override
  String build(IndentedStringBuffer buf) {
    // The prompt label
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
  T get value => options[selectedIndex].value;

  @override
  bool get isDone => _isDone;

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
