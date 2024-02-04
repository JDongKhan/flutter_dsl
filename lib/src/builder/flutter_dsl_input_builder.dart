part of '../../flutter_dsl.dart';

class FlutterDSLInputBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLInputBuilder();

  @override
  NodeData createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller, item);
    Widget? child = children.isNotEmpty ? children.first : null;
    String? style = node.getAttribute('style');
    InputAttribute attribute = InputAttribute(style: style);
    String? click = node.getAttribute('click');
    String? placeholder = node.getAttribute('placeholder');
    Color? color = attribute.getColorFromStyle('color');
    double? fontSize = attribute.getDoubleFromStyle('font-size');

    return NodeData(
      widget: TextField(
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: color, fontSize: fontSize),
          enabledBorder: InputBorder.none,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
      attribute: attribute,
    );
  }
}

class InputAttribute extends Attribute {
  InputAttribute({super.style});
}
