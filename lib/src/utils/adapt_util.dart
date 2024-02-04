import 'package:flutter/material.dart';

class AdaptUtil {
  static MediaQueryData mediaQuery = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
  static final double _width = mediaQuery.size.width;
  static final double _height = mediaQuery.size.height;
  static final double _topBarH = mediaQuery.padding.top;
  static final double _botBarH = mediaQuery.padding.bottom;
  static final double _pixelRatio = mediaQuery.devicePixelRatio;
  static double? _ratio;
  static const int _defaultH = 750;

  static init(int? number) {
    int width = number ?? _defaultH;
    _ratio = _width / width;
  }

  static double rpx(number) {
    if (_ratio == null) {
      AdaptUtil.init(_defaultH);
    }
    return (number * _ratio);
  }

  static onePx() {
    return 1 / _pixelRatio;
  }

  static screenW() {
    return _width;
  }

  static screenH() {
    return _height;
  }

  static padTopH() {
    return _topBarH;
  }

  static padBotH() {
    return _botBarH;
  }
}
