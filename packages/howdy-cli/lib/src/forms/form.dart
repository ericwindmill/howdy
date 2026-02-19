import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/extensions.dart';

/// A multi-page form container.
///
/// Each page can be a [Group] (multiple widgets) or a single
/// [InteractiveWidget]. When a page completes, the form advances
/// to the next one. After all pages are done, returns [MultiWidgetResults].
///
/// Navigation:
/// - Enter / Tab: advance within a page or to the next page.
/// - ← (left-arrow), when not consumed by the focused widget: go back
///   one page (resets the previous page so it can be re-edited).
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
    final t = Theme.current;

    // ── Title ──
    buf.indent();
    if (title != null) {
      buf.writeln(
        '${title!.style(t.group.title)} '
        '${'(page ${_pageIndex + 1}/${widgets.length})'.style(t.group.description)}',
      );
      buf.writeln();
    }

    // ── Page widgets with focus-aware left border ──
    final page = _currentPage;
    final pageWidgets = page is MultiWidget ? page.widgets : [page];
    final focusIdx = page is MultiWidget ? page.focusIndex : 0;

    for (var i = 0; i < pageWidgets.length; i++) {
      final isFocused = i == focusIdx;
      final widget = pageWidgets[i];
      if (widget is InteractiveWidget) {
        widget.isFocused = isFocused;
      }
      final style = isFocused ? t.focused : t.blurred;

      // Inject a red asterisk on the first content line when the widget
      // has an error, so the error is visible at a glance even when unfocused.
      var rendered = widget.render();
      final hasWidgetError = widget is InteractiveWidget && widget.hasError;
      if (hasWidgetError) {
        rendered = _injectErrorMarker(rendered, t);
      }

      buf.writeln(
        rendered.withBorder(
          borderType: BorderType.leftOnly,
          padding: EdgeInsets.only(left: 1),
          borderStyle: style.base,
        ),
      );
    }

    // ── Guide line ──
    buf.writeln(_guideTextFor(focused));

    // ── Error line (from the focused widget) ──
    buf.writeln(
      errorText != null
          ? '${Icon.error} $errorText'.style(t.focused.errorMessage)
          : '',
    );

    return buf.toString();
  }

  /// Appends a red asterisk to the first non-blank visible line.
  String _injectErrorMarker(String rendered, Theme t) {
    final lines = rendered.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (stripAnsi(lines[i]).trim().isNotEmpty) {
        lines[i] =
            '${lines[i]} ${Icon.asterisk.style(t.focused.errorIndicator)}';
        break;
      }
    }
    return lines.join('\n');
  }

  /// Returns the styled usage text for the focused widget, with a back hint
  /// appended when the user can go back.
  String _guideTextFor(InteractiveWidget? focused) {
    final base = focused?.usage ?? '';
    if (_pageIndex > 0) {
      final t = Theme.current;
      final dot = Icon.dot.style(t.help.shortSeparator);
      final backHint =
          '${'b'.style(t.help.shortKey)} ${'back'.style(t.help.shortDesc)}';
      return base.isEmpty ? backHint : '$base  $dot  $backHint';
    }
    return base;
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (_isDone) return KeyResult.ignored;

    // ── Back navigation ──
    // 'b' goes back one page and resets it for re-editing.
    if (event case CharKey(char: 'b') when _pageIndex > 0) {
      _pageIndex--;
      _currentPage.reset();
      return KeyResult.consumed;
    }

    final result = _currentPage.handleKey(event);

    if (result == KeyResult.done) {
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
