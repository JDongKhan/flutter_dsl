import 'observer.dart';

ObsInterface obsProxy = ObsInterface();
typedef BuilderFunction<T> = T Function();

class ObsInterface {
  static Observer? proxy;

  static T notifyChildren<T>(Observer observer, BuilderFunction<T> builder) {
    final oldObserver = ObsInterface.proxy;
    ObsInterface.proxy = observer;
    final result = builder();
    ObsInterface.proxy = oldObserver;
    return result;
  }
}
