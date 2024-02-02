class Observer {
  final Function _function;
  Observer(this._function);
  void update() {
    _function.call();
  }
}
