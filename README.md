设计一款轻量级的xml转widget的框架
支持如下自定义的页面以及js调用，适合一些做活动的页面

(本项目暂还未结束，暂无法商用)

该组件是直接从文件读取template下的数据动态组装成widget树，所以纯页面不存在跟js打交道，性能可以保证，如果使用了js代码，那就需要使用到jsbridge进行通信，如果不需要响应式问题也不大。  如果改变了某一个变量就要触发ui变化，这里用到了js的proxy，通过代码动态绑定和widget的关系以及监听变化刷新页面，那性能就不能保证了。

**1、从flutter获取数据注入到xml里面**
```dart
      FlutterDSLWidget(
        data: const {
            'data': {
              'title': "我来自dart（点我）",
              'title2': "我来自dart（点我）",
              'index': 0,
            },
          },
        path: 'assets/view.xml',
      );

```

**2、如果需要从页面自己获取数据从无须传入data字段.**

```dart
      FlutterDSLWidget(
        path: 'assets/view.xml',
      );
```

```html

**页面代码**

<template>
    <list-view>
        <column style="background-color:#f6f6f6;height:800rpx;">
            <view style="color:#cecece;font-size:20rpx;">11111</view>
            <text style="color:#ff00ff;font-size:30rpx;">2222 <text style="color:#00ff00">3333</text> </text>
            <button click="add(11)">{{title}}</button>
            <image style="width:200rpx;height:200rpx;" src="assets/1.png"></image>
            <row>
                <view style="width:100rpx;height:100rpx;background-color:#00ff00;"></view>
                <view style="width:100rpx;height:100rpx;background-color:#0000ff;"></view>
            </row>
        </column>
    </list-view>
</template>

<script>

    const data = {
        title: "我是字段端",
        index:0,
    }

    function add(args) {
        data.index++;
        data.title = "点击事件"+data.index;
        dslBridge.setState();
        dslBridge.log('点击事件'+data.title);
        return args;
    }
</script>

```

1、支持flutter注入数据，模版根据注入的数据生成widget树，可用于动态生成页面。 此种方式不支持调用js更改数据

2、支持数据来源于js，支持页面事件与js交互，从来通过更改数据而修改页面（目前问题是支持响应式变量(即局部刷新)性能有待测试）。

