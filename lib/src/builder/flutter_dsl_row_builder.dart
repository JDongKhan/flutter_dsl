part of '../../flutter_dsl.dart';

class FlutterDSLRowBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLRowBuilder();

  @override
  NodeData createWidget(XmlElement node, JSCaller jsCaller) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller);
    return NodeData(
      widget: Row(
        children: children,
      ),
    );
  }
}

class RowAttribute extends Attribute {}
