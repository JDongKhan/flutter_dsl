part of '../../flutter_dsl.dart';

class FlutterDSLViewBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLViewBuilder();

  @override
  Widget createWidget(XmlElement node, Attribute? attribute, JSPageChannel jsChannel, [dynamic item]) {
    List<Widget> children = createChildren(node.children.iterator, jsChannel, item);
    Widget? child = children.isNotEmpty ? children.first : null;
    return child ?? const SizedBox.shrink();
  }
}

class ViewAttribute extends Attribute {
  ViewAttribute({super.style});
}
