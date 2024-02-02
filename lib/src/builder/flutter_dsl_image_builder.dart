part of '../../flutter_dsl.dart';

class FlutterDSLImageBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLImageBuilder();

  @override
  NodeData createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    String? src = node.getAttribute('src');
    bool isHttp = src?.startsWith('http') ?? false;
    String? style = node.getAttribute('style');
    ImageAttribute imageAttribute = ImageAttribute(style: style);
    // 高度
    double? width = imageAttribute.getDoubleFromStyle('width');
    double? height = imageAttribute.getDoubleFromStyle('height');
    if (src == null) {
      return NodeData(
        widget: const SizedBox.shrink(),
        attribute: imageAttribute,
      );
    }
    return NodeData(
      widget: isHttp
          ? Image.network(
              src,
              width: width,
              height: height,
            )
          : Image.asset(
              src,
              width: width,
              height: height,
            ),
      attribute: imageAttribute,
    );
  }
}

class ImageAttribute extends Attribute {
  ImageAttribute({super.style});
}
