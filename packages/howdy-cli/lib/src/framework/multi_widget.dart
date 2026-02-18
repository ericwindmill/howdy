part of 'widget.dart';

class MultiWidgetResults {
  final Map<String, Object?> _values = {};

  void operator []=(String key, Object? value) {
    _values[key] = value;
  }

  Object? operator [](String key) {
    return _values[key];
  }
}

abstract class MultiWidget extends Widget<MultiWidgetResults> {
  MultiWidget(this.widgets);

  final List<Widget> widgets;

  int _focusIndex = 0;

  bool _isDone = false;

  bool get isDone => _isDone;

  @override
  MultiWidgetResults get value {
    var results = MultiWidgetResults();
    for (final widget in widgets) {
      if (widget is DisplayWidget) continue;

      results[key ?? widget.value] = widget.value;
    }

    return results;
  }

  /* * * * * * * * * * *
  
  Handle key stroke section.

  Recieves key events, handles navigation, and delegates
  interaction to child widgets

  * * * * * * * * * * */
  KeyResult handleKey(KeyEvent event) {
    if (isDone) return KeyResult.ignored;
    final focused = widgets[_focusIndex];

    // Check for group-level navigation first
    if (event case SpecialKey(key: Key.shiftTab)) {
      if (_focusIndex > 0) {
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

  KeyResult _handleKeyDisplayWidget(KeyEvent event) {
    return KeyResult.done;
  }

  KeyResult _handleKeyInputWidget(KeyEvent event, InteractiveWidget widget) {
    return widget.handleKey(event);
  }

  KeyResult _handleKeyMultiWidget(KeyEvent event, MultiWidget widget) {
    return widget.handleKey(event);
  }

  /* * * * * * * * * * *
  
  Build and write section

  * * * * * * * * * * */

  @override
  MultiWidgetResults write() {
    terminal.cursorHide();
    terminal.updateScreen(render());

    terminal.runRawModeSync(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);
        if (keyResult == KeyResult.consumed || keyResult == KeyResult.done) {
          terminal.updateScreen(render());
        }
        if (keyResult == KeyResult.done) {
          return value;
        }
      }
    });

    terminal.clearScreen();
    terminal.write(render());
    terminal.cursorShow();
    return value;
  }
}
