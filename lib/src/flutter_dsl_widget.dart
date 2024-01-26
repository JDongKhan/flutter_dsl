part of '../flutter_dsl.dart';

class FlutterDSLWidget extends StatefulWidget {
  final String path;
  const FlutterDSLWidget({
    super.key,
    required this.path,
  });

  @override
  State<FlutterDSLWidget> createState() => _FlutterDSLWidgetState();
}

class _FlutterDSLWidgetState extends State<FlutterDSLWidget> {
  FlutterDSLParser parser = FlutterDSLParser();

  @override
  Widget build(BuildContext context) {
    parser.onRefresh = () {
      setState(() {});
    };
    return FutureBuilder(
      future: parser.parserFromPath(widget.path),
      builder: (c, sp) {
        if (sp.hasData) {
          return sp.data!;
        }
        return const SizedBox.shrink();
      },
    );
  }
}
