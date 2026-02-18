import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/theme.dart';

/// A MultiWidget renders its children with a unified UI.
///
/// Form displays one [Group] at a time. When a group completes,
/// the form advances to the next page. After all pages are done, the
/// form returns MultiWidgetResults, which has a
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
class Form extends MultiWidget {
  Form(super.widgets, {this.title}) {
    // Suppress inline error rendering — Form owns the error display.
    for (final group in groups) {
      for (final widget in group.widgets) {
        if (widget is InteractiveWidget) {
          widget.renderContext = RenderContext.form;
        }
      }
    }
  }

  /// Optional title shown above each page.
  final String? title;

  int _pageIndex = 0;
  bool _isDone = false;

  /// Typed view of [widgets] as [Group]s.
  List<Group> get groups => widgets.cast<Group>();

  /// Convenience to run a form and return results.
  static MultiWidgetResults send(List<Group> groups, {String? title}) {
    return Form(groups, title: title).write();
  }

  @override
  String build(StringBuffer buf) {
    // Show title with page indicator
    if (title != null) {
      buf.write(
        '${title!.label}'
        '${'(page ${_pageIndex + 1}/${widgets.length})'.dim}',
      );
      buf.writeln();
    }

    // Render the current group
    buf.write(groups[_pageIndex].render());

    // ── Error line (from the focused widget) ──
    final currentGroup = groups[_pageIndex];
    final focused = currentGroup.widgets[currentGroup.focusIndex];
    final errorText = (focused is InteractiveWidget) ? focused.error : null;
    buf.writeln(
      errorText != null
          ? '${Icon.error} $errorText'.style(Theme.current.error)
          : '',
    );

    // ── Guide line with page indicator ──
    buf.write(
      '${_guideTextFor(focused).dim}  ${'${_pageIndex + 1}/${widgets.length}'.dim}',
    );

    return buf.toString();
  }

  /// Returns context-appropriate guide text for the focused widget.
  String _guideTextFor(Widget focused) {
    if (focused is InteractiveWidget) {
      return focused.usage;
    }
    return '';
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
}
