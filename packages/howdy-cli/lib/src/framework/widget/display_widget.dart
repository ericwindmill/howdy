part of 'widget.dart';

abstract class DisplayWidget extends Widget<void> {
  DisplayWidget({
    super.key,
    super.theme,
  });

  @override
  void get value {}
}
