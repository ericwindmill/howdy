import 'package:howdy/howdy.dart';
import 'package:howdy/src/terminal/wrap.dart';

/// A multi-page form container.
///
/// Each page can be a [Page] (multiple widgets) or a single
/// [InputWidget]. When a page completes, the form advances
/// to the next one. After all pages are done, returns [MultiWidgetResults].
///
/// Navigation:
/// - Enter / Tab: advance within a page or to the next page.
/// - Shift+Tab: go back one page (resets the previous page so it can be re-edited).
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
  Form(super.title, {FormKeyMap? keymap, required super.children})
    : keymap = keymap ?? defaultKeyMap.form {
    // Suppress inline error/chrome rendering — Form owns that display.
    for (final widget in children) {
      _setFormContext(widget);
    }
  }

  /// Optional title shown above each page.
  @override
  final FormKeyMap keymap;

  int _pageIndex = 0;
  bool _isDone = false;

  /// Convenience to run a form and return results.
  static MultiWidgetResults send(
    List<Widget> children, {
    String? title,
    FormKeyMap? keymap,
  }) {
    final widget = Form(
      title ?? '',
      children: children,
      keymap: keymap,
    );

    widget.write();
    return widget.value;
  }

  /// The widget for the current page.
  Widget get _currentPage => children[_pageIndex];

  /// The currently focused interactive widget on the current page.
  ///
  /// For a [MultiWidget] page, this is the focused child.
  /// For a single [InputWidget] page, that widget itself.
  InputWidget? get _focusedWidget {
    final page = _currentPage;
    if (page is MultiWidget) {
      final idx = page.focusIndex;
      if (idx >= page.children.length) return null;
      final focused = page.children[idx];
      return focused is InputWidget ? focused : null;
    }
    if (page is InputWidget) return page;
    return null;
  }

  @override
  String build(IndentedStringBuffer buf) {
    final focused = _focusedWidget;
    final errorText = focused?.error;

    // ── Title ──
    buf.indent();
    if (title != null) {
      buf.writeln(
        '${title!.style(Theme.current.group.title)} '
        '${'(page ${_pageIndex + 1}/${children.length})'.style(
          Theme.current.group.description,
        )}',
      );
      buf.writeln();
    }

    // ── Page widgets with focus-aware left border ──
    final page = _currentPage;
    buf = switch (page) {
      Note note => _handleNote(buf, note),
      MultiWidget mw => _handlePage(buf, mw),
      Widget widget => _handleWidget(buf, widget),
    };

    // ── Guide line ──
    buf.writeln(_guideTextFor(focused));

    // ── Error line (from the focused widget) ──
    buf.writeln(
      errorText != null
          ? '${Icon.error} $errorText'.style(
              Theme.current.focused.errorMessage,
            )
          : '',
    );

    return buf.toString();
  }

  /// Appends a red asterisk to the first non-blank visible line.
  String _injectErrorMarker(String rendered, Theme t) {
    final lines = rendered.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].stripAnsi().trim().isNotEmpty) {
        lines[i] =
            '${lines[i]} ${Icon.asterisk.style(t.focused.errorIndicator)}';
        break;
      }
    }
    return lines.join('\n');
  }

  /// Returns the styled usage text for the focused widget, with a back hint
  /// appended when the user can go back.
  String _guideTextFor(InputWidget? focused) {
    final base = focused?.usage ?? '';
    if (_pageIndex > 0) {
      final t = Theme.current;
      final dot = Icon.dot.style(t.help.shortSeparator);
      final backHint =
          '${keymap.back.helpKey.style(t.help.shortKey)} ${keymap.back.helpDesc.style(t.help.shortDesc)}';
      return base.isEmpty ? backHint : '$base $dot $backHint';
    }
    return base;
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (_isDone) return KeyResult.ignored;

    // Delegate to the current page first so it can handle within-page
    // back navigation. Only go back to the previous page when the page
    // itself has no previous field (returns ignored for the back event).
    final result = _currentPage.handleKey(event);

    if (result == KeyResult.ignored &&
        keymap.back.matches(event) &&
        _pageIndex > 0) {
      _pageIndex--;
      _currentPage.reset();
      return KeyResult.consumed;
    }

    if (result == KeyResult.done) {
      if (_pageIndex < children.length - 1) {
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
    if (widget is InputWidget) {
      widget.renderContext = RenderContext.form;
    } else if (widget is MultiWidget) {
      for (final child in widget.children) {
        _setFormContext(child);
      }
    }
  }

  IndentedStringBuffer _handleNote(IndentedStringBuffer buf, Note note) {
    final pageWidgets = note.children;
    final focusIdx = note.focusIndex;

    for (var i = 0; i < pageWidgets.length; i++) {
      final isFocused = i == focusIdx;
      final widget = pageWidgets[i];
      if (widget is InputWidget) {
        widget.isFocused = isFocused;
      }

      // Inject a red asterisk on the first content line when the widget
      // has an error, so the error is visible at a glance even when unfocused.
      var rendered = widget.render();
      final hasWidgetError = widget is InputWidget && widget.hasError;
      if (hasWidgetError) {
        rendered = _injectErrorMarker(rendered, Theme.current);
      }

      buf.writeln(rendered);
    }
    return buf;
  }

  IndentedStringBuffer _handlePage(
    IndentedStringBuffer buf,
    MultiWidget page,
  ) {
    final pageWidgets = page.children;
    final focusIdx = page.focusIndex;

    for (var i = 0; i < pageWidgets.length; i++) {
      final isFocused = i == focusIdx;
      final widget = pageWidgets[i];
      if (widget is InputWidget) {
        widget.isFocused = isFocused;
      }
      final style = isFocused ? Theme.current.focused : Theme.current.blurred;

      // Inject a red asterisk on the first content line when the widget
      // has an error, so the error is visible at a glance even when unfocused.
      var rendered = widget.render();
      final hasWidgetError = widget is InputWidget && widget.hasError;
      if (hasWidgetError) {
        rendered = _injectErrorMarker(rendered, Theme.current);
      }

      buf.writeln(
        Border.wrap(
          rendered,
          borderType: BorderType.leftOnly,
          padding: EdgeInsets.only(left: 1),
          borderStyle: style.base,
        ),
      );
    }
    return buf;
  }

  IndentedStringBuffer _handleWidget(IndentedStringBuffer buf, Widget widget) {
    if (widget is InputWidget) {
      widget.isFocused = true;
    }

    // Inject a red asterisk on the first content line when the widget
    // has an error, so the error is visible at a glance even when unfocused.
    var rendered = widget.render();
    final hasWidgetError = widget is InputWidget && widget.hasError;
    if (hasWidgetError) {
      rendered = _injectErrorMarker(rendered, Theme.current);
    }

    buf.writeln(
      Border.wrap(
        rendered,
        borderType: BorderType.leftOnly,
        padding: EdgeInsets.only(left: 1),
        borderStyle: Theme.current.focused.base,
      ),
    );
    return buf;
  }
}
