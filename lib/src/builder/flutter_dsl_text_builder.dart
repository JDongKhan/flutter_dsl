part of '../../flutter_dsl.dart';

class FlutterDSLTextBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLTextBuilder();

  @override
  Widget createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    String? style = node.getAttribute('style');
    TextAttribute attribute = TextAttribute(style: style);
    Color? color = attribute.getColorFromStyle('color');
    double? fontSize = attribute.getDoubleFromStyle('font-size');
    String? v = node.innerXml;

    builder(Iterator<XmlNode> nodeList) {
      return RichText(
        text: TextSpan(
          children: _createTextSpans(nodeList, jsCaller),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
          ),
        ),
      );
    }

    Widget widget;
    if (v.contains('{{') && v.contains('}}')) {
      widget = ObsText(
          debugLabel: 'text($v)',
          content: v,
          item: item,
          jsChannel: jsCaller,
          builder: (context, value) {
            node.treatedString = value;
            XmlDocumentFragment document = XmlDocumentFragment.parse(value);
            return builder(document.children.iterator);
          });
    } else {
      widget = builder(node.children.iterator);
    }

    return widget;
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

extension CustomXmlStringExtension on XmlNode {
  static final _treatedString = Expando<String>();
  String? get treatedString => _treatedString[this];
  set treatedString(String? x) => _treatedString[this] = x;
}
