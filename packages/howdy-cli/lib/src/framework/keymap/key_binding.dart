import 'package:howdy/howdy.dart';

/// A set of keys that trigger a specific action, along with help text.
class KeyBinding {
  const KeyBinding({
    required this.keys,
    required this.helpKey,
    required this.helpDesc,
    this.enabled = true,
  });

  /// The keys that trigger this binding.
  final List<KeyEvent> keys;

  /// The short key text to display in help (e.g. "enter").
  final String helpKey;

  /// The description of the action (e.g. "submit").
  final String helpDesc;

  final bool enabled;

  KeyBinding copyWith({
    List<KeyEvent>? keys,
    String? helpKey,
    String? helpDesc,
    bool? enabled,
  }) {
    return KeyBinding(
      keys: keys ?? this.keys,
      helpKey: helpKey ?? this.helpKey,
      helpDesc: helpDesc ?? this.helpDesc,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Returns true if the given [event] matches any key in this binding.
  bool matches(KeyEvent event) => keys.contains(event);

  String get usage =>
      '${helpKey.style(Theme.current.help.shortKey)} ${helpDesc.style(Theme.current.help.shortDesc)}';
}
