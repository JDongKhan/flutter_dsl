part of '../../flutter_dsl.dart';

class FlutterDSLButtonBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLButtonBuilder();

  @override
  NodeData createWidget(XmlElement node, JSCaller jsCaller) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller);
    Widget? child = children.isNotEmpty ? children.first : null;
    String? style = node.getAttribute('style');
    ButtonAttribute attribute = ButtonAttribute(style: style);
    String? click = node.getAttribute('click');
    return NodeData(
      widget: TextButton(
        onPressed: () {
          if (click != null) {
            jsCaller.callJsMethod(click);
          }
        },
        child: child ?? const SizedBox.shrink(),
      ),
      attribute: attribute,
    );
  }
}

class ButtonAttribute extends Attribute {
  ButtonAttribute({super.style});
}
