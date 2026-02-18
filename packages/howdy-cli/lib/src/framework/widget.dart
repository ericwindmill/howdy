import 'dart:async';

import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/theme.dart';

part 'multi_widget.dart';
part 'display_widget.dart';
part 'interactive_widget.dart';

/// How a widget responded to a key event.
enum KeyResult {
  /// Key was processed, widget state changed (triggers re-render).
  consumed,

  /// Key was not relevant to this widget.
  ignored,

  /// Widget is finished — [value] is the final answer.
  done,
}

/// The rendering context for an interactive widget.
///
/// Controls whether the widget renders its own chrome (error messages,
/// control hints) or defers to a parent container.
enum RenderContext {
  /// Standalone — widget owns all chrome (error line, control hints).
  standalone,

  /// Inside a container (e.g. [Form]) — container owns error and controls.
  form,
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
  /// Used for easy retrieval of results in [MultiWidgetResults]
  String? key;

  Widget({this.key, this.theme = Theme.current});

  /// Optional theme override for this widget.
  /// Falls back to [Theme.current] if not provided.
  final Theme theme;

  /// The widget's current value.
  ///
  /// For input widgets, this may be a partial/default value until
  /// [isDone] is true. For output widgets, this returns immediately.
  T get value;

  /// Whether the widget has finished collecting input.
  bool get isDone => false;

  KeyResult handleKey(KeyEvent event) => KeyResult.done;

  /// Render current visual state as a string. Does NOT write to output.
  /// Usually you want to override [build] instead of [render].
  String render() {
    final buf = IndentedStringBuffer();
    final str = build(buf);
    return str;
  }

  /// Build the widget's visual output into [buf].
  ///
  /// Use [IndentedStringBuffer.indent] and [IndentedStringBuffer.dedent]
  /// to control indentation instead of hardcoding spaces.
  String build(IndentedStringBuffer buf);

  /// Run standalone — manages raw mode, reads keys, writes to output.
  ///
  /// This is the convenience wrapper that wires [render] and
  /// [handleKey] together with terminal IO for one-off usage.
  FutureOr<T> write();
}
