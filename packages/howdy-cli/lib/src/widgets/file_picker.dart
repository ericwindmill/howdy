import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:howdy/howdy.dart';

class FilePicker extends InteractiveWidget<File> {
  FilePicker({
    required super.label,
    SelectKeyMap? keymap,
    this.initialDirectory,
    super.help,
    super.validator,
    super.key,
    super.theme,
  }) : keymap = keymap ?? defaultKeyMap.select {
    _currentDir = Directory(initialDirectory ?? Directory.current.path);
    _loadDirectory();
  }

  static File send({
    required String label,
    SelectKeyMap? keymap,
    String? initialDirectory,
    String? help,
    Validator<File>? validator,
  }) {
    return FilePicker(
      label: label,
      keymap: keymap,
      initialDirectory: initialDirectory,
      help: help,
      validator: validator,
    ).write();
  }

  final String? initialDirectory;
  final SelectKeyMap keymap;

  late Directory _currentDir;
  List<FileSystemEntity> _entities = [];
  int _selectedIndex = 0;
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

  @override
  String get usage => usageHint([
    (keys: '${keymap.prev.helpKey}/${keymap.next.helpKey}', action: 'navigate'),
    (keys: Icon.arrowRight, action: 'open dir'),
    (keys: Icon.arrowLeft, action: 'parent dir'),
    (keys: keymap.submit.helpKey, action: 'select file'),
  ]);

  void _loadDirectory() {
    if (!_currentDir.existsSync()) {
      _entities = [];
      _selectedIndex = 0;
      return;
    }

    try {
      _entities = _currentDir.listSync();
    } catch (e) {
      _entities = [];
    }

    _entities.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return p.basename(a.path).compareTo(p.basename(b.path));
    });

    if (_entities.isNotEmpty && _selectedIndex >= _entities.length) {
      _selectedIndex = _entities.length - 1;
    } else if (_entities.isEmpty) {
      _selectedIndex = 0;
    }
  }

  @override
  KeyResult handleKey(KeyEvent event) {
    if (keymap.prev.matches(event)) {
      if (_selectedIndex > 0) {
        _selectedIndex--;
        return KeyResult.consumed;
      }
    } else if (keymap.next.matches(event)) {
      if (_selectedIndex < _entities.length - 1) {
        _selectedIndex++;
        return KeyResult.consumed;
      }
    } else if (event is SpecialKey && event.key == Key.arrowRight) {
      // Navigate into dir
      if (_entities.isNotEmpty) {
        final selected = _entities[_selectedIndex];
        if (selected is Directory) {
          _currentDir = selected;
          _selectedIndex = 0;
          _loadDirectory();
          return KeyResult.consumed;
        }
      }
    } else if (event is SpecialKey && event.key == Key.arrowLeft) {
      // Navigate up dir
      final parent = _currentDir.parent;
      if (parent.path != _currentDir.path) {
        _currentDir = parent;
        _selectedIndex = 0;
        _loadDirectory();
        return KeyResult.consumed;
      }
    } else if (keymap.submit.matches(event)) {
      if (_entities.isEmpty) return KeyResult.ignored;

      final selected = _entities[_selectedIndex];
      if (selected is Directory) {
        // Enter directory on Enter key as well
        _currentDir = selected;
        _selectedIndex = 0;
        _loadDirectory();
        return KeyResult.consumed;
      } else if (selected is File) {
        if (validator != null) {
          final err = validator!(selected);
          if (err != null) {
            error = err;
            return KeyResult.consumed;
          }
        }
        error = null;
        _isDone = true;
        return KeyResult.done;
      }
    }
    return KeyResult.ignored;
  }

  @override
  File get value {
    if (_entities.isEmpty) throw StateError('No file selected');
    return _entities[_selectedIndex] as File;
  }

  @override
  String build(IndentedStringBuffer buf) {
    buf.writeln(label.style(fieldStyle.title));
    if (help != null) buf.writeln(help!.style(fieldStyle.description));

    buf.writeln(p.normalize(_currentDir.path).style(theme.focused.description));

    if (_entities.isEmpty) {
      buf.writeln('  <empty directory>'.style(theme.blurred.description));
    } else {
      // Limit to max 10 to avoid screen overflow for now
      final start = (_selectedIndex ~/ 10) * 10;
      final end = (start + 10).clamp(0, _entities.length);

      if (start > 0) buf.writeln('  ...'.style(theme.blurred.description));

      for (var i = start; i < end; i++) {
        final entity = _entities[i];
        final isSelected = i == _selectedIndex;
        final name = p.basename(entity.path) + (entity is Directory ? '/' : '');

        if (isSelected && !isDone) {
          buf.writeln(
            '${Icon.pointer.style(fieldStyle.select.selector)} ${name.style(fieldStyle.select.option)}',
          );
        } else if (isSelected && isDone) {
          buf.writeln('${Icon.check} $name'.success);
        } else {
          buf.writeln('  ${name.style(fieldStyle.base)}');
        }
      }

      if (end < _entities.length) {
        buf.writeln('  ...'.style(theme.blurred.description));
      }
    }

    if (isStandalone) {
      buf.writeln();
      buf.writeln(usage.style(theme.help.shortDesc));
      if (hasError) {
        buf.writeln('${Icon.error} $error'.style(fieldStyle.errorMessage));
      }
      buf.writeln();
    }

    return buf.toString();
  }

  @override
  File write() {
    terminal.cursorHide();
    terminal.updateScreen(render());

    terminal.runRawModeSync<void>(() {
      while (true) {
        final event = terminal.readKeySync();
        final keyResult = handleKey(event);

        if (keyResult == KeyResult.done) {
          return;
        }

        if (keyResult == KeyResult.consumed) {
          terminal.updateScreen(render());
        }
      }
    });

    terminal.clearScreen();
    terminal.write(render());
    terminal.cursorShow();

    return value;
  }
}
