import 'package:howdy/howdy.dart';

/// A MultiWidget that displays a collection of DisplayWidgets,
/// and optionally pauses execution with a [NextButton].
class Note extends MultiWidget<Widget> {
  // ignore: use_super_parameters
  Note(
    List<DisplayWidget> notes, {
    this.next = false,
    this.nextLabel = 'Next',
  }) : super([...notes, if (next) NextButton(label: nextLabel)]);

  /// Whether this note should pause execution until the user continues.
  final bool next;

  /// The label for the continue button, if [next] is true.
  final String nextLabel;

  /// Convenience factory for standalone usage.
  static void send(
    List<DisplayWidget> widgets, {
    bool next = false,
    String nextLabel = 'Next',
  }) {
    Note(widgets, next: next, nextLabel: nextLabel).write();
  }

  @override
  int get focusIndex {
    final idx = widgets.indexWhere((w) => w is NextButton);
    return idx != -1 ? idx : 0;
  }

  @override
  bool get isDone {
    final btn = widgets.whereType<NextButton>().firstOrNull;
    if (btn != null) return btn.isDone;
    return true;
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (isDone) return KeyResult.ignored;
    final btn = widgets.whereType<NextButton>().firstOrNull;
    if (btn != null) {
      return btn.handleKey(event);
    }
    return super.handleKey(event);
  }

  @override
  void reset() {
    for (final w in widgets) {
      w.reset();
    }
  }

  @override
  String build(IndentedStringBuffer buf) {
    for (var i = 0; i < widgets.length; i++) {
      final widget = widgets[i];
      if (widget is NextButton) {
        // Enforce focus state so the NextButton receives the focused theme.
        widget.isFocused = true;
        buf.writeln(widget.render());
      } else {
        buf.writeln(widget.render());
      }
    }
    return buf.toString();
  }
}
