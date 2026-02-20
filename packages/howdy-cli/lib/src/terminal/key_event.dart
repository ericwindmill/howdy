/// A keypress event parsed from raw terminal input.
sealed class KeyEvent {
  const KeyEvent();
}

/// Known special keys.
enum Key {
  enter,
  escape,
  backspace,
  delete,
  tab,
  shiftTab,
  space,
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  home,
  end,
  ctrlD,
}

/// A printable character key.
class CharKey extends KeyEvent {
  /// The character that was typed.
  final String char;

  const CharKey(this.char);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CharKey && char == other.char;

  @override
  int get hashCode => char.hashCode;

  @override
  String toString() => 'CharKey($char)';
}

/// A special (non-printable) key.
class SpecialKey extends KeyEvent {
  /// Which special key was pressed.
  final Key key;

  const SpecialKey(this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SpecialKey && key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'SpecialKey(${key.name})';
}
