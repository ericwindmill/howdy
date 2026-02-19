abstract class Icon {
  static const String check = '✔';
  static const String pointer = '❯';
  static const String error = '✘';
  static const String warning = '!';
  static const String optionFilled = '◉';
  static const String optionEmpty = '◯';
  static const String question = '?';

  // ── Directional ────────────────────────────────────────────────────────────
  static const String arrowLeft = '←';
  static const String arrowRight = '→';
  static const String arrowUp = '↑';
  static const String arrowDown = '↓';

  // ── Separators ─────────────────────────────────────────────────────────────
  /// Middle dot — used as a separator in usage hint strings.
  static const String dot = '·';

  // ── Decoration ─────────────────────────────────────────────────────────────
  static const String asterisk = '*';

  /// Spinner animation frames.
  static List<String> spinnerFrames = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];
}
