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
class Group extends MultiWidget {
  Group(super.widgets);

  bool _isDone = false;

  int _focusIndex = 0;

  @override
  int get focusIndex => _focusIndex;

  @override
  bool get isDone => _isDone;

  /// Convenience to run a group and return results.
  static MultiWidgetResults send(List<InteractiveWidget> widgets) {
    return Group(widgets).write();
  }

  @override
  void reset() {
    _isDone = false;
    _focusIndex = 0;
    for (final w in widgets) {
      w.reset();
    }
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (isDone) return KeyResult.ignored;
    final focused = widgets[focusIndex];

    // Check for group-level navigation first
    if (event case SpecialKey(key: Key.shiftTab)) {
      if (focusIndex > 0) {
        _focusIndex--;
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    }

    // delegate to widget
    var result = switch (focused) {
      DisplayWidget _ => _handleKeyDisplayWidget(event),
      InteractiveWidget w => _handleKeyInputWidget(event, w),
      MultiWidget w => _handleKeyMultiWidget(event, w),
    };

    // handle navigation
    if (result == KeyResult.done) {
      // Widget completed — advance focus
      if (focusIndex < widgets.length - 1) {
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

  KeyResult _handleKeyDisplayWidget(KeyEvent event) {
    return KeyResult.done;
  }

  KeyResult _handleKeyInputWidget(KeyEvent event, InteractiveWidget widget) {
    return widget.handleKey(event);
  }

  KeyResult _handleKeyMultiWidget(KeyEvent event, MultiWidget widget) {
    return widget.handleKey(event);
  }

  @override
  String build(IndentedStringBuffer buf) {
    for (var i = 0; i < widgets.length; i++) {
      buf.writeln(widgets[i].render());
    }
    return buf.toString();
  }
}
