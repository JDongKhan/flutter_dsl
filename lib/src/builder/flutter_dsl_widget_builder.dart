part of '../../flutter_dsl.dart';

abstract class FlutterDSLWidgetBuilder {
  FlutterDSLWidgetBuilder();

  ///创建属性
  Attribute? createAttribute(XmlElement node) {
    String? style = node.getAttribute('style');
    if (style == null) {
      return null;
    }
    return ViewAttribute(style: style);
  }

  ///build
  Widget build(XmlElement node, JSPageChannel jsChannel, [dynamic item]) {
    String? vIf = node.getAttribute('v-if');
    if (vIf != null) {
      return Obs(
        debugLabel: 'if($vIf)',
        jsChannel: jsChannel,
        builder: (context, result) {
          bool result = jsChannel.callExpression(vIf);
          if (!result) {
            return const SizedBox.shrink();
          }
          return _build(node, jsChannel, item);
        },
      );
    }
    return _build(node, jsChannel, item);
  }

  Widget _build(XmlElement node, JSPageChannel jsChannel, [dynamic item]) {
    //处理通用样式
    Attribute? attribute = createAttribute(node);
    //创建widget
    Widget child = createWidget(node, attribute, jsChannel, item);
    //字体颜色
    Color? color = attribute?.getColorFromStyle('color');
    double? fontSize = attribute?.getDoubleFromStyle('font-size');
    String? fontFamily = attribute?.getStyle('font-family');
    int? flex = attribute?.getIntFromStyle('flex');
    Alignment? alignment = attribute?.getAlignment("alignment");
    //字体颜色
    if (color != null || fontSize != null) {
      child = DefaultTextStyle(style: TextStyle(color: color, fontSize: fontSize, fontFamily: fontFamily), child: child);
    }

    // 高度
    double? width = attribute?.getDoubleFromStyle('width');
    double? height = attribute?.getDoubleFromStyle('height');
    //背景色
    Color? backgroundColor = attribute?.getColorFromStyle('background-color');
    Color? foregroundColor = attribute?.getColorFromStyle('foregroundColor');
    //圆角
    double? borderRadius = attribute?.getDoubleFromStyle('border-radius');
    EdgeInsets? padding = attribute?.getPadding();
    EdgeInsets? margin = attribute?.getMargin();

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
    if (constraints == null && flex != null) {
      child = Expanded(
        flex: flex,
        child: child,
      );
    }
    return child;
  }

  ///创建单个控件
  Widget createWidget(XmlElement node, Attribute? attribute, JSPageChannel jsChannel, [dynamic item]);

  ///处理子控件
  List<Widget> createChildren(Iterator<XmlNode> nodeList, JSPageChannel jsChannel, dynamic item) {
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
            ObsText(
              debugLabel: 'children($v)',
              content: v,
              item: item,
              jsChannel: jsChannel,
              builder: (context, newV) => Text(newV ?? 'null'),
            ),
          );
        } else {
          list.add(Text(v));
        }
      } else if (node is XmlElement) {
        String? vFor = node.getAttribute('v-for');
        if (vFor != null) {
          list.addAll(_buildList(node, vFor, jsChannel));
        } else {
          Widget? widget = _buildOneWidget(node, jsChannel, item);
          if (widget != null) {
            list.add(widget);
          }
        }
      }
    }
    return list;
  }

  Widget? _buildOneWidget(XmlElement node, JSPageChannel jsChannel, dynamic item) {
    String nodeName = node.name.local;
    FlutterDSLWidgetBuilder? builder = mappingBuilder[nodeName];
    Widget? widget = builder?.build(node, jsChannel, item);
    return widget;
  }

  List<Widget> _buildList(XmlElement node, String vFor, JSPageChannel jsChannel) {
    List array = vFor.split(' in ');
    String field = array[1].trim();
    String item = array[0];
    item = item.replaceAll("(", "");
    item = item.replaceAll(")", "");
    List items = item.split(',');
    String? itemKey;
    String? indexKey;
    if (items.length == 2) {
      itemKey = items[0];
      indexKey = items[1];
    } else if (items.length == 1) {
      itemKey = items[0];
    }
    List dataList = jsChannel.getField(field) ?? [];
    List<Widget> widgetList = [];
    for (var index = 0; index < dataList.length; index++) {
      var element = dataList[index];
      Map data = {};
      if (itemKey != null) {
        data[itemKey] = element;
      }
      if (indexKey != null) {
        data[indexKey] = index;
      }
      Widget? widget = _buildOneWidget(node, jsChannel, data);
      if (widget != null) {
        widgetList.add(widget);
      }
    }
    return widgetList;
  }
}

abstract class Attribute {
  ///style
  final String? style;

  ///样式
  Map<String, String>? _styles;

  Attribute({this.style}) {
    if (style != null) {
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

  int? getIntFromStyle(String key) {
    String? value = getStyle(key);
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }

  EdgeInsets? getPadding() {
    double? left = getDoubleFromStyle('padding-left');
    double? top = getDoubleFromStyle('padding-top');
    double? right = getDoubleFromStyle('padding-right');
    double? bottom = getDoubleFromStyle('padding-bottom');
    EdgeInsets? padding = getEdgeFromStyle("padding");
    return EdgeInsets.only(
      left: left ?? padding?.left ?? 0,
      top: top ?? padding?.top ?? 0,
      right: right ?? padding?.right ?? 0,
      bottom: bottom ?? padding?.bottom ?? 0,
    );
  }

  EdgeInsets? getMargin() {
    double? left = getDoubleFromStyle('margin-left');
    double? top = getDoubleFromStyle('margin-top');
    double? right = getDoubleFromStyle('margin-right');
    double? bottom = getDoubleFromStyle('margin-bottom');
    EdgeInsets? padding = getEdgeFromStyle("margin");
    return EdgeInsets.only(
      left: left ?? padding?.left ?? 0,
      top: top ?? padding?.top ?? 0,
      right: right ?? padding?.right ?? 0,
      bottom: bottom ?? padding?.bottom ?? 0,
    );
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
    return null;
  }

  double? _handleDouble(String? value) {
    if (value == null) {
      return null;
    }
    if (value.endsWith('rpx')) {
      value = value.replaceAll('rpx', '');
      double num = double.tryParse(value) ?? 0;
      return AdaptUtil.rpx(num);
    } else if (value.endsWith('px')) {
      value = value.replaceAll('px', '');
    }
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
      value = 'ff$newColorStr';
    }
    assert(value.length == 8, '颜色#$value格式不正确');
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
      double d4 = _handleDouble(numbers[3]) ?? 0;
      edgeInsets = EdgeInsets.only(top: d1, right: d2, bottom: d3, left: d4);
    }
    return edgeInsets;
  }
}
