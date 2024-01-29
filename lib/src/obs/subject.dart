import 'observer.dart';

class Subject {
  List<Observer> observerList = [];

  void addObserver(Observer observer) {
    if (!observerList.contains(observer)) {
      observerList.add(observer);
    }
  }

  void removeObserver(Observer observer) {
    observerList.remove(observer);
  }
}
