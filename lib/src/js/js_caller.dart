import 'package:flutter/cupertino.dart';
import 'package:flutter_js/flutter_js.dart';

class JSCaller {
  JavascriptRuntime flutterJs = getJavascriptRuntime();
  Function? callback;

  String injectJs = '''
  var dslBridge;
  if (typeof dslBridge === 'undefined') {
      dslBridge = {
        onLoad(){
         sendMessage("onLoad",JSON.stringify({}));
        },
        log(message){
         sendMessage("log",JSON.stringify({message:message}));
        },
        setState:function() {
         sendMessage("setState",JSON.stringify({}));
        }
      }
      
      dslBridge.onLoad();
  }
  ''';

  bool hasInject = false;

  void setup(String js, Function? callback) {
    if (hasInject) {
      return;
    }
    //监听页面刷新
    injectFunction();
    this.callback = callback;
    //注入bridge
    JsEvalResult bridgeResult = flutterJs.evaluate(injectJs);
    print('加载bridge代码:$bridgeResult');
    //注入页面js
    JsEvalResult result = flutterJs.evaluate(js);
    print('加载js代码:$result');
    if (result.stringResult == null) {
      hasInject = true;
    }
  }

  dynamic callJsMethod(String method, [List? args]) {
    if (!method.contains('(')) {
      if (args == null) {
        method = '$method()';
      } else {
        method = '$method($args)';
      }
    }
    JsEvalResult result = flutterJs.evaluate(method);
    print('执行js代码$result');
    return result;
  }

  void injectFunction() {
    flutterJs.onMessage('onLoad', (dynamic args) {
      debugPrint('bridge注入成功:$args');
    });

    flutterJs.onMessage('log', (dynamic args) {
      Map map = args as Map;
      debugPrint('DSL:${map['message']}');
    });

    flutterJs.onMessage('setState', (dynamic args) {
      debugPrint('刷新页面');
      callback?.call();
    });
  }

  String getField(String field) {
    JsEvalResult result = flutterJs.evaluate('(()=>{return data.$field; })();');
    debugPrint('执行js代码$result');
    return result.stringResult;
  }
}
