part of '../../flutter_dsl.dart';

class FlutterDSLInputBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLInputBuilder();

  @override
  Attribute createAttribute(XmlElement node) {
    String? style = node.getAttribute('style');
    return InputAttribute(style: style);
  }

  @override
  Widget createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller, item);
    Widget? child = children.isNotEmpty ? children.first : null;

    String? click = node.getAttribute('click');
    String? placeholder = node.getAttribute('placeholder');
    Color? color = attribute?.getColorFromStyle('color');
    double? fontSize = attribute?.getDoubleFromStyle('font-size');

    return TextField(
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: color, fontSize: fontSize),
        enabledBorder: InputBorder.none,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

class InputAttribute extends Attribute {
  InputAttribute({super.style});
}
