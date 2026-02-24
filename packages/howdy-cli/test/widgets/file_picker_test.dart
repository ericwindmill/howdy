import 'dart:io';
import 'package:howdy/howdy.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('FilePicker', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('howdy_file_picker_test_');
      File(p.join(tempDir.path, 'a.txt')).createSync();
      Directory(p.join(tempDir.path, 'dir')).createSync();
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('renders current directory and its contents', () {
      final widget = FilePicker(
        'Pick a file',
        initialDirectory: tempDir.path,
      );
      final output = widget.render().stripAnsi();

      expect(output, contains('Pick a file'));
      expect(output, contains(tempDir.path));
      expect(output, contains('a.txt'));
      expect(output, contains('dir/'));
    });

    test('handleKey down arrow changes selection', () {
      final widget = FilePicker(
        'Pick a file',
        initialDirectory: tempDir.path,
      );

      var output = widget.render().stripAnsi();
      expect(output, contains('❯ dir/'));
      expect(output, contains('  a.txt'));

      widget.handleKey(const SpecialKey(Key.arrowDown));
      output = widget.render().stripAnsi();
      expect(output, contains('❯ a.txt'));
      expect(output, contains('  dir/'));
    });

    test('handleKey right arrow on directory enters directory', () {
      final widget = FilePicker(
        'Pick a file',
        initialDirectory: tempDir.path,
      );

      widget.handleKey(const SpecialKey(Key.arrowRight));
      final output = widget.render().stripAnsi();
      expect(output, contains(p.join(tempDir.path, 'dir')));
      expect(output, contains('<empty directory>'));
    });

    test('handleKey enter on file finishes with value', () {
      final widget = FilePicker(
        'Pick a file',
        initialDirectory: tempDir.path,
      );

      widget.handleKey(const SpecialKey(Key.arrowDown));
      final result = widget.handleKey(const SpecialKey(Key.enter));
      expect(result, equals(KeyResult.done));
      expect(widget.value.path, equals(p.join(tempDir.path, 'a.txt')));
    });
  });
}
