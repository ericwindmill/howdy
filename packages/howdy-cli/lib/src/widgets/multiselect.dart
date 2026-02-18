import 'package:howdy/howdy.dart';

class Multiselect<T> extends SelectInput<T> implements InputWidget<List<T>> {
  late final List<bool> selected;

  Multiselect({
    required super.label,
    required super.options,
    super.labelStyle,
    super.optionStyle,
    super.selectedStyle,
    this.validator,
  }) {
    selected = List<bool>.filled(options.length, false);
  }

  final Validator<List<T>>? validator;
  bool _isDone = false;
  String? _error;

  static List<T> send<T>({
    required String label,
    required List<Option<T>> options,
  }) {
    return Multiselect<T>(label: label, options: options).write();
  }

  @override
  String renderCompact() {
    return '${renderHeaderString()}\n';
  }

  @override
  String renderHeaderString() {
    final resolvedLabelStyle = labelStyle.hasStyle
        ? labelStyle
        : TextStyle(bold: true);
    final resolvedIconStyle = labelStyle.hasStyle
        ? labelStyle
        : TextStyle(foreground: Color.green);

    return renderSpans([
      StyledText('? ', style: resolvedIconStyle),
      StyledText(label, style: resolvedLabelStyle),
      StyledText(
        '  (space to toggle, enter to confirm)',
        style: TextStyle(dim: true),
      ),
    ]);
  }

  @override
  String render() {
    final buf = StringBuffer();
    build(buf);
    return buf.toString();
  }

  @override
  String renderOptionsString() {
    final buf = StringBuffer();
    for (var i = 0; i < options.length; i++) {
      final isCursor = i == selectedIndex;
      final isChecked = selected[i];
      final marker = isChecked ? '◉' : '◯';
      final prefix = isCursor ? '❯ ' : '  ';

      if (isCursor) {
        buf.writeln(
          renderSpans([
            StyledText(
              '  $prefix$marker ${options[i].label}',
              style: TextStyle(foreground: Color.cyan),
            ),
          ]),
        );
      } else {
        buf.writeln('  $prefix$marker ${options[i].label}');
      }
    }
    return buf.toString();
  }

  @override
  String build(StringBuffer buf) {
    if (_isDone) {
      final labels = <String>[];
      for (var i = 0; i < options.length; i++) {
        if (selected[i]) labels.add(options[i].label);
      }
      return '${renderSpans([StyledText('✔ ', style: TextStyle(foreground: Color.green)), StyledText(label, style: TextStyle(bold: true)), StyledText(': '), StyledText(labels.isEmpty ? '(none)' : labels.join(', '), style: TextStyle(foreground: Color.cyan))])}\n';
    }

    var result = '${renderHeaderString()}\n${renderOptionsString()}';
    if (_error != null) {
      result +=
          '${renderSpans([StyledText('  ✘ $_error', style: TextStyle(foreground: Color.red))])}\n';
    }
    return result;
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
    final buffer = ScreenBuffer();
    buffer.update(render());

    return terminal.runRawModeSync(() {
      while (true) {
        final event = terminal.readKeySync();
        final result = handleKey(event);
        if (result == KeyResult.consumed) {
          buffer.update(render());
        }
        if (result == KeyResult.done) {
          buffer.update(render());
          return value;
        }
      }
    });
  }
}
