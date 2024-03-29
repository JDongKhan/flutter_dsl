part of '../../flutter_dsl.dart';

class FlutterDSLTextBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLTextBuilder();

  @override
  Widget createWidget(XmlElement node, Attribute? attribute, JSPageChannel jsChannel, [dynamic item]) {
    String? style = node.getAttribute('style');
    TextAttribute attribute = TextAttribute(style: style);
    Color? color = attribute.getColorFromStyle('color');
    double? fontSize = attribute.getDoubleFromStyle('font-size');
    int? fw = attribute.getIntFromStyle('font-weight');
    String? v = node.innerXml;

    FontWeight? fontWeight;
    if (fw != null) {
      fontWeight = FontWeight.values.firstWhere((element) => element.value == fw, orElse: () => FontWeight.normal);
    }
    builder(Iterator<XmlNode> nodeList) {
      return RichText(
        text: TextSpan(
          children: _createTextSpans(nodeList, jsChannel),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
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
          jsChannel: jsChannel,
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

  List<TextSpan> _createTextSpans(Iterator<XmlNode> nodeList, JSPageChannel jsChannel) {
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
        children.add(_createChildTextSpan(node, jsChannel));
      }
    }
    return children;
  }

  TextSpan _createChildTextSpan(XmlElement node, JSPageChannel jsChannel) {
    String? style = node.getAttribute('style');
    TextAttribute attribute = TextAttribute(style: style);
    Color? color = attribute.getColorFromStyle('color');
    TextStyle? textStyle;
    if (color != null) {
      textStyle = TextStyle(color: color);
    }
    return TextSpan(text: null, children: _createTextSpans(node.children.iterator, jsChannel), style: textStyle);
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
