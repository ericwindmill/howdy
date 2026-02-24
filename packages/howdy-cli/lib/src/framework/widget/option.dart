import 'package:howdy/howdy.dart';

/// A selectable option for use with [Select] and [Multiselect] primitives.
class Option<T> {
  /// The display label shown to the user.
  final String label;

  /// The value returned when this option is selected.
  final T value;

  /// Optional custom style for this option's label.
  final TextStyle textStyle;

  /// Optional help text shown as a second column alongside the label.
  final String? help;

  const Option({
    required this.label,
    required this.value,
    this.textStyle = const TextStyle(),
    this.help,
  });
}
