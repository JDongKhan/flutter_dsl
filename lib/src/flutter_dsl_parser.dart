part of '../flutter_dsl.dart';

class FlutterDSLParser {
  LinkAction? linkAction;
  String js = '';
  JSPageChannel jsChannel = JSPageChannel();

  Function? onRefresh;

  Future<Widget> parserFromPath(String key, String path) async {
    String context = await rootBundle.loadString(path);
    return parser(key, context);
  }

  ///根据内容解析xml
  Future<Widget> parser(String key, String content) async {
    jsChannel.linkAction = linkAction;
    jsChannel.key = key;
    String page = "<page>$content</page>";
    XmlDocument document = await compute((message) => XmlDocument.parse(message), page);
    //处理ui
    XmlNode? template = document.xpath('/page/template').firstOrNull;
    //处理js
    _handleJS(key, document);
    //渲染ui
    if (template != null && template.children.isNotEmpty) {
      Iterator nodeList = template.children.iterator;
      while (nodeList.moveNext()) {
        XmlNode node = nodeList.current;
        if (node is XmlText) {
          String v = node.value.trim();
          if (v == '') {
            continue;
          }
        } else if (node is XmlElement) {
          Widget? widget = _buildWidget(node) ?? const SizedBox.shrink();
          return widget;
        }
      }
    }
    return const SizedBox.shrink();
  }

  ///处理js
  Future<void> _handleJS(String key, XmlDocument document) async {
    //处理js
    XmlNode? script = document.xpath('/page/script').firstOrNull;
    if (script != null) {
      XmlNode? jsNode = script.firstChild;
      js = jsNode?.value?.toString() ?? '';
      jsChannel.setup(js, onRefresh);
    }
  }

  //处理ui
  Widget? _buildWidget(XmlNode? node) {
    if (node is XmlElement) {
      String nodeName = node.name.local;
      FlutterDSLWidgetBuilder? builder = mappingBuilder[nodeName];
      return builder?.build(node, jsChannel);
    }
    return null;
  }
}
