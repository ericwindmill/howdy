import 'package:howdy/src/terminal/key_event.dart';

/// A set of keys that trigger a specific action, along with help text.
class KeyBinding {
  const KeyBinding({
    required this.keys,
    required this.helpKey,
    required this.helpDesc,
  });

  /// The keys that trigger this binding.
  final List<KeyEvent> keys;

  /// The short key text to display in help (e.g. "enter").
  final String helpKey;

  /// The description of the action (e.g. "submit").
  final String helpDesc;

  /// Returns true if the given [event] matches any key in this binding.
  bool matches(KeyEvent event) => keys.contains(event);
}

/// Keybindings for navigating lists and options.
class ListKeyMap {
  const ListKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.arrowDown), SpecialKey(Key.tab), CharKey('j')],
      helpKey: '↓/j',
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.arrowUp), SpecialKey(Key.shiftTab), CharKey('k')],
      helpKey: '↑/k',
      helpDesc: 'prev',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;
}

/// Keybindings for [SelectInput].
class SelectKeyMap {
  const SelectKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.arrowDown), SpecialKey(Key.tab), CharKey('j')],
      helpKey: '↓/j',
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.arrowUp), SpecialKey(Key.shiftTab), CharKey('k')],
      helpKey: '↑/k',
      helpDesc: 'prev',
    ),
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter)],
      helpKey: 'enter',
      helpDesc: 'submit',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;
  final KeyBinding submit;
}

/// Keybindings for [MultiSelectInput].
class MultiSelectKeyMap {
  const MultiSelectKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.arrowDown), SpecialKey(Key.tab), CharKey('j')],
      helpKey: '↓/j',
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.arrowUp), SpecialKey(Key.shiftTab), CharKey('k')],
      helpKey: '↑/k',
      helpDesc: 'prev',
    ),
    this.toggle = const KeyBinding(
      keys: [SpecialKey(Key.space), CharKey('x')],
      helpKey: 'space/x',
      helpDesc: 'toggle',
    ),
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter)],
      helpKey: 'enter',
      helpDesc: 'submit',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;
  final KeyBinding toggle;
  final KeyBinding submit;
}

/// Keybindings for [PromptInput] and [Textarea].
class InputKeyMap {
  const InputKeyMap({
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter)],
      helpKey: 'enter',
      helpDesc: 'submit',
    ),
    this.submitTextarea = const KeyBinding(
      keys: [SpecialKey(Key.ctrlD)],
      helpKey: 'ctrl+d',
      helpDesc: 'submit',
    ),
  });

  final KeyBinding submit;

  /// Multi-line textareas use a different key to submit.
  final KeyBinding submitTextarea;
}

/// Keybindings for [NoteMultiwidget] and generic page navigation.
class PageKeyMap {
  const PageKeyMap({
    this.next = const KeyBinding(
      keys: [SpecialKey(Key.tab), SpecialKey(Key.enter)],
      helpKey: 'tab/enter',
      helpDesc: 'next',
    ),
    this.prev = const KeyBinding(
      keys: [SpecialKey(Key.shiftTab)],
      helpKey: 'shift+tab',
      helpDesc: 'prev',
    ),
  });

  final KeyBinding next;
  final KeyBinding prev;
}

/// Keybindings for [Form].
class FormKeyMap {
  const FormKeyMap({
    this.back = const KeyBinding(
      keys: [CharKey('b')],
      helpKey: 'b',
      helpDesc: 'back',
    ),
  });

  final KeyBinding back;
}

/// Keybindings for [ConfirmButton].
class ConfirmKeyMap {
  const ConfirmKeyMap({
    this.toggle = const KeyBinding(
      keys: [
        SpecialKey(Key.arrowLeft),
        SpecialKey(Key.arrowRight),
        CharKey('h'),
        CharKey('l'),
      ],
      helpKey: '←/→',
      helpDesc: 'toggle',
    ),
    this.submit = const KeyBinding(
      keys: [SpecialKey(Key.enter)],
      helpKey: 'enter',
      helpDesc: 'submit',
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
}

/// A centralized registry of default interactive keybindings.
class KeyMap {
  const KeyMap({
    this.select = const SelectKeyMap(),
    this.multiSelect = const MultiSelectKeyMap(),
    this.input = const InputKeyMap(),
    this.page = const PageKeyMap(),
    this.form = const FormKeyMap(),
    this.confirm = const ConfirmKeyMap(),
  });

  final SelectKeyMap select;
  final MultiSelectKeyMap multiSelect;
  final InputKeyMap input;
  final PageKeyMap page;
  final FormKeyMap form;
  final ConfirmKeyMap confirm;
}

/// The default global keybindings used by all interactive widgets.
const defaultKeyMap = KeyMap();
