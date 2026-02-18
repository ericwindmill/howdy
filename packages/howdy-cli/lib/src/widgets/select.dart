import 'package:howdy/src/option.dart';
import 'package:howdy/src/terminal/key_event.dart';
import 'package:howdy/src/terminal/screen_buffer.dart';
import 'package:howdy/src/terminal/styled_text.dart';
import 'package:howdy/src/terminal/terminal.dart';
import 'package:howdy/src/terminal/text_style.dart';
import 'package:howdy/src/widget.dart';

abstract class SelectInput<T> {
  final String label;
  final List<Option<T>> options;
  final TextStyle labelStyle;
  final TextStyle optionStyle;
  final TextStyle selectedStyle;

  int selectedIndex = 0;

  SelectInput({
    required this.label,
    required this.options,
    this.labelStyle = const TextStyle(),
    this.optionStyle = const TextStyle(),
    this.selectedStyle = const TextStyle(foreground: Color.cyan),
  });

  /// Build the `? label` header string.
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
    ]);
  }

  /// Build the option list string. Subclasses define the visual style.
  String renderOptionsString();
}

class Select<T> extends SelectInput<T> implements InputWidget<T> {
  Select({
    required super.label,
    required super.options,
    super.labelStyle,
    super.optionStyle,
    super.selectedStyle,
    this.validator,
  });

  final Validator<T>? validator;
  bool _isDone = false;
  String? _error;

  static T send<T>({required String label, required List<Option<T>> options}) {
    return Select<T>(label: label, options: options).write();
  }

  @override
  String renderCompact() {
    return '${renderHeaderString()}\n';
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
      final isSelected = i == selectedIndex;
      final option = options[i];
      final unselectedStyle = option.textStyle.hasStyle
          ? option.textStyle
          : optionStyle;

      if (isSelected) {
        buf.writeln(
          renderSpans([
            StyledText('  ❯ ${option.label}', style: selectedStyle),
          ]),
        );
      } else {
        buf.writeln(
          renderSpans([
            StyledText('    ${option.label}', style: unselectedStyle),
          ]),
        );
      }
    }
    return buf.toString();
  }

  @override
  String build(StringBuffer buf) {
    if (_isDone) {
      return '${renderSpans([StyledText('✔ ', style: TextStyle(foreground: Color.green)), StyledText(label, style: TextStyle(bold: true)), StyledText(': '), StyledText(options[selectedIndex].label, style: TextStyle(foreground: Color.cyan))])}\n';
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
  T get value => options[selectedIndex].value;

  @override
  bool get isDone => _isDone;

  @override
  T write() {
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
