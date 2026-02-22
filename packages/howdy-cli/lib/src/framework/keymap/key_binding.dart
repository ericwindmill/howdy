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

  static const up = KeyBinding(
    keys: [SpecialKey(Key.arrowUp)],
    helpKey: Icon.arrowUp,
    helpDesc: 'up',
  );

  static const down = KeyBinding(
    keys: [SpecialKey(Key.arrowDown)],
    helpKey: Icon.arrowDown,
    helpDesc: 'down',
  );

  static const left = KeyBinding(
    keys: [SpecialKey(Key.arrowLeft)],
    helpKey: Icon.arrowLeft,
    helpDesc: 'left',
  );

  static const right = KeyBinding(
    keys: [SpecialKey(Key.arrowRight)],
    helpKey: Icon.arrowRight,
    helpDesc: 'right',
  );

  // NOTE: macOS terminals apply ICRNL translation (\ r → \n) before Dart reads
  // stdin in raw mode, so pressing Enter arrives as byte 10 (Key.ctrlJ), not
  // byte 13 (Key.enter). Both are included in all Enter-related bindings so
  // they work correctly on macOS and other platforms.
  static const newline = KeyBinding(
    keys: [SpecialKey(Key.enter), SpecialKey(Key.ctrlJ)],
    helpKey: 'enter',
    helpDesc: 'newline',
  );

  static const enterTabSubmit = KeyBinding(
    keys: [SpecialKey(Key.enter), SpecialKey(Key.ctrlJ), SpecialKey(Key.tab)],
    helpKey: 'enter/tab',
    helpDesc: 'submit',
  );

  static const tabSubmit = KeyBinding(
    keys: [SpecialKey(Key.tab)],
    helpKey: 'tab',
    helpDesc: 'submit',
  );

  static const back = KeyBinding(
    keys: [SpecialKey(Key.shiftTab)],
    helpKey: 'shift+tab',
    helpDesc: 'back',
  );

  static const ctrlJSubmit = KeyBinding(
    keys: [SpecialKey(Key.ctrlJ)],
    helpKey: 'ctrl+j',
    helpDesc: 'submit',
  );

  static const spaceSelect = KeyBinding(
    keys: [SpecialKey(Key.space)],
    helpKey: 'space',
    helpDesc: 'select',
  );
}
