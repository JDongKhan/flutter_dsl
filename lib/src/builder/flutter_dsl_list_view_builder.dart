part of '../../flutter_dsl.dart';

class FlutterDSLListViewBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLListViewBuilder();

  @override
  Widget createWidget(XmlElement node, Attribute? attribute, JSPageChannel jsCaller, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller, item);
    return ListView(
      children: children,
    );
  }
}

class ListViewAttribute extends Attribute {}
