part of '../../flutter_dsl.dart';

class FlutterDSLImageBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLImageBuilder();

  @override
  Attribute createAttribute(XmlElement node) {
    String? style = node.getAttribute('style');
    return ImageAttribute(style: style);
  }

  @override
  Widget createWidget(XmlElement node, JSPageChannel jsCaller, [dynamic item]) {
    String? src = node.getAttribute('src');
    bool isHttp = src?.startsWith('http') ?? false;

    // 高度
    double? width = attribute?.getDoubleFromStyle('width');
    double? height = attribute?.getDoubleFromStyle('height');
    if (src == null) {
      return const SizedBox.shrink();
    }
    return isHttp
        ? Image.network(
            src,
            width: width,
            height: height,
          )
        : Image.asset(
            src,
            width: width,
            height: height,
          );
  }
}

class ImageAttribute extends Attribute {
  ImageAttribute({super.style});
}
