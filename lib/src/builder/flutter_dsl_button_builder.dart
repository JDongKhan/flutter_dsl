part of '../../flutter_dsl.dart';

class FlutterDSLButtonBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLButtonBuilder();

  @override
  NodeData createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller, item);
    Widget? child = children.isNotEmpty ? children.first : null;
    String? style = node.getAttribute('style');
    ButtonAttribute attribute = ButtonAttribute(style: style);
    String? click = node.getAttribute('click');
    //点击事件
    onClick() {
      if (click != null) {
        if (click.contains(':') == true) {
          jsCaller.onClick(click);
        } else {
          jsCaller.callJsMethod(click);
        }
      }
    }

    Widget widget = TextButton(
      onPressed: onClick,
      child: child ?? const SizedBox.shrink(),
    );
    return NodeData(
      widget: widget,
      attribute: attribute,
    );
  }
}

class ButtonAttribute extends Attribute {
  ButtonAttribute({super.style});
}
