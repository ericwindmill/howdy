part of 'widget.dart';

abstract class DisplayWidget extends Widget<void> {
  DisplayWidget({
    String? title,
    super.help,
    super.key,
    super.theme,
  }) : super(title);

  @override
  void get value {}
}
