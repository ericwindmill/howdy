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
class Page extends MultiWidget {
  Page({required List<Widget> children, PageKeyMap? keymap})
    : keymap = keymap ?? defaultKeyMap.page,
      super(null, children: children) {
    _focusIndex = _nextFocusableIndex(-1);
    if (_focusIndex == children.length) {
      _isDone = true;
    }
  }

  /// Convenience to run a group and return results.
  static MultiWidgetResults send({
    required List<Widget> children,
    PageKeyMap? keymap,
  }) {
    return Page(children: children, keymap: keymap).write();
  }

  @override
  final PageKeyMap keymap;
  bool _isDone = false;
  late int _focusIndex;

  @override
  int get focusIndex => _focusIndex;

  @override
  bool get isDone => _isDone;

  int _nextFocusableIndex(int startIndex) {
    for (var i = startIndex + 1; i < children.length; i++) {
      if (children[i] is! DisplayWidget) return i;
    }
    return children.length;
  }

  int _prevFocusableIndex(int startIndex) {
    for (var i = startIndex - 1; i >= 0; i--) {
      if (children[i] is! DisplayWidget) return i;
    }
    return -1;
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (isDone) return KeyResult.ignored;
    final focused = children[focusIndex];

    // Check for group-level navigation first
    if (keymap.prev.matches(event)) {
      final prev = _prevFocusableIndex(focusIndex);
      if (prev != -1) {
        _focusIndex = prev;
        return KeyResult.consumed;
      }
      return KeyResult.ignored;
    }

    // delegate to widget
    var result = switch (focused) {
      DisplayWidget _ => KeyResult.done, // Should unreachable now
      InputWidget w => _handleKeyInputWidget(event, w),
      MultiWidget w => _handleKeyMultiWidget(event, w),
      _ => KeyResult.ignored,
    };

    // handle navigation
    if (result == KeyResult.done) {
      // Widget completed — advance focus
      final next = _nextFocusableIndex(focusIndex);
      if (next < children.length) {
        _focusIndex = next;
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
  void reset() {
    _isDone = false;
    _focusIndex = _nextFocusableIndex(-1);
    if (_focusIndex == children.length) {
      _isDone = true;
    }
    for (final w in children) {
      w.reset();
    }
  }

  KeyResult _handleKeyInputWidget(KeyEvent event, InputWidget widget) {
    return widget.handleKey(event);
  }

  KeyResult _handleKeyMultiWidget(KeyEvent event, MultiWidget widget) {
    return widget.handleKey(event);
  }

  @override
  String build(IndentedStringBuffer buf) {
    for (var i = 0; i < children.length; i++) {
      final widget = children[i];
      if (widget is InputWidget) {
        widget.isFocused = i == _focusIndex;
      }
      buf.writeln(widget.render());
    }
    return buf.toString();
  }
}
