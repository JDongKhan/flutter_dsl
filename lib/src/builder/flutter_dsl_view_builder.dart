part of '../../flutter_dsl.dart';

class FlutterDSLViewBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLViewBuilder();

  @override
  NodeData createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsCaller, item);
    Widget? child = children.isNotEmpty ? children.first : null;
    return NodeData(
      widget: child ?? const SizedBox.shrink(),
    );
  }
}

class ViewAttribute extends Attribute {
  ViewAttribute({super.style});
}
