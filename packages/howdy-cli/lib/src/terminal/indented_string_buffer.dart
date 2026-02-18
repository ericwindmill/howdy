import 'dart:math';

import 'package:howdy/src/terminal/word_wrap.dart';

/// A [StringBuffer] that automatically prepends indentation.
///
/// Use [indent] and [dedent] to adjust the current level.
/// All [writeln] calls prepend the current indentation prefix.
///
/// Optionally set [maxWidth] to automatically word-wrap content so that
/// `indent + content` never exceeds that many characters per line.
///
/// ```dart
/// final buf = IndentedStringBuffer(maxWidth: 40);
/// buf.writeln('Title');
/// buf.indent();
/// buf.writeln('A long line that will be wrapped automatically');
/// buf.dedent();
/// ```
class IndentedStringBuffer extends StringBuffer {
  IndentedStringBuffer({this.indentUnit = '  ', this.maxWidth});

  /// The string used for one indent level (default: two spaces).
  final String indentUnit;

  /// Optional maximum line width (including indent prefix).
  ///
  /// When set, content passed to [write] and [writeln] is word-wrapped
  /// so that no line exceeds this width. The indent prefix width is
  /// subtracted from the available content width automatically.
  final int? maxWidth;

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

  /// The number of characters available for content on the current line,
  /// accounting for the indent prefix. Returns `null` if [maxWidth] is unset.
  int? get _availableWidth {
    final max = maxWidth;
    if (max == null) return null;
    return (max - _prefix.length).clamp(1, max);
  }

  @override
  void write(Object? object) {
    final str = object.toString();
    if (str.isEmpty) return;

    final available = _availableWidth;

    // If no maxWidth, write lines directly with indent prefix.
    if (available == null) {
      _writeLines(str.split('\n'));
      return;
    }

    // Word-wrap each hard-newline segment to the available width.
    final segments = str.split('\n');
    final wrapped = <String>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) wrapped.add(''); // preserve hard newline boundary
      if (segments[i].isEmpty) continue;
      wrapped.addAll(wordWrap(segments[i], available));
    }
    _writeLines(wrapped);
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
