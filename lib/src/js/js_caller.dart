import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dsl/src/js/js_container.dart';
import 'package:flutter_dsl/src/obs/obs_Interface.dart';
import 'package:flutter_js/flutter_js.dart';

import '../obs/observer.dart';

typedef LinkAction = void Function(dynamic link);

class JSCaller {
  LinkAction? linkAction;
  Function? callback;
  late String key;

  Map<String, FieldObs> data = {};

  bool hasInject = false;

  bool _isSameObject(dynamic obj1, dynamic obj2) {
    if (obj1.runtimeType != obj2.runtimeType) {
      return false;
    }
    if (obj1 is Map) {
      obj2 as Map;
      for (String key in obj1.keys) {
        if (!obj2.containsKey(key)) {
          return false;
        }
      }
    }
    return true;
  }

  String _getAllKeys(dynamic obj) {
    if (obj is Map) {
      StringBuffer sb = StringBuffer();
      obj.forEach((key, value) {
        sb.write('${key}_');
      });
      return sb.toString();
    }
    return obj.toString();
  }

  ///根据关系触发事件
  void setData(dynamic target, String key, dynamic value) {
    String allKey = _getAllKeys(target);
    key = '$allKey$key';
    FieldObs? obs = data[key];
    if (obs == null) {
      return;
    }
    for (var element in obs.obsList) {
      element.update();
    }
  }

  ///数据建立关系
  void getData(dynamic target, String key) {
    Observer? s = ObsInterface.proxy;
    if (s == null) {
      return;
    }
    String allKey = _getAllKeys(target);
    key = '$allKey$key';
    FieldObs? obs = data[key];
    if (obs == null) {
      obs = FieldObs();
      data[key] = obs;
    }
    obs.target = target;
    if (!obs.obsList.contains(s)) {
      obs.obsList.add(s);
    }

    debugPrint('get$key');
  }

  void setup(String js, Function? callback) {
    //监听页面刷新
    JsContainer.instance.registerRefresh(key, callback);
    JsContainer.instance.registerSetData(key, setData);
    JsContainer.instance.registerGetData(key, getData);
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
             sendMessage("getData",JSON.stringify({page:'$key',target:target,key:property}));
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
    return result.rawResult;
  }

  // bool executeExpression(String expression) {
  //   JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.expression($expression) }); })();');
  //   return false;
  // }

  dynamic getField(String field) {
    JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.$field }); })();');
    String jsonField = result.stringResult;
    Map map = jsonDecode(jsonField);
    debugPrint('执行js代码$result');
    return map['field'];
  }

  void removeObs(String field, Observer context) {
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
  dynamic target;
  late String key;
  List<Observer> obsList = [];
}
