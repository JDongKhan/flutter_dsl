part of '../../flutter_dsl.dart';

class FlutterDSLColumnBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLColumnBuilder();

  @override
  NodeData createWidget(XmlElement node, JSCaller jsCaller) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller);
    return NodeData(
      widget: Column(
        children: children,
      ),
    );
  }
}

class ColumnAttribute extends Attribute {}
