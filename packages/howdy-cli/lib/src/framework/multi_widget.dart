part of 'widget.dart';

class MultiWidgetResults {
  final Map<String, Object?> _values = {};

  void operator []=(String key, Object? value) {
    _values[key] = value;
  }

  Object? operator [](String key) {
    return _values[key];
  }

  /// All result keys.
  Iterable<String> get keys => _values.keys;
}

abstract class MultiWidget extends Widget<MultiWidgetResults> {
  MultiWidget(this.widgets);

  final List<Widget> widgets;

  int get focusIndex => 0;

  @override
  MultiWidgetResults get value {
    var results = MultiWidgetResults();
    for (final widget in widgets) {
      if (widget is DisplayWidget) continue;

      // Merge child MultiWidget results (e.g. Group inside Form)
      // into the parent so all keys are accessible at the top level.
      if (widget is MultiWidget) {
        final childResults = widget.value;
        for (final key in childResults.keys) {
          results[key] = childResults[key];
        }
      } else {
        results[widget.key ?? ''] = widget.value;
      }
    }

    return results;
  }

  // For now, all Multiwidgets use the same write logic.
  // It's possible that I'll need to make this an abstract method, we'll see.
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
