设计一款轻量级的解析DSL框架，暂时只是个设想
支持如下自定义的页面以及js调用，适合一些做活动的页面


```html

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

2、支持数据来源于js，支持页面事件与js交互，从来通过更改数据而修改页面。

