import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dsl/src/js/js_container.dart';
import 'package:flutter_dsl/src/obs/obs_Interface.dart';
import 'package:flutter_js/flutter_js.dart';

import '../obs/observer.dart';

typedef LinkAction = void Function(dynamic link);

class JSPageChannel {
  LinkAction? linkAction;
  Function? callback;
  late String key;

  Map<String, FieldObs> data = {};

  bool hasInject = false;

  ///根据关系触发事件
  void setData(dynamic target, String key, dynamic value) {
    String? keyId = target['keyId'];
    if (keyId == null) {
      return;
    }
    key = '${keyId}__$key';
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
    String? keyId = target['keyId'];
    if (keyId == null) {
      return;
    }
    key = '${keyId}__$key';
    FieldObs? obs = data[key];
    if (obs == null) {
      obs = FieldObs();
      data[key] = obs;
    }
    obs.target = target;
    if (!obs.obsList.contains(s)) {
      obs.obsList.add(s);
      s.register(key);
    }

    debugPrint('绑定$key和组件的关系');
  }

  ///页面初始化
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
        objCount:0,
        
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
             if (typeof target.keyId === 'undefined') {
                target.keyId = '__key__' + $key.objCount++
             }
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

  ///处理表达式
  dynamic callExpression(String expression) {
    JsEvalResult result = JsContainer.instance.evaluate('(function(){return $key.$expression})()');
    debugPrint('执行js代码$result');
    return result.rawResult;
  }

  ///调用js方法
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

  ///获取js里面的字段
  dynamic getField(String field) {
    JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.$field }); })();');
    String jsonField = result.stringResult;
    Map map = jsonDecode(jsonField);
    debugPrint('执行js代码$result');
    return map['field'];
  }

  ///移除widget和数据的绑定
  void removeObs(String field, Observer context) {
    FieldObs? obs = data[field];
    obs?.obsList.remove(context);
  }

  ///点击事件
  void onClick(dynamic link) {
    linkAction?.call(link);
  }

  ///页面销毁
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
