part of '../../flutter_dsl.dart';

class FlutterDSLImageBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLImageBuilder();

  @override
  NodeData createWidget(XmlElement node, JSCaller jsCaller, [dynamic item]) {
    String? src = node.getAttribute('src');
    return NodeData(
      widget: Image.asset(src ?? ''),
    );
  }
}

class ImageAttribute extends Attribute {
  ImageAttribute({super.style});
}
