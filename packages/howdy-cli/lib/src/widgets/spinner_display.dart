import 'dart:async';

import 'package:howdy/howdy.dart';

/// A pure spinner animation primitive.
///
/// Renders an animated spinner on the current line. Call [stop] to
/// end the animation and show a success (✔) or failure (✘) icon.
///
/// Spinner is timer-driven rather than key-driven, so it doesn't
/// use [handleKey]. It still implements [render] for
/// consistency and potential composition.
///
/// ```dart
/// final spinner = Spinner();
/// spinner.render();
/// await doSomeWork();
/// spinner.stop();
/// ```
class Spinner extends DisplayWidget {
  Spinner({
    this.style = const TextStyle(foreground: Color.yellow),
    this.rightPrompt,
  });

  final TextStyle style;
  final String? rightPrompt;

  int _frameIndex = 0;
  Timer? _timer;
  bool _stopped = false;
  bool _success = true;

  @override
  bool get isDone => _stopped;

  @override
  void get value {}

  /// Stops the spinner and replaces it with a result icon.
  ///
  /// Shows ✔ on success or ✘ on failure.
  void stop({bool success = true}) {
    _timer?.cancel();
    _timer = null;
    _stopped = true;
    _success = success;

    terminal.eraseLine();
    terminal.cursorToStart();

    if (success) {
      terminal.writeSpans([
        StyledText('✔ ', style: TextStyle(foreground: Color.green)),
        if (rightPrompt != null) StyledText(rightPrompt!),
      ]);
    } else {
      terminal.writeSpans([
        StyledText('✘ ', style: TextStyle(foreground: Color.red)),
        if (rightPrompt != null) StyledText(rightPrompt!),
      ]);
    }

    terminal.cursorShow();
  }

  void _renderFrame() {
    terminal.eraseLine();
    terminal.cursorToStart();
    terminal.writeSpans([
      StyledText('${Icon.spinnerFrames[_frameIndex]} ', style: style),
      if (rightPrompt != null) StyledText(rightPrompt!),
    ]);
  }

  @override
  String build(IndentedStringBuffer buf) {
    if (_stopped) {
      if (_success) {
        return StyledText.renderSpans([
          StyledText('✔ ', style: TextStyle(foreground: Color.green)),
          if (rightPrompt != null) StyledText(rightPrompt!),
        ]);
      } else {
        return StyledText.renderSpans([
          StyledText('✘ ', style: TextStyle(foreground: Color.red)),
          if (rightPrompt != null) StyledText(rightPrompt!),
        ]);
      }
    }
    return StyledText.renderSpans([
      StyledText('${Icon.spinnerFrames[_frameIndex]} ', style: style),
      if (rightPrompt != null) StyledText(rightPrompt!),
    ]);
  }

  /// Starts the spinner animation.
  @override
  void write() {
    terminal.cursorHide();
    _renderFrame();
    _timer = Timer.periodic(Duration(milliseconds: 80), (_) {
      _frameIndex = (_frameIndex + 1) % Icon.spinnerFrames.length;
      _renderFrame();
    });
  }
}
