part of '../../flutter_dsl.dart';

class FlutterDSLTextBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLTextBuilder();

  @override
  NodeData createWidget(XmlElement node, JSCaller jsCaller) {
    String? style = node.getAttribute('style');
    TextAttribute attribute = TextAttribute(style: style);
    Color? color = attribute.getColorFromStyle('color');
    double? fontSize = attribute.getDoubleFromStyle('font-size');
    return NodeData(
      widget: RichText(
        text: TextSpan(
          children: _createTextSpans(node.children.iterator),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
          ),
        ),
      ),
      attribute: attribute,
    );
  }

  List<TextSpan> _createTextSpans(Iterator<XmlNode> nodeList) {
    List<TextSpan> children = [];
    while (nodeList.moveNext()) {
      XmlNode node = nodeList.current;
      if (node is XmlText) {
        String v = node.value.trim();
        if (v == '') {
          continue;
        }
        children.add(TextSpan(text: v));
      } else if (node is XmlElement) {
        children.add(_createChildTextSpan(node));
      }
    }
    return children;
  }

  TextSpan _createChildTextSpan(XmlElement node) {
    String? style = node.getAttribute('style');
    TextAttribute attribute = TextAttribute(style: style);
    Color? color = attribute.getColorFromStyle('color');
    TextStyle? textStyle;
    if (color != null) {
      textStyle = TextStyle(color: color);
    }
    return TextSpan(text: null, children: _createTextSpans(node.children.iterator), style: textStyle);
  }
}

class TextAttribute extends Attribute {
  TextAttribute({super.style});
}
