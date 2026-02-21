import 'package:howdy/howdy.dart';

/// A display widget that renders a bulleted list using [Icon.dot] as the marker.
///
/// Supports scrolling with ↑/↓ arrow keys when rendered via [write()].
/// The visible window is controlled by [maxVisibleRows]; ellipsis lines
/// (`...`) appear above/below when the list is clipped.
///
/// ```dart
/// BulletList(
///   items: ['Eggs', 'Milk', 'Butter'],
///   title: 'Shopping list',
/// ).write();
/// ```
///
/// Output:
/// ```
/// Shopping list
/// · Eggs
/// · Milk
/// · Butter
/// ```
class BulletList extends DisplayWidget {
  BulletList({
    required this.items,
    super.title,
    this.maxVisibleRows = 10,
    this.markerStyle,
    this.itemStyle,
    super.key,
    super.theme,
  }) : _offset = 0;

  /// Convenience method — creates and immediately writes a [BulletList].
  static void send(
    List<String> items, {
    String? title,
    int maxVisibleRows = 10,
    TextStyle? markerStyle,
    TextStyle? itemStyle,
  }) {
    BulletList(
      items: items,
      title: title,
      maxVisibleRows: maxVisibleRows,
      markerStyle: markerStyle,
      itemStyle: itemStyle,
    ).write();
  }

  /// The items to display.
  final List<String> items;

  /// Maximum number of items visible at once. Defaults to 10.
  final int maxVisibleRows;

  /// Style applied to the `·` marker. Defaults to the theme's description style.
  final TextStyle? markerStyle;

  /// Style applied to each item label. Defaults to the theme's base style.
  final TextStyle? itemStyle;

  /// Current scroll offset (index of the first visible item).
  int _offset;

  /// Handles ↑/↓ arrow key scroll events.
  ///
  /// Returns [KeyResult.consumed] if the offset changed,
  /// [KeyResult.ignored] for any other key.
  @override
  KeyResult handleKey(KeyEvent event) {
    if (event is SpecialKey) {
      if (event.key == Key.arrowDown &&
          _offset + maxVisibleRows < items.length) {
        _offset++;
        return KeyResult.consumed;
      } else if (event.key == Key.arrowUp && _offset > 0) {
        _offset--;
        return KeyResult.consumed;
      }
    }
    return KeyResult.ignored;
  }

  @override
  String build(IndentedStringBuffer buf) {
    if (title != null) {
      buf.writeln(title!.style(theme.focused.title));
    }

    if (items.isEmpty) {
      buf.writeln('  (empty)'.style(theme.blurred.description));
      return buf.toString();
    }

    final end = (_offset + maxVisibleRows).clamp(0, items.length);

    // Ellipsis above
    if (_offset > 0) {
      buf.writeln('  ...'.style(theme.blurred.description));
    }

    final markerSty = markerStyle ?? theme.focused.description;
    final itemSty = itemStyle ?? theme.focused.base;

    for (var i = _offset; i < end; i++) {
      final marker = Icon.dot.style(markerSty);
      final label = items[i].style(itemSty);
      buf.writeln('$marker $label');
    }

    // Ellipsis below
    if (end < items.length) {
      buf.writeln('  ...'.style(theme.blurred.description));
    }

    return buf.toString();
  }

  @override
  void write() {
    if (items.isEmpty || items.length <= maxVisibleRows) {
      // No scrolling needed — just print and return.
      terminal.write(render());
      return;
    }

    terminal.cursorHide();
    terminal.updateScreen(render());

    terminal.runRawModeSync<void>(() {
      while (true) {
        final event = terminal.readKeySync();

        if (event is SpecialKey) {
          switch (event.key) {
            case Key.arrowDown:
            case Key.arrowUp:
              final result = handleKey(event);
              if (result == KeyResult.consumed) {
                terminal.updateScreen(render());
              }
            case Key.enter:
            case Key.escape:
              return;
            default:
              break;
          }
        } else if (event is CharKey && event.char == 'q') {
          return;
        }
      }
    });

    terminal.clearScreen();
    terminal.write(render());
    terminal.cursorShow();
  }
}
