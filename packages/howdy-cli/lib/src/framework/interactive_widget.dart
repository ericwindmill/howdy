part of 'widget.dart';

abstract class InteractiveWidget<T> extends Widget<T> {
  InteractiveWidget({
    required this.label,
    this.help,
    this.defaultValue,
    this.validator,
    super.key,
  });

  final String label;
  final String? help;
  final T? defaultValue;
  final Validator<T>? validator;

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
