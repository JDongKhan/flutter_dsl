import 'observer.dart';

class Subject {
  final String key;
  Subject(this.key);

  List<Observer> observerList = [];

  void addObserver(Observer observer) {
    if (!observerList.contains(observer)) {
      observerList.add(observer);
      observer.register(key);
    }
  }

  void removeObserver(Observer observer) {
    observerList.remove(observer);
  }

  void notify() {
    for (var element in observerList) {
      element.update();
    }
  }
}
