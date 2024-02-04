part of '../flutter_dsl.dart';

class FlutterDSLWidget extends StatefulWidget {
  final String path;
  final LinkAction? linkAction;
  final dynamic data;
  const FlutterDSLWidget({
    super.key,
    required this.path,
    this.linkAction,
    this.data,
  });

  @override
  State<FlutterDSLWidget> createState() => _FlutterDSLWidgetState();
}

class _FlutterDSLWidgetState extends State<FlutterDSLWidget> {
  late FlutterDSLParser parser;
  late String pageId;

  @override
  void initState() {
    parser = FlutterDSLParser(data: widget.data);
    parser.linkAction = widget.linkAction;
    pageId = UniqueKeyGenerator.generateUniqueKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    parser.onRefresh = () {
      setState(() {});
    };
    if (kDebugMode) {
      FutureBuilder.debugRethrowError = true;
    }
    return FutureBuilder(
      future: parser.parserFromPath(pageId, widget.path),
      builder: (c, sp) {
        if (sp.hasData) {
          return sp.data!;
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    parser.jsChannel.destroy();
    super.dispose();
  }
}

class FlutterDSlInject {
  ///注册自定义组件解析
  static void register(String key, FlutterDSLWidgetBuilder widgetBuilder) {
    mappingBuilder.putIfAbsent(key, () => widgetBuilder);
  }
}
