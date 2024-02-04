part of '../../flutter_dsl.dart';

class FlutterDSLInputBuilder extends FlutterDSLWidgetBuilder {
  FlutterDSLInputBuilder();

  @override
  Widget createWidget(XmlElement node, Attribute? attribute, JSPageChannel jsCaller, [dynamic item]) {
    String? placeholder = node.getAttribute('placeholder');
    Color? color = attribute?.getColorFromStyle('color');
    double? fontSize = attribute?.getDoubleFromStyle('font-size');
    return TextField(
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: color, fontSize: fontSize),
        enabledBorder: InputBorder.none,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
