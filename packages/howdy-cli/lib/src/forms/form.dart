import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/theme.dart';

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
class Form extends InteractiveWidget<List<List<Object?>>> {
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
    // Show title with page indicator
    if (title != null) {
      buf.write(
        '${title!.style(Theme.current.title)}  ${'(page ${_pageIndex + 1}/${groups.length})'.dim}',
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
    terminal.cursorHide();
    terminal.updateScreen(render());

    final result = terminal.runRawModeSync(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);

        if (keyResult == KeyResult.consumed || keyResult == KeyResult.done) {
          terminal.updateScreen(render());
        }

        if (keyResult == KeyResult.done) {
          return value;
        }
      }
    });

    terminal.clearScreen();
    terminal.write(render());
    terminal.cursorShow();
    return result;
  }

  @override
  String renderCompact() {
    if (title != null) {
      return '${title!.style(Theme.current.title)}  ${'(${groups.length} pages)'.dim}\n';
    }
    return '${'Form'.style(Theme.current.title)}  ${'(${groups.length} pages)'.dim}\n';
  }
}
