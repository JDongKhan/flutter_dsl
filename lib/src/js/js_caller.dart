import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dsl/src/js/js_container.dart';
import 'package:flutter_js/flutter_js.dart';

typedef LinkAction = void Function(dynamic link);

class JSCaller {
  LinkAction? linkAction;
  Function? callback;
  late String key;

  Map<String, FieldObs> data = {};

  bool hasInject = false;

  void setData(dynamic target, String key, dynamic value) {
    key = "data.$key";
    FieldObs? obs = data[key];
    if (obs == null) {
      obs = FieldObs();
      data[key] = obs;
    }
    obs.value = value;
    for (var element in obs.obsList) {
      element.refresh();
    }
  }

  void getData(String key) {}

  void setup(String js, Function? callback) {
    //监听页面刷新
    JsContainer.instance.registerRefresh(key, callback);
    JsContainer.instance.registerSetData(key, setData);
    if (hasInject) {
      JsContainer.instance.evaluate('if($key.onShow){$key.onShow();}');
      return;
    }
    String pageJs = '''
      var $key = {
        setState:function() {
          sendMessage("setState",JSON.stringify({page:'$key',}));
        },
        expression:function(expression){
          console.log("expression:"+expression);
          return expression;
        },
        ...$js
      };
     
      function reactive(value){
         const handler = {
            get:function(target,property){
             console.log("代理get:"+property);
             return target[property];
            },
            set:function(target,property,value){
              console.log("代理set:"+property);
              sendMessage("setData",JSON.stringify({page:'$key',target:target,key:property,value:value}));
              target[property] = value;
            }
         }
         return new Proxy(value,handler);
      }
     
      ''';
    //注入页面js
    JsEvalResult result = JsContainer.instance.evaluate(pageJs);
    debugPrint('加载js代码:$result');
    if (result.stringResult == 'null') {
      hasInject = true;
      JsContainer.instance.evaluate('if($key.onLoad){$key.onLoad();}');
      JsContainer.instance.evaluate('if($key.onShow){$key.onShow();}');
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

  bool executeExpression(String expression) {
    JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.expression($expression) }); })();');
    return false;
  }

  dynamic getField(String field) {
    JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.$field }); })();');
    String jsonField = result.stringResult;
    Map map = jsonDecode(jsonField);
    debugPrint('执行js代码$result');
    return map['field'];
  }

  dynamic getObsField(String field, ObserverMixin context) {
    FieldObs? obs = data[field];
    if (obs == null) {
      obs = FieldObs();
      data[field] = obs;
    }
    if (!obs.obsList.contains(context)) {
      obs.obsList.add(context);
    }
    JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.$field }); })();');
    String jsonField = result.stringResult;
    Map map = jsonDecode(jsonField);
    debugPrint('执行js代码$result');
    return map['field'];
  }

  void removeObs(String field, ObserverMixin context) {
    FieldObs? obs = data[field];
    obs?.obsList.remove(context);
  }

  void onClick(dynamic link) {
    linkAction?.call(link);
  }

  void destroy() {
    callJsMethod('onDestroy()');
    JsContainer.instance.destroy(key);
    JsContainer.instance.evaluate('$key = null;');
  }
}

class FieldObs {
  late String key;
  dynamic value;
  List<ObserverMixin> obsList = [];
}

mixin ObserverMixin<T extends StatefulWidget> on State<T> {
  void refresh() {
    setState(() {});
  }
}
