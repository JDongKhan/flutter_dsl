part of '../../flutter_dsl.dart';

class FlutterDSLButtonBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLButtonBuilder();

  @override
  Widget createWidget(XmlElement node, Attribute? attribute, JSPageChannel jsChannel, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsChannel, item);
    Widget? child = children.isNotEmpty ? children.first : null;
    String? click = node.getAttribute('click');
    //点击事件
    onClick() {
      if (click != null) {
        if (click.contains(':') == true) {
          jsChannel.onClick(click);
        } else {
          jsChannel.callJsMethod(click);
        }
      }
    }

    Widget widget = TextButton(
      onPressed: onClick,
      child: child ?? const SizedBox.shrink(),
    );
    return widget;
  }
}
