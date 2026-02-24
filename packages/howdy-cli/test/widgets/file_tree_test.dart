import 'dart:io';
import 'package:howdy/howdy.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('FileTree', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('howdy_file_tree_test_');
      File(p.join(tempDir.path, 'a.txt')).createSync();
      Directory(p.join(tempDir.path, 'dir')).createSync();
      File(p.join(tempDir.path, 'dir', 'b.txt')).createSync();
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('renders root directory name', () {
      final widget = FileTree(tempDir.path);
      final output = widget.render().stripAnsi();
      expect(output, contains(tempDir.path));
    });

    test('renders contents recursively with branch characters', () {
      final widget = FileTree(tempDir.path);
      final output = widget.render().stripAnsi();

      // The sort order is directories first, then files:
      // index 0: dir
      // index 1: a.txt
      expect(output, contains('├── dir'));
      expect(output, contains('│   └── b.txt'));
      expect(output, contains('└── a.txt'));
    });

    test('handles non-existent directory', () {
      final widget = FileTree(p.join(tempDir.path, 'nope'));
      final output = widget.render().stripAnsi();
      expect(output, contains('Directory not found:'));
    });
  });
}
