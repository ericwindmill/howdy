import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';
import 'package:howdy/src/terminal/theme.dart';

/// A multi-page form container.
///
/// Each page can be a [Group] (multiple widgets) or a single
/// [InteractiveWidget]. When a page completes, the form advances
/// to the next one. After all pages are done, returns [MultiWidgetResults].
///
/// ```dart
/// final results = Form([
///   Group([
///     Prompt(label: 'Name'),
///     Select(label: 'Language', options: [...]),
///   ]),
///   Multiselect(label: 'Features', options: [...]),
///   ConfirmInput(label: 'Use git?'),
/// ]).write();
/// ```
class Form extends MultiWidget {
  Form(super.widgets, {this.title}) {
    // Suppress inline error/chrome rendering — Form owns that display.
    for (final widget in widgets) {
      _setFormContext(widget);
    }
  }

  /// Optional title shown above each page.
  final String? title;

  int _pageIndex = 0;
  bool _isDone = false;

  /// Convenience to run a form and return results.
  static MultiWidgetResults send(List<Widget> pages, {String? title}) {
    return Form(pages, title: title).write();
  }

  /// The widget for the current page.
  Widget get _currentPage => widgets[_pageIndex];

  /// The currently focused interactive widget on the current page.
  ///
  /// For a [MultiWidget] page, this is the focused child.
  /// For a single [InteractiveWidget] page, that widget itself.
  InteractiveWidget? get _focusedWidget {
    final page = _currentPage;
    if (page is MultiWidget) {
      final focused = page.widgets[page.focusIndex];
      return focused is InteractiveWidget ? focused : null;
    }
    if (page is InteractiveWidget) return page;
    return null;
  }

  @override
  String build(IndentedStringBuffer buf) {
    final focused = _focusedWidget;
    final errorText = focused?.error;

    // Show title with page indicator
    buf.indent();
    if (title != null) {
      buf.writeln(
        '${title!.style(TextStyle(foreground: Color.greyLight))} '
        '${'(page ${_pageIndex + 1}/${widgets.length})'.dim}',
      );
      buf.writeln();
    }

    // Render each widget individually with a focus-aware left border.
    final page = _currentPage;
    final pageWidgets = page is MultiWidget ? page.widgets : [page];
    final focusIdx = page is MultiWidget ? page.focusIndex : 0;

    for (var i = 0; i < pageWidgets.length; i++) {
      final isFocused = i == focusIdx;
      final borderStyle = isFocused
          ? TextStyle(foreground: Color.white)
          : TextStyle(dim: true);
      buf.writeln(
        pageWidgets[i].render().withBorder(
          style: SignStyle.leftOnly,
          padding: EdgeInsets.only(left: 1),
          borderStyle: borderStyle,
        ),
      );
    }

    // ── Guide line ──
    buf.writeln(_guideTextFor(focused).dim);

    // ── Error line (from the focused widget) ──
    buf.writeln(
      errorText != null
          ? '${Icon.error} $errorText'.style(Theme.current.error)
          : '',
    );

    return buf.toString();
  }

  /// Returns context-appropriate guide text for the focused widget.
  String _guideTextFor(InteractiveWidget? focused) {
    return focused?.usage ?? '';
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (_isDone) return KeyResult.ignored;

    final result = _currentPage.handleKey(event);

    if (result == KeyResult.done) {
      // Page completed — advance to next
      if (_pageIndex < widgets.length - 1) {
        _pageIndex++;
        return KeyResult.consumed;
      } else {
        _isDone = true;
        return KeyResult.done;
      }
    }

    return result;
  }

  /// Recursively set [RenderContext.form] on all interactive widgets
  /// so they suppress their own standalone chrome.
  void _setFormContext(Widget widget) {
    if (widget is InteractiveWidget) {
      widget.renderContext = RenderContext.form;
    } else if (widget is MultiWidget) {
      for (final child in widget.widgets) {
        _setFormContext(child);
      }
    }
  }
}
