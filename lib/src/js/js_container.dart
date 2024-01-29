import 'package:flutter/cupertino.dart';
import 'package:flutter_js/flutter_js.dart';

typedef SetDataAction = void Function(String key, dynamic value);

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
    if (pageInfo == null) {
      pageInfo = PageInfo();
      _pages[page] = pageInfo;
    }
    pageInfo.refreshCallback = callback;
    _pages[page] = pageInfo;
  }

  void registerSetData(String page, SetDataAction callback) {
    PageInfo? pageInfo = _pages[page];
    if (pageInfo == null) {
      pageInfo = PageInfo();
      _pages[page] = pageInfo;
    }
    pageInfo.setData = callback;
  }

  void _injectFunction() {
    flutterJs.onMessage('onInit', (dynamic args) {
      debugPrint('bridge注入成功:$args');
    });

    flutterJs.onMessage('log', (dynamic args) {
      Map map = args as Map;
      debugPrint('DSL:${map['message']}');
    });

    flutterJs.onMessage('setData', (dynamic args) {
      Map map = args as Map;
      String page = map['page'].toString();
      String key = map['key'];
      dynamic value = map['value'];
      PageInfo? pageInfo = _pages[page];
      pageInfo?.setData?.call(key, value);
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

  void destroy(String page) {
    _pages.remove(page);
  }
}

class PageInfo {
  Function? refreshCallback;
  SetDataAction? setData;
}
