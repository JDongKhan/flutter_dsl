part of '../../flutter_dsl.dart';

class FlutterDSLListViewBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLListViewBuilder();

  @override
  NodeData createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller, item);
    return NodeData(
      widget: ListView(
        children: children,
      ),
    );
  }
}

class ListViewAttribute extends Attribute {}
