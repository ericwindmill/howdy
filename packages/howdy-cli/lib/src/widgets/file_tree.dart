import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:howdy/howdy.dart';

class FileTree extends DisplayWidget {
  FileTree(
    this.path, {
    super.title,
    super.key,
    super.theme,
  });

  /// The root path of the directory to display.
  final String path;

  /// Convenience factory to print a file tree.
  static void send(String path) {
    FileTree(path).write;
  }

  @override
  bool get isDone => true;

  @override
  String build(IndentedStringBuffer buf) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      buf.writeln(
        'Directory not found: $path'.style(theme.focused.errorMessage),
      );
      return buf.toString();
    }

    buf.writeln(p.normalize(path).style(theme.focused.title));
    _printTree(dir, buf, '');

    return buf.toString();
  }

  void _printTree(Directory dir, IndentedStringBuffer buf, String prefix) {
    if (!dir.existsSync()) return;

    List<FileSystemEntity> entities;
    try {
      entities = dir.listSync();
    } catch (e) {
      buf.writeln(
        '$prefix${Icon.lastBranch} <error reading directory>'.style(
          theme.focused.errorMessage,
        ),
      );
      return;
    }

    entities.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return a.path.compareTo(b.path);
    });

    for (var i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final isLast = i == entities.length - 1;
      final branch = isLast ? Icon.lastBranch : Icon.branch;
      final name = p.basename(entity.path);

      buf.writeln('$prefix$branch $name'.style(theme.focused.description));

      if (entity is Directory) {
        final newPrefix = prefix + (isLast ? '    ' : '${Icon.pipe}   ');
        _printTree(entity, buf, newPrefix);
      }
    }
  }

  @override
  void write() {
    terminal.write(render());
  }
}
