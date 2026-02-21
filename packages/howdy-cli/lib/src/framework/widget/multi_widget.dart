part of 'widget.dart';

/// Todo: Remove if not needed
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

abstract class MultiWidget<T extends Widget>
    extends Widget<MultiWidgetResults> {
  MultiWidget(
    super.title, {
    super.help,
    super.theme,
    required this.children,
  });

  final List<T> children;

  int get focusIndex => 0;

  @override
  MultiWidgetResults get value {
    var results = MultiWidgetResults();
    for (final widget in children) {
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
