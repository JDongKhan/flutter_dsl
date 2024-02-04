class LogUtils {
  static bool isLoggable = false;

  static void log(String message) {
    if (isLoggable) {
      print(message);
    }
  }
}
