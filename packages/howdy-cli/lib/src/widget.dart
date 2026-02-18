import 'dart:async';

import 'package:howdy/src/terminal/key_event.dart';

/// How a widget responded to a key event.
enum KeyResult {
  /// Key was processed, widget state changed (triggers re-render).
  consumed,

  /// Key was not relevant to this widget.
  ignored,

  /// Widget is finished — [value] is the final answer.
  done,
}

/// A validation function. Returns `null` if valid, or an error message string.
typedef Validator<T> = String? Function(T value);

/// Base class for all terminal widgets.
///
/// **Output widgets** (Text, Table) only need to override [render]
/// and [write].
///
/// **Input widgets** (Prompt, Select, etc.) also override [handleKey]
/// and [value].
///
/// [write] is the standalone convenience method that handles IO directly.
/// [render] + [handleKey] are the composable building blocks
/// that Form/Group use.
sealed class Widget<T> {
  /// Render current visual state as a string. Does NOT write to output.
  /// Generally, you want to override `build` instead of render.
  String render() {
    final buf = StringBuffer();
    final str = build(buf);
    return str;
  }

  /// Render a compact version for unfocused display within a Group.
  ///
  /// Override for widgets with long interactive displays (like Select)
  /// to show just a one-line label when not focused.
  /// Defaults to [render].
  String renderCompact() => render();

  String build(StringBuffer buf);

  /// Run standalone — manages raw mode, reads keys, writes to output.
  ///
  /// This is the convenience wrapper that wires [render] and
  /// [handleKey] together with terminal IO for one-off usage.
  FutureOr<T> write();

  /// The widget's current value.
  ///
  /// For input widgets, this may be a partial/default value until
  /// [isDone] is true. For output widgets, this returns immediately.
  T get value;
}

abstract class DisplayWidget extends Widget<void> {
  @override
  void get value {}
}

abstract class InputWidget<T> extends Widget<T> {
  InputWidget({
    required this.label,
    this.help,
    this.defaultValue,
    this.validator,
  });

  final String label;
  final String? help;
  final String? defaultValue;
  final Validator<String>? validator;

  String? _error;

  /// Whether the widget has finished collecting input.
  bool get isDone;

  bool get hasDefault => defaultValue != null;

  bool get hasError => _error != null;

  /// Process a key event. Override for interactive widgets.
  ///
  /// Returns [KeyResult.consumed] if the key changed widget state,
  /// [KeyResult.ignored] if it wasn't relevant, or [KeyResult.done]
  /// if the widget has finished collecting input.
  KeyResult handleKey(KeyEvent event) => KeyResult.ignored;
}
