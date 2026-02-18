import 'package:howdy/howdy.dart';

extension Spans on StringBuffer {
  void writeSpan(StyledText span) {
    final rendered = renderSpans([span]);
    write(rendered);
  }

  void writeSpanLn(StyledText span) {
    final rendered = renderSpans([span]);
    writeln(rendered);
  }

  void writeSpans(List<StyledText> spans) {
    final rendered = renderSpans(spans);
    write(rendered);
  }

  void writeSpansLn(List<StyledText> spans) {
    final rendered = renderSpans(spans);
    writeln(rendered);
  }
}
