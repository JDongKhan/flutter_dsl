import '../../flutter_dsl.dart';

const Map<String, FlutterDSLWidgetBuilder> mappingBuilder = {
  'view': FlutterDSLViewBuilder(),
  'text': FlutterDSLTextBuilder(),
  'column': FlutterDSLColumnBuilder(),
  'list-view': FlutterDSLListViewBuilder(),
  'row': FlutterDSLRowBuilder(),
  'button': FlutterDSLButtonBuilder(),
  'image': FlutterDSLImageBuilder(),
};
