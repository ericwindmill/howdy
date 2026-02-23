import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:howdy/howdy.dart';

class FilePicker extends InputWidget<FileSystemEntity> {
  FilePicker(
    super.title, {
    FilePickerKeyMap? keymap,
    this.initialDirectory,
    super.help,
    super.validator,
    super.key,
    super.theme,
  }) : keymap = keymap ?? defaultKeyMap.filePicker {
    _currentDir = Directory(initialDirectory ?? Directory.current.path);
    _loadDirectory();
  }

  static FileSystemEntity send({
    required String title,
    FilePickerKeyMap? keymap,
    String? initialDirectory,
    String? help,
    Validator<FileSystemEntity>? validator,
  }) {
    final widget = FilePicker(
      title,
      keymap: keymap,
      initialDirectory: initialDirectory,
      help: help,
      validator: validator,
    );

    widget.write();
    return widget.value;
  }

  final String? initialDirectory;
  @override
  final FilePickerKeyMap keymap;

  late Directory _currentDir;
  List<FileSystemEntity> _entities = [];
  int _selectedIndex = 0;
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

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
    if (keymap.up.matches(event)) {
      if (_selectedIndex > 0) {
        _selectedIndex--;
        return KeyResult.consumed;
      }
    } else if (keymap.down.matches(event)) {
      if (_selectedIndex < _entities.length - 1) {
        _selectedIndex++;
        return KeyResult.consumed;
      }
    } else if (keymap.stepIn.matches(event)) {
      // ArrowRight: navigate into the selected directory.
      if (_entities.isNotEmpty) {
        final selected = _entities[_selectedIndex];
        if (selected is Directory) {
          _currentDir = selected;
          _selectedIndex = 0;
          _loadDirectory();
          return KeyResult.consumed;
        }
      }
    } else if (keymap.parent.matches(event)) {
      // ArrowLeft: go to the parent directory.
      final parent = _currentDir.parent;
      if (parent.path != _currentDir.path) {
        _currentDir = parent;
        _selectedIndex = 0;
        _loadDirectory();
        return KeyResult.consumed;
      }
    } else if (keymap.submit.matches(event)) {
      // Enter/Tab: select the highlighted file (directories are not selectable).
      if (_entities.isEmpty) return KeyResult.ignored;
      final selected = _entities[_selectedIndex];
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
    return KeyResult.ignored;
  }

  @override
  FileSystemEntity get value {
    if (_entities.isEmpty) throw StateError('No file selected');
    return _entities[_selectedIndex];
  }

  @override
  String build(IndentedStringBuffer buf) {
    if (title != null) buf.writeln(title!.style(fieldStyle.title));
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
          buf.writeln('${Icon.check} $name'.style(fieldStyle.successMessage));
        } else {
          buf.writeln('  ${name.style(fieldStyle.base)}');
        }
      }

      if (end < _entities.length) {
        buf.writeln('  ...'.style(theme.blurred.description));
      }
    }

    // Chrome: usage hint + error — only shown when standalone
    // Otherwise handled by form
    switch (renderState) {
      case RenderState.editing:
      case RenderState.waiting:
      case RenderState.complete:
        if (isStandalone) {
          buf.writeln();
          buf.writeln(usage.style(theme.help.shortDesc));
          buf.writeln();
          buf.writeln();
        }
      case RenderState.hasError:
        if (isStandalone) {
          buf.writeln();
          buf.writeln(usage.style(theme.help.shortDesc));
          buf.writeln('${Icon.error} $error'.style(fieldStyle.errorMessage));
          buf.writeln();
        }
      case RenderState.verified:
        // form owns chrome when verified inside a form, nothing extra needed
        break;
    }

    return buf.toString();
  }
}
