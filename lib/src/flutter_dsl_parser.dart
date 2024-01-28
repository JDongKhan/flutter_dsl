part of '../flutter_dsl.dart';

class FlutterDSLParser {
  LinkAction? linkAction;
  String js = '';
  JSCaller jsCaller = JSCaller();

  Function? onRefresh;

  Future<Widget> parserFromPath(String path) async {
    String context = await rootBundle.loadString(path);
    return parser(context);
  }

  ///根据内容解析xml
  Future<Widget> parser(String content) async {
    jsCaller.linkAction = linkAction;
    String page = "<page>$content</page>";
    XmlDocument document = await compute((message) => XmlDocument.parse(message), page);
    //处理ui
    XmlNode? template = document.xpath('/page/template').firstOrNull;
    //处理js
    _handleJS(document);
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
  Future<void> _handleJS(XmlDocument document) async {
    //处理js
    XmlNode? script = document.xpath('/page/script').firstOrNull;
    if (script != null) {
      XmlNode? jsNode = script.firstChild;
      js = jsNode?.value?.toString() ?? '';
      jsCaller.setup(js, onRefresh);
    }
  }

  //处理ui
  Widget? _buildWidget(XmlNode? node) {
    if (node is XmlElement) {
      String nodeName = node.name.local;
      FlutterDSLWidgetBuilder? builder = mappingBuilder[nodeName];
      return builder?.build(node, jsCaller);
    }
    return null;
  }

}
