import 'package:howdy/howdy.dart';

/// A MultiWidget that displays a collection of DisplayWidgets,
/// and optionally pauses execution with a [NextButton].
class Note extends MultiWidget<Widget> {
  // ignore: use_super_parameters
  Note({
    required List<DisplayWidget> children,
    this.next = false,
    this.nextLabel = 'Next',
    PageKeyMap? keymap,
  }) : super(
         null,
         children: [
           ...children,
           if (next) NextButton(nextLabel, keymap: keymap),
         ],
       );

  /// Whether this note should pause execution until the user continues.
  final bool next;

  /// The label for the continue button, if [next] is true.
  final String nextLabel;

  /// Convenience factory for standalone usage.
  static void send({
    required List<DisplayWidget> children,
    bool next = false,
    String nextLabel = 'Next',
    PageKeyMap? keymap,
  }) {
    Note(
      children: children,
      next: next,
      nextLabel: nextLabel,
      keymap: keymap,
    ).write();
  }

  @override
  int get focusIndex {
    final idx = children.indexWhere((w) => w is NextButton);
    return idx != -1 ? idx : 0;
  }

  @override
  bool get isDone {
    final btn = children.whereType<NextButton>().firstOrNull;
    if (btn != null) return btn.isDone;
    return true;
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (isDone) return KeyResult.ignored;
    final btn = children.whereType<NextButton>().firstOrNull;
    if (btn != null) {
      return btn.handleKey(event);
    }
    return super.handleKey(event);
  }

  @override
  void reset() {
    for (final w in children) {
      w.reset();
    }
  }

  @override
  String build(IndentedStringBuffer buf) {
    for (var i = 0; i < children.length; i++) {
      final widget = children[i];
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
