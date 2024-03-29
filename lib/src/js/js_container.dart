import 'package:flutter/cupertino.dart';
import 'package:flutter_dsl/src/utils/utils.dart';
import 'package:flutter_js/flutter_js.dart';

typedef SetDataAction = void Function(dynamic target, String? targetId, String key, dynamic value);
typedef GetDataAction = void Function(dynamic target, String targetId, String key);

///JS容器
class JsContainer {
  static JsContainer? _instance;
  JsContainer._() {
    flutterJs = getJavascriptRuntime();
    _injectBridge();
  }
  static JsContainer get instance => _instance ??= JsContainer._();
  late JavascriptRuntime flutterJs;

  String injectJs = '''
  var dslBridge;
  if (typeof dslBridge === 'undefined') {
      dslBridge = {
        onInit(){
         sendMessage("onInit",JSON.stringify({}));
        },
        log(message){
         sendMessage("log",JSON.stringify({message:message}));
        },
      }
      dslBridge.onInit();
  }
  ''';

  void _injectBridge() {
    _injectFunction();
    //注入bridge
    JsEvalResult bridgeResult = flutterJs.evaluate(injectJs);
    LogUtils.log('加载bridge代码:$bridgeResult');
  }

  final Map<String, PageInfo> _pages = {};

  void registerSetState(String page, Function? callback) {
    PageInfo? pageInfo = _pages[page];
    if (pageInfo == null) {
      pageInfo = PageInfo();
      _pages[page] = pageInfo;
    }
    pageInfo.refreshCallback = callback;
    _pages[page] = pageInfo;
    flutterJs.onMessage('setState', (dynamic args) {
      Map info = args;
      String page = info['page'].toString();
      PageInfo? pageInfo = _pages[page];
      pageInfo?.refreshCallback?.call();
      LogUtils.log('刷新页面');
    });
  }

  void registerSetData(String page, SetDataAction callback) {
    PageInfo? pageInfo = _pages[page];
    if (pageInfo == null) {
      pageInfo = PageInfo();
      _pages[page] = pageInfo;
    }
    pageInfo.setData = callback;
    flutterJs.onMessage('setData', (dynamic args) {
      Map map = args as Map;
      String page = map['page'].toString();
      dynamic target = map['target'];
      String key = map['key'];
      String targetId = map['targetId'];
      dynamic value = map['value'];
      PageInfo? pageInfo = _pages[page];
      pageInfo?.setData?.call(target, targetId, key, value);
    });
  }

  void registerGetData(String page, GetDataAction callback) {
    PageInfo? pageInfo = _pages[page];
    if (pageInfo == null) {
      pageInfo = PageInfo();
      _pages[page] = pageInfo;
    }
    pageInfo.getData = callback;
    flutterJs.onMessage('getData', (dynamic args) {
      Map map = args as Map;
      String page = map['page'].toString();
      dynamic target = map['target'];
      String targetId = map['targetId'];
      String key = map['key'];
      PageInfo? pageInfo = _pages[page];
      pageInfo?.getData?.call(target, targetId, key);
    });
  }

  void _injectFunction() {
    flutterJs.onMessage('onInit', (dynamic args) {
      LogUtils.log('bridge注入成功:$args');
    });
    flutterJs.onMessage('log', (dynamic args) {
      Map map = args as Map;
      LogUtils.log('log-[DSL]:${map['message']}');
    });
    flutterJs.onMessage('alert', (dynamic args) {
      Map map = args as Map;
      debugPrint('alert:${map['text']}');
    });
  }

  JsEvalResult evaluate(String code, {String? sourceUrl}) {
    return flutterJs.evaluate(code, sourceUrl: sourceUrl);
  }

  void destroy(String page) {
    _pages.remove(page);
  }
}

class PageInfo {
  Function? refreshCallback;
  SetDataAction? setData;
  GetDataAction? getData;
}
