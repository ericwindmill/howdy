import 'package:howdy/howdy.dart';

/// A page of widgets rendered and completed together.
///
/// Group manages focus across multiple input widgets, routing key events
/// to the active widget and re-rendering all widgets on state changes.
///
/// ```dart
/// final group = Group([
///   Prompt(label: 'Name'),
///   Select(label: 'Language', options: [...]),
///   ConfirmInput(label: 'Use git?'),
/// ]);
///
/// final results = group.render();
/// // results[0] = 'MyApp' (String)
/// // results[1] = 'dart' (T)
/// // results[2] = true (bool)
/// ```
///
/// Use Tab/Enter to advance to the next field, Shift+Tab to go back.
class Group extends InputWidget<List<Object?>> {
  Group(this.widgets);

  /// The widgets in this group, rendered top-to-bottom.
  final List<Widget> widgets;

  /// Index of the currently focused widget.
  int _focusIndex = 0;

  bool _isDone = false;

  /// Convenience to run a group and return results.
  static List<Object?> send(List<Widget> widgets) {
    return Group(widgets).write();
  }

  @override
  String build(StringBuffer buf) {
    final buf = StringBuffer();
    for (var i = 0; i < widgets.length; i++) {
      final widget = widgets[i];
      if (widget.isDone) {
        // Completed: show done state
        buf.write(widget.render());
      } else if (i == _focusIndex) {
        // Focused: show full interactive state
        buf.write(widget.render());
      } else {
        // Pending: show compact label
        buf.write(widget.renderCompact());
      }
    }
    return buf.toString();
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (_isDone) return KeyResult.ignored;

    final focused = widgets[_focusIndex];

    // Check for group-level navigation first
    if (event case SpecialKey(key: Key.shiftTab)) {
      if (_focusIndex > 0) {
        _focusIndex--;
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    }

    // Delegate to the focused widget
    final result = focused.handleKey(event);

    if (result == KeyResult.done) {
      // Widget completed — advance focus
      if (_focusIndex < widgets.length - 1) {
        _focusIndex++;
        return KeyResult.consumed;
      } else {
        // All widgets done
        _isDone = true;
        return KeyResult.done;
      }
    }

    return result;
  }

  @override
  List<Object?> get value {
    return [for (final widget in widgets) widget.value];
  }

  @override
  bool get isDone => _isDone;

  @override
  List<Object?> write() {
    final buffer = ScreenBuffer();
    terminal.cursorHide();
    buffer.update(render());

    final result = terminal.runRawModeSync(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);
        if (keyResult == KeyResult.consumed || keyResult == KeyResult.done) {
          buffer.update(render());
        }
        if (keyResult == KeyResult.done) {
          return value;
        }
      }
    });

    terminal.cursorShow();
    return result;
  }
}
