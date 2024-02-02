part of '../../flutter_dsl.dart';

class FlutterDSLTextBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLTextBuilder();

  @override
  NodeData createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    String? style = node.getAttribute('style');
    TextAttribute attribute = TextAttribute(style: style);
    Color? color = attribute.getColorFromStyle('color');
    double? fontSize = attribute.getDoubleFromStyle('font-size');
    String? v = node.innerXml;

    builder() {
      return RichText(
        text: TextSpan(
          children: _createTextSpans(node.children.iterator, jsCaller),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
          ),
        ),
      );
    }

    Widget widget;
    if (v.contains('{{') && v.contains('}}')) {
      widget = ObsWidget(
          debugLabel: 'text',
          content: v,
          item: item,
          jsChannel: jsCaller,
          builder: (context) {
            node.innerXml = context;
            return builder();
          });
    } else {
      widget = builder();
    }

    return NodeData(
      widget: widget,
      attribute: attribute,
    );
  }

  List<TextSpan> _createTextSpans(Iterator<XmlNode> nodeList, JSPageChannel jsCaller) {
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
        children.add(_createChildTextSpan(node, jsCaller));
      }
    }
    return children;
  }

  TextSpan _createChildTextSpan(XmlElement node, JSPageChannel jsCaller) {
    String? style = node.getAttribute('style');
    TextAttribute attribute = TextAttribute(style: style);
    Color? color = attribute.getColorFromStyle('color');
    TextStyle? textStyle;
    if (color != null) {
      textStyle = TextStyle(color: color);
    }
    return TextSpan(text: null, children: _createTextSpans(node.children.iterator, jsCaller), style: textStyle);
  }
}

class TextAttribute extends Attribute {
  TextAttribute({super.style});
}
