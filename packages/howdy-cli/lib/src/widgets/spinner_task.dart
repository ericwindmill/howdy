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
class SpinnerTask<T> extends InteractiveWidget<T> {
  SpinnerTask({required super.label, required this.task});

  final Future<T> Function() task;

  T? _value;
  bool _isDone = false;

  @override
  String get usage => '';

  static Future<T> send<T>({
    required String label,
    required Future<T> Function() task,
  }) {
    return SpinnerTask<T>(label: label, task: task).write();
  }

  @override
  String build(StringBuffer buf) {
    if (_isDone) {
      return '${renderSpans([StyledText('✔ '), StyledText(label)])}\n';
    }
    // While running, the spinner handles its own animation frames.
    return label;
  }

  @override
  T get value => _value as T;

  @override
  bool get isDone => _isDone;

  @override
  Future<T> write() async {
    final spinner = Spinner();

    // Render spinner + label on the same line.
    spinner.write();
    terminal.writeSpans([StyledText(label)]);

    try {
      final result = await task();
      _value = result;
      _isDone = true;
      spinner.stop(success: true);
      terminal.writeSpansLn([StyledText(label)]);
      return result;
    } catch (e) {
      spinner.stop(success: false);
      terminal.writeSpansLn([StyledText(label)]);
      rethrow;
    }
  }
}
