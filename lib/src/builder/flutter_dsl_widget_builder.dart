part of '../../flutter_dsl.dart';

abstract class FlutterDSLWidgetBuilder {
  const FlutterDSLWidgetBuilder();

  ///build
  Widget build(XmlElement node, JSPageChannel jsChannel, [dynamic item]) {
    String? vIf = node.getAttribute('v-if');
    if (vIf != null) {
      return Obs2(
        debugLabel: 'if',
        jsChannel: jsChannel,
        builder: (result) {
          bool result = jsChannel.callExpression(vIf);
          if (!result) {
            return const SizedBox.shrink();
          }
          return _build(node, jsChannel, item);
        },
        vIf: vIf,
      );
    }
    return _build(node, jsChannel, item);
  }

  Widget _build(XmlElement node, JSPageChannel jsChannel, [dynamic item]) {
    NodeData nodeData = createWidget(node, jsChannel, item);
    Widget child = nodeData.widget;

    //处理通用样式
    Attribute? attribute = nodeData.attribute;
    if (attribute == null) {
      String? style = node.getAttribute('style');
      attribute = ViewAttribute(style: style);
    }
    //字体颜色
    Color? color = attribute.getColorFromStyle('color');
    double? fontSize = attribute.getDoubleFromStyle('font-size');
    String? fontFamily = attribute.getStyle('font-family');
    Alignment? alignment = attribute.getAlignment("alignment");
    //字体颜色
    if (color != null || fontSize != null) {
      child = DefaultTextStyle(style: TextStyle(color: color, fontSize: fontSize, fontFamily: fontFamily), child: child);
    }

    // 高度
    double? width = attribute.getDoubleFromStyle('width');
    double? height = attribute.getDoubleFromStyle('height');
    //背景色
    Color? backgroundColor = attribute.getColorFromStyle('background-color');
    Color? foregroundColor = attribute.getColorFromStyle('foregroundColor');
    //圆角
    double? borderRadius = attribute.getDoubleFromStyle('border-radius');
    EdgeInsets? padding = attribute.getEdgeFromStyle("padding");
    EdgeInsets? margin = attribute.getEdgeFromStyle('margin');

    if (alignment != null) {
      child = Align(alignment: alignment, child: child);
    }

    if (padding != null) {
      child = Padding(padding: padding, child: child);
    }

    if (borderRadius != null) {
      child = DecoratedBox(decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(borderRadius)), child: child);
    } else if (backgroundColor != null) {
      child = ColoredBox(color: backgroundColor, child: child);
    }

    if (foregroundColor != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(color: foregroundColor),
        position: DecorationPosition.foreground,
        child: child,
      );
    }

    BoxConstraints? constraints = (width != null || height != null) ? BoxConstraints.tightFor(width: width, height: height) : null;
    if (constraints != null) {
      child = ConstrainedBox(constraints: constraints, child: child);
    }

    if (margin != null) {
      child = Padding(padding: margin, child: child);
    }
    return child;
  }

  ///创建控件
  NodeData createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]);

  ///处理子控件
  List<Widget> createChildren(Iterator<XmlNode> nodeList, JSPageChannel jsCaller, dynamic item) {
    List<Widget> list = [];
    while (nodeList.moveNext()) {
      XmlNode node = nodeList.current;
      if (node is XmlText) {
        String v = node.value.trim();
        if (v == '') {
          continue;
        }
        if (v.contains('{{') && v.contains('}}')) {
          list.add(
            ObsWidget(
              debugLabel: 'children',
              content: v,
              item: item,
              jsChannel: jsCaller,
              builder: (newV) => Text(newV ?? 'null'),
            ),
          );
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
        if (p.length != 2) {
          debugPrint('{$style}  里面的 "$element" 异常');
        } else {
          String key = p[0];
          String value = p[1];
          map[key] = value;
        }
      }
    }
    _styles = map;
  }

  String? getStyle(String key) {
    return _styles?[key];
  }

  Color? getColorFromStyle(String key) {
    String? colorStr = getStyle(key);
    return _handleColor(colorStr);
  }

  double? getDoubleFromStyle(String key) {
    String? value = getStyle(key);
    return _handleDouble(value);
  }

  EdgeInsets? getEdgeFromStyle(String key) {
    String? value = getStyle(key);
    return _handleEdgInset(value);
  }

  Alignment? getAlignment(String key) {
    String? value = getStyle(key);
    if (value == null) {
      return null;
    }
    if (value == 'center') {
      return Alignment.center;
    }
    if (value == 'topLeft') {
      return Alignment.topLeft;
    }
    if (value == 'topCenter') {
      return Alignment.topCenter;
    }
    if (value == 'topRight') {
      return Alignment.topRight;
    }
    if (value == 'centerLeft') {
      return Alignment.centerLeft;
    }
    if (value == 'centerRight') {
      return Alignment.centerRight;
    }
    if (value == 'bottomLeft') {
      return Alignment.bottomLeft;
    }
    if (value == 'bottomCenter') {
      return Alignment.bottomCenter;
    }
    if (value == 'bottomRight') {
      return Alignment.bottomRight;
    }
  }

  double? _handleDouble(String? value) {
    if (value == null) {
      return null;
    }
    value = value.replaceAll('rpx', '');
    value = value.replaceAll('px', '');
    return double.tryParse(value) ?? 0;
  }

  Color? _handleColor(String? value) {
    if (value == null) {
      return null;
    }
    value = value.replaceFirst('#', '');
    if (value.length == 6) {
      value = 'ff$value';
    } else if (value.length == 3) {
      String newColorStr = '';
      for (int i = 0; i < value.length; i++) {
        newColorStr += value[i] + value[i];
      }
      value = newColorStr;
    }
    return Color(int.parse(value, radix: 16));
  }

  EdgeInsets? _handleEdgInset(String? value) {
    if (value == null) {
      return null;
    }
    List<String> numbers = value.trim().split(RegExp(r'\s+'));
    EdgeInsets edgeInsets = EdgeInsets.zero;
    if (numbers.length == 1) {
      double dx = _handleDouble(numbers[0]) ?? 0;
      edgeInsets = EdgeInsets.all(dx);
    } else if (numbers.length == 2) {
      double d1 = _handleDouble(numbers[0]) ?? 0;
      double d2 = _handleDouble(numbers[1]) ?? 0;
      edgeInsets = EdgeInsets.symmetric(vertical: d1, horizontal: d2);
    } else if (numbers.length == 3) {
      double d1 = _handleDouble(numbers[0]) ?? 0;
      double d2 = _handleDouble(numbers[1]) ?? 0;
      double d3 = _handleDouble(numbers[2]) ?? 0;
      edgeInsets = EdgeInsets.only(top: d1, right: d2, bottom: d2, left: d3);
    } else if (numbers.length == 4) {
      double d1 = _handleDouble(numbers[0]) ?? 0;
      double d2 = _handleDouble(numbers[1]) ?? 0;
      double d3 = _handleDouble(numbers[2]) ?? 0;
      double d4 = _handleDouble(numbers[2]) ?? 0;
      edgeInsets = EdgeInsets.only(top: d1, right: d2, bottom: d3, left: d4);
    }
    return edgeInsets;
  }
}
