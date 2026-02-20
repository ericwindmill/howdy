import 'dart:math';

/// A [StringBuffer] that automatically prepends indentation.
///
/// Use [indent] and [dedent] to adjust the current level.
/// All [writeln] calls prepend the current indentation prefix.
///
/// ```dart
/// final buf = IndentedStringBuffer();
/// buf.writeln('Title');
/// buf.indent();
/// buf.writeln('A long line of text');
/// buf.dedent();
/// ```
class IndentedStringBuffer extends StringBuffer {
  IndentedStringBuffer({this.indentUnit = '  '});

  /// The string used for one indent level (default: two spaces).
  final String indentUnit;

  /// Current indent depth.
  int _level = 0;

  /// Whether the cursor is at the start of a new line.
  bool _atLineStart = true;

  /// Increase indent by [levels] (default 1).
  void indent([int levels = 1]) {
    _level += levels;
  }

  /// Decrease indent by [levels] (default 1). Clamps to 0.
  void dedent([int levels = 1]) {
    _level = max(0, _level - levels);
  }

  String get _prefix => indentUnit * _level;

  @override
  void write(Object? object) {
    final str = object.toString();
    if (str.isEmpty) return;
    _writeLines(str.split('\n'));
  }

  void _writeLines(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      if (i > 0) {
        super.write('\n');
        _atLineStart = true;
      }
      if (lines[i].isNotEmpty) {
        if (_atLineStart) super.write(_prefix);
        super.write(lines[i]);
        _atLineStart = false;
      }
    }
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void writeln([Object? object = '']) {
    write(object);
    super.write('\n');
    _atLineStart = true;
  }
}
