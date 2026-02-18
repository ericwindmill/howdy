import 'package:howdy/howdy.dart';

/// A multi-page form composed of [Group]s.
///
/// Form displays one [Group] (page) at a time. When a group completes,
/// the form advances to the next page. After all pages are done, the
/// form returns a list of results — one [List<Object?>] per group.
///
/// ```dart
/// final results = Form([
///   Group([
///     Prompt(label: 'Name'),
///     Select(label: 'Language', options: [...]),
///   ]),
///   Group([
///     Multiselect(label: 'Features', options: [...]),
///     ConfirmInput(label: 'Use git?'),
///   ]),
/// ]).render();
///
/// // results[0] -> [name, language]  (page 1)
/// // results[1] -> [features, git]   (page 2)
/// ```
class Form extends InputWidget<List<List<Object?>>> {
  Form(this.groups, {this.title});

  /// The groups (pages) in this form.
  final List<Group> groups;

  /// Optional title shown above each page.
  final String? title;

  int _pageIndex = 0;
  bool _isDone = false;

  /// Convenience to run a form and return results.
  static List<List<Object?>> send(List<Group> groups, {String? title}) {
    return Form(groups, title: title).write();
  }

  @override
  String build(StringBuffer buf) {
    final buf = StringBuffer();

    // Show title with page indicator
    if (title != null) {
      buf.write(
        renderSpans([
          StyledText('? ', style: TextStyle(foreground: Color.green)),
          StyledText(title!, style: TextStyle(bold: true)),
          StyledText(
            '  (page ${_pageIndex + 1}/${groups.length})',
            style: TextStyle(dim: true),
          ),
        ]),
      );
      buf.writeln();
    }

    // Render the current group
    buf.write(groups[_pageIndex].render());

    return buf.toString();
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (_isDone) return KeyResult.ignored;

    final currentGroup = groups[_pageIndex];
    final result = currentGroup.handleKey(event);

    if (result == KeyResult.done) {
      // Group completed — advance to next page
      if (_pageIndex < groups.length - 1) {
        _pageIndex++;
        return KeyResult.consumed;
      } else {
        _isDone = true;
        return KeyResult.done;
      }
    }

    return result;
  }

  @override
  List<List<Object?>> get value {
    return [for (final group in groups) group.value];
  }

  @override
  bool get isDone => _isDone;

  @override
  List<List<Object?>> write() {
    final buffer = ScreenBuffer();
    terminal.cursorHide();
    buffer.update(render());

    final result = terminal.runRawModeSync(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);

        if (keyResult == KeyResult.consumed || keyResult == KeyResult.done) {
          // Clear previous page output and render new state
          buffer.update(render());
        }

        if (keyResult == KeyResult.done) {
          return value;
        }
      }
    });

    terminal.cursorShow();
    return result;
  }

  @override
  String renderCompact() {
    if (title != null) {
      return '${renderSpans([StyledText(title!, style: TextStyle(bold: true)), StyledText('  (${groups.length} pages)', style: TextStyle(dim: true))])}\n';
    }
    return '${renderSpans([StyledText('Form', style: TextStyle(bold: true)), StyledText('  (${groups.length} pages)', style: TextStyle(dim: true))])}\n';
  }
}
