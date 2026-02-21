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

class NoActionKeyMap extends KeyMap {
  @override
  String get usage => '';
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
    this.filePicker = const FilePickerKeyMap(),
  });

  final ListSelectKeyMap select;
  final MultiSelectKeyMap multiSelect;
  final InputKeyMap input;
  final PageKeyMap page;
  final FormKeyMap form;
  final ConfirmKeyMap confirm;
  final TextAreaKeyMap textArea;
  final FilePickerKeyMap filePicker;

  @override
  String get usage => '';
}

/// Keybindings for navigating lists that don't expect a selection.
/// Used by [BulletList],
class ListKeyMap extends KeyMap {
  const ListKeyMap({
    this.down = KeyBinding.down,
    this.up = KeyBinding.up,
  });

  final KeyBinding down;
  final KeyBinding up;

  @override
  String get usage {
    return '${up.usage} ${Icon.dot} ${down.usage}';
  }
}

/// Keybindings for navigating lists that expect a selection.
/// Used by [Select].
class ListSelectKeyMap extends KeyMap {
  const ListSelectKeyMap({
    this.down = KeyBinding.down,
    this.up = KeyBinding.up,
    this.submit = KeyBinding.enterTabSubmit,
  });

  final KeyBinding down;
  final KeyBinding up;
  final KeyBinding submit;

  @override
  String get usage =>
      '${down.helpKey}/${up.helpKey} navigate ${Icon.dot} ${submit.usage}';
}

/// Keybindings for navigating in 4 directions that expect a selection.
/// Used by [FilePicker].
class DirectionalSelectKeyMap extends KeyMap {
  const DirectionalSelectKeyMap({
    this.down = KeyBinding.down,
    this.up = KeyBinding.up,
    this.left = KeyBinding.left,
    this.right = KeyBinding.right,
    this.submit = KeyBinding.enterTabSubmit,
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

/// Keybindings for [MultiSelectInput].
class MultiSelectKeyMap extends KeyMap {
  const MultiSelectKeyMap({
    this.down = KeyBinding.down,
    this.up = KeyBinding.up,
    this.submit = KeyBinding.enterTabSubmit,
    this.toggle = KeyBinding.spaceSelect,
  });

  final KeyBinding down;
  final KeyBinding up;
  final KeyBinding toggle;
  final KeyBinding submit;

  @override
  String get usage =>
      '${down.usage} ${Icon.dot} ${up.usage} ${Icon.dot} ${toggle.usage} ${Icon.dot} ${submit.usage}';
}

/// Keybindings for [PromptInput]
class InputKeyMap extends KeyMap {
  const InputKeyMap({this.submit = KeyBinding.enterTabSubmit});

  /// Single-line prompt submit (Enter or Tab).
  final KeyBinding submit;

  @override
  String get usage => submit.usage;
}

/// Keybindings for [Textarea].
///
/// Enter inserts a newline. Tab or Ctrl+J submits.
/// Ctrl+J (byte 10, \n) is reliably distinct from Enter (\r, byte 13)
/// in raw mode — the closest cross-terminal equivalent to "Ctrl+Enter".
class TextAreaKeyMap extends KeyMap {
  const TextAreaKeyMap({
    this.submit = KeyBinding.tabSubmit,
    this.newline = KeyBinding.newline,
    this.submitAlt = KeyBinding.ctrlJSubmit,
  });

  /// Submit the textarea (Tab).
  final KeyBinding submit;

  /// Insert a newline (Enter).
  final KeyBinding newline;

  /// Alternative submit via Ctrl+J.
  final KeyBinding submitAlt;

  @override
  String get usage => '${newline.usage} ${Icon.dot} ${submit.usage}';
}

/// Keybindings for [FilePicker].
///
/// Up/Down navigates the file list. Right enters a directory, Left goes to the
/// parent. Enter or Tab selects the currently highlighted item.
class FilePickerKeyMap extends KeyMap {
  const FilePickerKeyMap({
    this.down = KeyBinding.down,
    this.up = KeyBinding.up,
    this.stepIn = const KeyBinding(
      keys: [SpecialKey(Key.arrowRight)],
      helpKey: Icon.arrowRight,
      helpDesc: 'step in',
    ),
    this.parent = const KeyBinding(
      keys: [SpecialKey(Key.arrowLeft)],
      helpKey: Icon.arrowLeft,
      helpDesc: 'parent',
    ),
    this.submit = KeyBinding.enterTabSubmit,
  });

  /// Navigate down the list.
  final KeyBinding down;

  /// Navigate up the list.
  final KeyBinding up;

  /// Enter a directory (ArrowRight).
  final KeyBinding stepIn;

  /// Go to the parent directory (ArrowLeft).
  final KeyBinding parent;

  /// Select the highlighted file (Enter or Tab).
  final KeyBinding submit;

  @override
  String get usage =>
      '${up.usage} ${Icon.dot} ${down.usage} ${Icon.dot} ${stepIn.usage} ${Icon.dot} ${parent.usage} ${Icon.dot} ${submit.usage}';
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
    this.submit = KeyBinding.enterTabSubmit,
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
