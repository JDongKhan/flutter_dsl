import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';

var router = <String,WidgetBuilder>{
  '/next' : (c) {
    return const NextPage();
  }
};