part of '../../flutter_dsl.dart';

class FlutterDSLLazyListViewBuilder extends FlutterDSLWidgetBuilder {
  const FlutterDSLLazyListViewBuilder();

  @override
  NodeData createWidget(XmlElement node, JSCaller jsCaller, [dynamic item]) {
    List<Widget> children = createSlivers(node.children.iterator, jsCaller, item);
    return NodeData(
      widget: CustomScrollView(
        slivers: children,
      ),
    );
  }

  ///处理子控件
  List<Widget> createSlivers(Iterator<XmlNode> nodeList, JSCaller jsCaller, dynamic item) {
    List<Widget> list = [];
    while (nodeList.moveNext()) {
      XmlNode node = nodeList.current;
      if (node is XmlText) {
        String v = node.value.trim();
        if (v == '') {
          continue;
        }
      } else if (node is XmlElement) {
        String nodeName = node.name.local;
        String? vFor = node.getAttribute('v-for');
        if (vFor != null) {
          List array = vFor.split(' in ');
          String field = array[1].trim();
          String item = array[0];
          item = item.replaceAll("(", "");
          item = item.replaceAll(")", "");
          List items = item.split(',');
          String? itemKey;
          String? indexKey;
          if (items.length == 2) {
            itemKey = items[0];
            indexKey = items[1];
          } else if (items.length == 1) {
            itemKey = items[0];
          }
          List dataList = jsCaller.getField(field) ?? [];
          list.add(
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (c, index) {
                  dynamic it = dataList[index];
                  Map data = {};
                  if (itemKey != null) {
                    data[itemKey] = it;
                  }
                  if (indexKey != null) {
                    data[indexKey] = index;
                  }
                  FlutterDSLWidgetBuilder? builder = mappingBuilder[nodeName];
                  Widget? widget = builder?.build(node, jsCaller, data);
                  return widget;
                },
                childCount: dataList.length ?? 0,
              ),
            ),
          );
          continue;
        }

        FlutterDSLWidgetBuilder? builder = mappingBuilder[nodeName];
        Widget? widget = builder?.build(node, jsCaller, item);
        if (widget != null) {
          list.add(SliverToBoxAdapter(
            child: widget,
          ));
        }
      }
    }
    return list;
  }
}

class LazyListViewAttribute extends Attribute {}
