import 'package:flutter/cupertino.dart';
import 'package:flutter_dsl/src/js/js_container.dart';
import 'package:flutter_js/flutter_js.dart';

typedef LinkAction = void Function(dynamic link);

class JSCaller {
  LinkAction? linkAction;
  Function? callback;
  late String key;

  bool hasInject = false;

  void setup(String js, Function? callback) {
    //监听页面刷新
    JsContainer.instance.registerRefresh(key, callback);
    if (hasInject) {
      return;
    }
    //注入页面js
    JsEvalResult result = JsContainer.instance.evaluate(js);
    debugPrint('加载js代码:$result');
    if (result.stringResult == 'null') {
      hasInject = true;
    }
  }

  dynamic callJsMethod(String method, [List? args]) {
    if (!method.contains('(')) {
      if (args == null) {
        method = '$key.$method()';
      } else {
        method = '$key.$method($args)';
      }
    } else {
      method = '$key.$method';
    }
    JsEvalResult result = JsContainer.instance.evaluate(method);
    debugPrint('执行js代码$result');
    return result;
  }

  String getField(String field) {
    JsEvalResult result = JsContainer.instance.evaluate('(()=>{return $key.data.$field; })();');
    debugPrint('执行js代码$result');
    return result.stringResult;
  }

  void onClick(dynamic link) {
    linkAction?.call(link);
  }
}
