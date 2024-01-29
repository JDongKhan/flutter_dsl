part of '../flutter_dsl.dart';

class FlutterDSLWidget extends StatefulWidget {
  final String path;
  final LinkAction? linkAction;
  const FlutterDSLWidget({
    super.key,
    required this.path,
    this.linkAction,
  });

  @override
  State<FlutterDSLWidget> createState() => _FlutterDSLWidgetState();
}

class _FlutterDSLWidgetState extends State<FlutterDSLWidget> {
  FlutterDSLParser parser = FlutterDSLParser();
  late String key;

  @override
  void initState() {
    parser.linkAction = widget.linkAction;
    key = UniqueKeyGenerator.generateUniqueKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    parser.onRefresh = () {
      setState(() {});
    };
    return FutureBuilder(
      future: parser.parserFromPath(key,widget.path),
      builder: (c, sp) {
        if (sp.hasData) {
          return sp.data!;
        }
        return const SizedBox.shrink();
      },
    );
  }
}
