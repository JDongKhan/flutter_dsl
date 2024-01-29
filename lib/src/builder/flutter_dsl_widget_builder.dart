part of '../../flutter_dsl.dart';

abstract class FlutterDSLWidgetBuilder {
  const FlutterDSLWidgetBuilder();

  ///build
  Widget build(XmlElement node, JSCaller jsCaller, [dynamic item]) {
    String? vIf = node.getAttribute('v-if');
    if (vIf != null) {
      bool result = jsCaller.callJsMethod(vIf);
      if (!result) {
        return const SizedBox.shrink();
      }
    }

    NodeData nodeData = createWidget(node, jsCaller, item);
    Widget child = nodeData.widget;

    //处理通用样式
    Attribute? attribute = nodeData.attribute;
    if (attribute == null) {
      String? style = node.getAttribute('style');
      attribute = ViewAttribute(style: style);
    }

    Color? color = attribute.getColorFromStyle('color');
    double? fontSize = attribute.getDoubleFromStyle('font-size');
    //字体颜色
    if (color != null || fontSize != null) {
      child = DefaultTextStyle(style: TextStyle(color: color, fontSize: fontSize), child: child);
    }

    // 高度
    double? width = attribute.getDoubleFromStyle('width');
    double? height = attribute.getDoubleFromStyle('height');
    if (width != null || height != null) {
      child = SizedBox(width: width, height: height, child: child);
    }

    Color? backgroundColor = attribute.getColorFromStyle('background-color');
    //背景色
    if (backgroundColor != null) {
      child = ColoredBox(color: backgroundColor, child: child);
    }

    return child;
  }

  ///创建控件
  NodeData createWidget(XmlElement node, JSCaller jsCaller, [dynamic item]);

  ///处理子控件
  List<Widget> createChildren(Iterator<XmlNode> nodeList, JSCaller jsCaller, dynamic item) {
    List<Widget> list = [];
    while (nodeList.moveNext()) {
      XmlNode node = nodeList.current;
      if (node is XmlText) {
        String v = node.value.trim();
        if (v == '') {
          continue;
        }
        if (v.contains('{{') && v.contains('}}')) {
          if (item != null && item != 'null') {
            String? text = parserText(v, jsCaller, item);
            list.add(Text(text ?? ' null'));
          } else {
            list.add(Obs(field: v, jsCaller: jsCaller, builder: (newV) => Text(newV ?? 'null')));
          }
        } else {
          list.add(Text(v));
        }
      } else if (node is XmlElement) {
        String nodeName = node.name.local;
        FlutterDSLWidgetBuilder? builder = mappingBuilder[nodeName];
        Widget? widget = builder?.build(node, jsCaller, item);
        if (widget != null) {
          list.add(widget);
        }
      }
    }
    return list;
  }

  String? parserText(String v, JSCaller jsCaller, [dynamic item]) {
    if (v.contains('{{') && v.contains('}}')) {
      String content = v;
      RegExp regex = RegExp(r'{{(.*?)}}');
      Iterable<Match> matches = regex.allMatches(v);
      for (Match match in matches) {
        String? matchedText = match.group(1);
        if (matchedText != null) {
          dynamic c;
          if (item != null) {
            c = item[matchedText];
          } else {
            c = jsCaller.getField(matchedText);
          }
          content = content.replaceAll('{{$matchedText}}', c.toString());
        }
      }
      return content;
    }
    return v;
  }
}

class NodeData {
  final Widget widget;
  final Attribute? attribute;
  NodeData({required this.widget, this.attribute});
}

abstract class Attribute {
  ///style
  final String? style;

  ///样式
  Map<String, String>? _styles;

  Attribute({this.style}) {
    Map<String, String> map = HashMap();
    List<String>? strArr = style?.split(';');
    if (strArr != null) {
      for (var element in strArr) {
        if (element.isEmpty) {
          continue;
        }
        List p = element.split(':');
        String key = p[0];
        String value = p[1];
        map[key] = value;
      }
    }
    _styles = map;
  }

  String? getStyle(String key) {
    return _styles?[key];
  }

  Color? getColorFromStyle(String key) {
    String? colorStr = getStyle(key);
    if (colorStr != null) {
      colorStr = colorStr.replaceFirst('#', '');
      if (colorStr.length == 6) {
        colorStr = 'ff$colorStr';
      } else if (colorStr.length == 3) {
        String newColorStr = '';
        for (int i = 0; i < colorStr.length; i++) {
          newColorStr += colorStr[i] + colorStr[i];
        }
        colorStr = newColorStr;
      }
      return Color(int.parse(colorStr, radix: 16));
    }
    return null;
  }

  double? getDoubleFromStyle(String key) {
    String? value = getStyle(key);
    if (value == null) {
      return null;
    }
    value = value.replaceAll('rpx', '');
    value = value.replaceAll('px', '');
    return double.tryParse(value) ?? 0;
  }
}
