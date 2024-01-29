import 'package:flutter/cupertino.dart';
import 'package:flutter_js/flutter_js.dart';

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
    debugPrint('加载bridge代码:$bridgeResult');
  }

  final Map<String, PageInfo> _pages = {};

  void registerRefresh(String page, Function? callback) {
    PageInfo? pageInfo = _pages[page];
    pageInfo ??= PageInfo();
    pageInfo.refreshCallback = callback;
    _pages[page] = pageInfo;
  }

  void _injectFunction() {
    flutterJs.onMessage('onInit', (dynamic args) {
      debugPrint('bridge注入成功:$args');
    });

    flutterJs.onMessage('log', (dynamic args) {
      Map map = args as Map;
      debugPrint('DSL:${map['message']}');
    });

    flutterJs.onMessage('setState', (dynamic args) {
      Map info = args;
      String page = info['page'].toString();
      PageInfo? pageInfo = _pages[page];
      pageInfo?.refreshCallback?.call();
      debugPrint('刷新页面');
    });
  }

  JsEvalResult evaluate(String code, {String? sourceUrl}) {
    return flutterJs.evaluate(code, sourceUrl: sourceUrl);
  }
}

class PageInfo {
  Function? refreshCallback;
}
