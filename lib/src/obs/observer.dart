import '../js/js_page_channel.dart';

class Observer {
  final Function _function;
  final JSPageChannel channel;
  final String? debugLabel;
  Observer(
    this._function,
    this.channel,
    this.debugLabel,
  );
  void update() {
    _function.call();
  }

  final List<String> _fields = [];
  void register(String key) {
    if (!_fields.contains(key)) {
      _fields.add(key);
    }
  }

  void clear() {
    for (var element in _fields) {
      channel.removeObs(element, this);
    }
  }
}
