import 'package:howdy/howdy.dart';

/// An async task with a spinner and label.
///
/// Composes a [Spinner] primitive with a label and async task.
/// Displays the spinner while the task runs, then shows ✔ or ✘.
///
/// ```dart
/// final result = await SpinnerTask<String>(
///   label: 'Installing dependencies',
///   task: () async {
///     await Future.delayed(Duration(seconds: 2));
///     return 'done';
///   },
/// ).render();
/// ```
class SpinnerTask<T> extends InputWidget<T> {
  SpinnerTask(super.title, {required this.task});

  static Future<T> send<T>({
    required String label,
    required Future<T> Function() task,
  }) {
    return SpinnerTask<T>(label, task: task).write();
  }

  final Future<T> Function() task;

  T? _value;
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

  @override
  String get usage => '';

  @override
  KeyMap get keymap => defaultKeyMap;

  @override
  T get value => _value as T;

  @override
  String build(IndentedStringBuffer buf) {
    if (_isDone) {
      return '${StyledText.renderSpans([StyledText('✔ '), StyledText(title ?? '')])}\n';
    }
    // While running, the spinner handles its own animation frames.
    return title ?? '';
  }

  @override
  Future<T> write() async {
    final spinner = Spinner(rightPrompt: title ?? '');

    spinner.write();

    try {
      final result = await task();
      _value = result;
      _isDone = true;
      spinner.stop(success: true);
      terminal.writeln();
      return result;
    } catch (e) {
      spinner.stop(success: false);
      terminal.writeln();
      rethrow;
    }
  }
}
