part of '../../flutter_dsl.dart';

class FlutterDSLColumnBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLColumnBuilder();

  @override
  Widget createWidget(XmlElement node, Attribute? attribute, JSPageChannel jsChannel, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsChannel, item);
    String? mainAlign = node.getAttribute('main-align');
    String? crossAlign = node.getAttribute('cross-align');
    String? mainSize = node.getAttribute('mainSize');
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;

    switch (mainAlign) {
      case 'center':
        mainAxisAlignment = MainAxisAlignment.center;
        break;
      case 'end':
        mainAxisAlignment = MainAxisAlignment.end;
        break;
      case 'spaceBetween':
        mainAxisAlignment = MainAxisAlignment.spaceBetween;
        break;
      case 'spaceAround':
        mainAxisAlignment = MainAxisAlignment.spaceAround;
        break;
      case 'spaceEvenly':
        mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        break;
    }

    MainAxisSize mainAxisSize = MainAxisSize.max;
    if (mainSize != null) {
      mainAxisSize = MainAxisSize.values.firstWhere((element) => element.name == mainSize);
    }

    switch (crossAlign) {
      case 'start':
        crossAxisAlignment = CrossAxisAlignment.start;
        break;
      case 'end':
        crossAxisAlignment = CrossAxisAlignment.end;
        break;
      case 'stretch':
        crossAxisAlignment = CrossAxisAlignment.stretch;
        break;
      case 'baseline':
        crossAxisAlignment = CrossAxisAlignment.baseline;
        break;
    }
    return Column(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

class ColumnAttribute extends Attribute {}
