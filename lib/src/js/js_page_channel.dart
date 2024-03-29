import 'dart:convert';
import 'package:flutter_dsl/src/js/js_container.dart';
import 'package:flutter_dsl/src/obs/obs_Interface.dart';
import 'package:flutter_js/flutter_js.dart';

import '../obs/observer.dart';
import '../obs/subject.dart';
import '../utils/utils.dart';

typedef LinkAction = void Function(dynamic link);

///单页面通道
class JSPageChannel {
  dynamic data;
  JSPageChannel(this.data);
  LinkAction? linkAction;
  Function? callback;
  late String pageId;

  Map<String, Subject> dataObs = {};
  bool hasInject = false;

  ///根据关系触发事件
  void setData(dynamic target, String? targetId, String key, dynamic value) {
    if (targetId == null) {
      return;
    }
    if (target is List) {
      key = targetId;
    } else {
      key = '${targetId}__$key';
    }
    Subject? obs = dataObs[key];
    if (obs == null) {
      return;
    }
    obs.notify();
  }

  ///数据建立关系
  void getData(dynamic target, String targetId, String key) {
    // debugPrint('从js进入到dart层');
    Observer? s = ObsInterface.proxy;
    if (s == null) {
      return;
    }
    if (target is List) {
      key = targetId;
    } else {
      key = '${targetId}__$key';
    }
    __bindObs(key, s);
  }

  void __bindObs(String key, Observer s) {
    Subject? obs = dataObs[key];
    if (obs == null) {
      obs = Subject(key);
      dataObs[key] = obs;
    }
    obs.addObserver(s);
    LogUtils.log('绑定[$key]和observer[${s.debugLabel}]的关系');
  }

  ///页面初始化
  void setup(String js, Function? callback) {
    //监听页面刷新
    JsContainer.instance.registerSetState(pageId, callback);
    JsContainer.instance.registerSetData(pageId, setData);
    JsContainer.instance.registerGetData(pageId, getData);
    if (hasInject) {
      JsContainer.instance.evaluate('if($pageId.onShow){$pageId.onShow();}');
      return;
    }
    String pageJs = '''
      var $pageId = {
        objCount:0,
        
        setState:function() {
          sendMessage("setState",JSON.stringify({page:'$pageId',}));
        },
        
        log:function(msg){
          sendMessage("log",JSON.stringify({message: msg,}));
        },
        
        alert:function(text){
          sendMessage("alert",JSON.stringify({text:text,}));
        },
        
        ...$js
      };
     
      function reactive(value){
      
          for (let i in value) {
            let v = value[i]
            // console.log(i + ':' + typeof v)
            if (typeof v === 'object'){
              value[i] = reactive(v)
            }
          }
         const handler = {
            get:function(target,property){
             if (typeof target.targetId === 'undefined') {
                target.targetId = '__target__' + $pageId.objCount++
             }
             if (property != 'toJSON' && property != 'targetId' ) {
                 //console.log(target.targetId + " 代理get:" + property);
                sendMessage("getData",JSON.stringify({page:'$pageId',target:target,key:property,targetId:target.targetId,}));
             }
             return target[property];
            },
            set:function(target,property,value){
               //console.log(target.targetId + " 代理set:"+property);
              sendMessage("setData",JSON.stringify({page:'$pageId',target:target,key:property,value:value,targetId:target.targetId,}));
              target[property] = value;
            }
         }
         return new Proxy(value,handler);
      }
     
      ''';
    //注入页面js
    JsEvalResult result = JsContainer.instance.evaluate(pageJs);
    LogUtils.log('加载js代码:$result');
    if (result.stringResult == 'null') {
      hasInject = true;
      JsContainer.instance.evaluate('if($pageId.onLoad){$pageId.onLoad();}');
      JsContainer.instance.evaluate('if($pageId.onShow){$pageId.onShow();}');
    }
  }

  ///处理表达式
  dynamic callExpression(String expression) {
    JsEvalResult result = JsContainer.instance.evaluate('(function(){return $pageId.$expression})()');
    LogUtils.log('执行js代码$result');
    return result.rawResult;
  }

  ///给js端赋值
  void setFieldData(String expression, String data) {
    JsEvalResult result = JsContainer.instance.evaluate("$pageId.$expression = '${data.toString()}'; ");
    LogUtils.log('执行js代码$result');
  }

  ///调用js方法
  dynamic callJsMethod(String method, [List? args]) {
    if (!method.contains('(')) {
      if (args == null) {
        method = '$pageId.$method()';
      } else {
        method = '$pageId.$method($args)';
      }
    } else {
      method = '$pageId.$method';
    }
    JsEvalResult result = JsContainer.instance.evaluate(method);
    LogUtils.log('执行js代码$result');
    return result.rawResult;
  }

  // bool executeExpression(String expression) {
  //   JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.expression($expression) }); })();');
  //   return false;
  // }

  String? getTargetIdForField(String field) {
    if (field.contains('.')) {
      int lastIndex = field.lastIndexOf('.');
      String targetIdMethod = '${field.substring(0, lastIndex)}.targetId';
      JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$pageId.$targetIdMethod }); })();');
      String jsonField = result.stringResult;
      Map map = jsonDecode(jsonField);
      LogUtils.log('获取id');
      return map['field'];
    }
    return null;
  }

  ///获取js里面的字段
  dynamic getField(String field) {
    // if (data == null) {
    //   JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$key.data }); })();');
    //   dynamic jsonField = result.stringResult;
    //   Map map = jsonDecode(jsonField);
    //   data = {
    //     'data': map['field'],
    //   };
    // }
    if (data != null) {
      Iterator<String> p = field.split(".").iterator;
      dynamic value = data;
      while (p.moveNext()) {
        String key = p.current;
        value = value[key];
      }
      return value;
    }

    // String? targetId = getTargetIdForField(field);
    // if (targetId != null && ObsInterface.proxy != null) {
    //   int lastIndex = field.lastIndexOf('.');
    //   String key = field.substring(lastIndex + 1);
    //   key = '${targetId}__$key';
    //   __bindObs(key, ObsInterface.proxy!);
    // }
    LogUtils.log('开始获取$field字段数据');
    JsEvalResult result = JsContainer.instance.evaluate('(()=>{return JSON.stringify({field:$pageId.$field }); })();');
    String jsonField = result.stringResult;
    Map map = jsonDecode(jsonField);
    LogUtils.log('返回$field的结果:${map['field']}');
    return map['field'];
  }

  ///移除widget和数据的绑定
  void removeObs(String field, Observer context) {
    Subject? obs = dataObs[field];
    obs?.removeObserver(context);
  }

  ///点击事件
  void onClick(dynamic link) {
    linkAction?.call(link);
  }

  ///页面销毁
  void destroy() {
    callJsMethod('onDestroy()');
    JsContainer.instance.destroy(pageId);
    JsContainer.instance.evaluate('$pageId = null;');
  }
}
