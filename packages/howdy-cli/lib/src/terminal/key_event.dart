/// A keypress event parsed from raw terminal input.
sealed class KeyEvent {
  const KeyEvent();
}

/// Known special keys.
enum Key {
  // ── Navigation ────────────────────────────────────────────────────────────
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
  pageUp,
  pageDown,

  // ── Ctrl + letter (bytes 1–26) ────────────────────────────────────────────
  // Note: some overlap with other keys in some terminals:
  //   ctrlH == backspace (byte 8)
  //   ctrlI == tab       (byte 9)
  //   ctrlJ == \n        (byte 10) — distinct from Enter (\r), used for submit
  //   ctrlM == \r        (byte 13) — same byte as Enter
  ctrlA, // byte 1
  ctrlB, // byte 2
  ctrlC, // byte 3  — intercepted: triggers cleanup + exit
  ctrlD, // byte 4
  ctrlE, // byte 5
  ctrlF, // byte 6
  ctrlG, // byte 7
  ctrlH, // byte 8  — same as backspace in most terminals
  ctrlI, // byte 9  — same as tab in most terminals
  ctrlJ, // byte 10 — \n, distinct from Enter (\r); useful for "soft submit"
  ctrlK, // byte 11
  ctrlL, // byte 12
  ctrlM, // byte 13 — same byte as Enter; parser emits Key.enter instead
  ctrlN, // byte 14
  ctrlO, // byte 15
  ctrlP, // byte 16
  ctrlQ, // byte 17
  ctrlR, // byte 18
  ctrlS, // byte 19
  ctrlT, // byte 20
  ctrlU, // byte 21
  ctrlV, // byte 22
  ctrlW, // byte 23
  ctrlX, // byte 24
  ctrlY, // byte 25
  ctrlZ, // byte 26
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
