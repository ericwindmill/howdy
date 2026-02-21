import 'package:howdy/src/framework/icons.dart';
import 'package:howdy/src/framework/keymap/key_binding.dart';
import 'package:howdy/src/framework/theme.dart';
import 'package:howdy/src/terminal/key_event.dart';
import 'package:howdy/src/terminal/styled_text.dart';

/// The default global keybindings used by all interactive widgets.
const defaultKeyMap = AppKeyMap();

/// Enforces KeyMap.usage()
abstract class KeyMap {
  const KeyMap();

  String get usage;
}

/// A centralized registry of default interactive keybindings.
class AppKeyMap implements KeyMap {
  const AppKeyMap({
    this.select = const ListSelectKeyMap(),
    this.multiSelect = const MultiSelectKeyMap(),
    this.input = const InputKeyMap(),
    this.page = const PageKeyMap(),
    this.form = const FormKeyMap(),
    this.confirm = const ConfirmKeyMap(),
    this.textArea = const TextAreaKeyMap(),
  });

  final ListSelectKeyMap select;
  final MultiSelectKeyMap multiSelect;
  final InputKeyMap input;
  final PageKeyMap page;
  final FormKeyMap form;
  final ConfirmKeyMap confirm;
  final TextAreaKeyMap textArea;

  @override
  String get usage => '';
}

/// Keybindings for navigating lists and options.
class ListKeyMap extends KeyMap {
  const ListKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.arrowDown)],
      helpKey: Icon.arrowDown,
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.arrowUp)],
      helpKey: Icon.arrowUp,
      helpDesc: 'prev',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;

  @override
  String get usage {
    return '${next.usage} ${Icon.dot} ${prev.usage}';
  }
}

/// Keybindings for [SelectInput].
class AllDirectionSelectKeyMap extends KeyMap {
  const AllDirectionSelectKeyMap({
    this.down = const KeyBinding(
      keys: [SpecialKey(Key.arrowDown)],
      helpKey: Icon.arrowDown,
      helpDesc: 'down',
    ),
    this.up = const KeyBinding(
      keys: [SpecialKey(Key.arrowUp)],
      helpKey: Icon.arrowUp,
      helpDesc: 'up',
    ),
    this.left = const KeyBinding(
      keys: [SpecialKey(Key.arrowLeft)],
      helpKey: Icon.arrowLeft,
      helpDesc: 'left',
    ),
    this.right = const KeyBinding(
      keys: [SpecialKey(Key.arrowRight)],
      helpKey: Icon.arrowRight,
      helpDesc: 'right',
    ),
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter), SpecialKey(Key.tab)],
      helpKey: 'enter/tab',
      helpDesc: 'select',
    ),
  });

  final KeyBinding up;
  final KeyBinding down;
  final KeyBinding left;
  final KeyBinding right;
  final KeyBinding submit;

  @override
  String get usage =>
      '${up.helpKey}/${down.helpKey} ${'move'.style(Theme.current.help.shortDesc)} '
      ' ${Icon.dot} ${left.usage} ${Icon.dot} ${right.usage} ${Icon.dot} ${submit.usage}';
}

/// Keybindings for [SelectInput].
class ListSelectKeyMap extends KeyMap {
  const ListSelectKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.arrowDown)],
      helpKey: Icon.arrowDown,
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.arrowUp)],
      helpKey: Icon.arrowUp,
      helpDesc: 'prev',
    ),
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter), SpecialKey(Key.tab)],
      helpKey: 'enter/tab',
      helpDesc: 'select',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;
  final KeyBinding submit;

  @override
  String get usage =>
      '${next.usage} ${Icon.dot} ${prev.usage} ${Icon.dot} ${submit.usage}';
}

/// Keybindings for [MultiSelectInput].
class MultiSelectKeyMap extends KeyMap {
  const MultiSelectKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.arrowDown)],
      helpKey: Icon.arrowDown,
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.arrowUp)],
      helpKey: Icon.arrowUp,
      helpDesc: 'prev',
    ),
    this.toggle = const KeyBinding(
      keys: [SpecialKey(Key.space)],
      helpKey: 'space',
      helpDesc: 'toggle',
    ),
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter), SpecialKey(Key.tab)],
      helpKey: 'enter/tab',
      helpDesc: 'confirm',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;
  final KeyBinding toggle;
  final KeyBinding submit;

  @override
  String get usage =>
      '${next.usage} ${Icon.dot} ${prev.usage} ${Icon.dot} ${toggle.usage} ${Icon.dot} ${submit.usage}';
}

/// Keybindings for [PromptInput] and [Textarea].
///
/// Single-line prompts use [submit] (Enter or Tab).
/// Multi-line textareas use [newline] for Enter and [submitTextarea]
/// (Ctrl+J) to advance — making both ergonomic without key conflicts.
///
/// Ctrl+J sends byte 10 (\n), which is reliably distinct from Enter (\r,
/// byte 13) in raw mode.  It's the closest cross-terminal equivalent to
/// "Ctrl+Enter" and is far more natural than Ctrl+D.
class InputKeyMap extends KeyMap {
  const InputKeyMap({
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter), SpecialKey(Key.tab)],
      helpKey: 'enter/tab',
      helpDesc: 'submit',
    ),
  });

  /// Single-line prompt submit (Enter or Tab).
  final KeyBinding submit;

  @override
  String get usage => submit.usage;
}

/// Ctrl+J sends byte 10 (\n), which is reliably distinct from Enter (\r,
/// byte 13) in raw mode.  It's the closest cross-terminal equivalent to
/// "Ctrl+Enter" and is far more natural than Ctrl+D.
class TextAreaKeyMap extends KeyMap {
  const TextAreaKeyMap({
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter), SpecialKey(Key.tab)],
      helpKey: 'tab',
      helpDesc: 'submit',
    ),
    this.newline = const KeyBinding(
      keys: [SpecialKey(Key.enter)],
      helpKey: 'enter',
      helpDesc: 'newline',
    ),
    this.submitTextarea = const KeyBinding(
      keys: [SpecialKey(Key.ctrlJ)],
      helpKey: 'ctrl+j',
      helpDesc: 'submit',
    ),
  });

  /// Single-line prompt submit (Enter or Tab).
  final KeyBinding submit;

  /// Newline in a textarea (Enter only).
  final KeyBinding newline;

  /// Multi-line textarea submit (Ctrl+J — acts as a soft "ctrl+enter").
  final KeyBinding submitTextarea;

  @override
  String get usage => '${newline.usage} ${Icon.dot} ${submit.usage}';
}

/// Keybindings for [NoteMultiwidget] and generic page navigation.
///
/// Tab = next, Shift+Tab = back. Enter also advances for convenience.
class PageKeyMap extends KeyMap {
  const PageKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.tab), SpecialKey(Key.enter)],
      helpKey: 'tab/enter',
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.shiftTab)],
      helpKey: 'shift+tab',
      helpDesc: 'back',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;

  @override
  String get usage => '${next.usage} ${Icon.dot} ${prev.usage}';
}

/// Keybindings for [Form].
///
/// Shift+Tab goes back between fields/pages — consistent with the
/// universal next/back convention used across all widgets.
class FormKeyMap extends KeyMap {
  const FormKeyMap({
    this.back = const KeyBinding(
      keys: [SpecialKey(Key.shiftTab)],
      helpKey: 'shift+tab',
      helpDesc: 'back',
    ),
  });

  final KeyBinding back;

  @override
  String get usage => back.usage;
}

/// Keybindings for [ConfirmInput].
///
/// Arrow keys toggle the selection; Enter or Tab submit.
/// 'y'/'n' shortcuts remain for fast keyboard-driven confirmation.
class ConfirmKeyMap extends KeyMap {
  const ConfirmKeyMap({
    this.toggle = const KeyBinding(
      keys: [SpecialKey(Key.arrowLeft), SpecialKey(Key.arrowRight)],
      helpKey: '${Icon.arrowLeft}/${Icon.arrowRight}',
      helpDesc: 'toggle',
    ),
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter), SpecialKey(Key.tab)],
      helpKey: 'enter/tab',
      helpDesc: 'confirm',
    ),
    this.accept = const KeyBinding(
      keys: [CharKey('y'), CharKey('Y')],
      helpKey: 'y',
      helpDesc: 'yes',
    ),
    this.reject = const KeyBinding(
      keys: [CharKey('n'), CharKey('N')],
      helpKey: 'n',
      helpDesc: 'no',
    ),
  });

  final KeyBinding toggle;
  final KeyBinding submit;
  final KeyBinding accept;
  final KeyBinding reject;

  @override
  String get usage => '${toggle.usage} ${Icon.dot} ${submit.usage}';
}
