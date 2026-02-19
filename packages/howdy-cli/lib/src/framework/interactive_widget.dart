part of 'widget.dart';

abstract class InteractiveWidget<T> extends Widget<T> {
  InteractiveWidget({
    required this.label,
    this.help,
    this.defaultValue,
    this.validator,
    super.key,
    super.theme,
  });

  final String label;
  final String? help;
  final T? defaultValue;
  final Validator<T>? validator;

  /// Whether this widget is currently focused in a group or form.
  bool isFocused = true;

  /// The active style based on focus state.
  FieldStyles get fieldStyle => isFocused ? theme.focused : theme.blurred;

  @override
  T get value;

  /// The current validation error, if any. Null means valid.
  ///
  /// Subclasses set this in [handleKey] when validation fails.
  /// Parent containers (e.g. [Form]) read this to display errors
  /// in a centralized location.
  String? error;

  bool get hasDefault => defaultValue != null;

  bool get hasError => error != null;

  /// The control hint text for this widget (e.g. "space to toggle, enter to submit").
  ///
  /// Displayed below the widget when rendering standalone.
  /// Read by parent containers (e.g. [Form]) to show contextual guide text.
  String get usage;

  /// The rendering context for this widget.
  ///
  /// Defaults to [RenderContext.standalone] for standalone usage.
  /// Parent containers (e.g. [Form]) set this to
  /// [RenderContext.form] to take ownership of error display
  /// and control hints.
  RenderContext renderContext = RenderContext.standalone;

  /// Whether this widget is rendering standalone (i.e. owns its chrome).
  bool get isStandalone => renderContext == RenderContext.standalone;

  @override
  void reset() {
    error = null;
  }

  /// Process a key event. Override for interactive widgets.
  ///
  /// Returns [KeyResult.consumed] if the key changed widget state,
  /// [KeyResult.ignored] if it wasn't relevant, or [KeyResult.done]
  /// if the widget has finished collecting input.
  @override
  KeyResult handleKey(KeyEvent event) => KeyResult.ignored;
}
