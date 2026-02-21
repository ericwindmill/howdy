/// Terminal cursor shape, controlled via ANSI escape sequences.
///
/// Each value carries its full escape sequence, including the
/// `ESC[?12h` blink-enable prefix for blinking variants.
/// Pass to [Terminal.setCursorShape].
enum CursorShape {
  /// Blinking block cursor (▋).
  blinkingBlock('\x1B[?12h\x1B[1 q'),

  /// Steady (non-blinking) block cursor (█).
  steadyBlock('\x1B[2 q'),

  /// Blinking underline cursor (_).
  blinkingUnderline('\x1B[?12h\x1B[3 q'),

  /// Steady underline cursor.
  steadyUnderline('\x1B[4 q'),

  /// Blinking bar cursor (|) — common IDE default.
  blinkingBar('\x1B[?12h\x1B[5 q'),

  /// Steady bar cursor.
  steadyBar('\x1B[6 q')
  ;

  const CursorShape(this.sequence);

  /// The full ANSI escape sequence for this cursor shape.
  final String sequence;
}
