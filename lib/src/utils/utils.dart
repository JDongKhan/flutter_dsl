class LogUtils {
  static bool isLoggable = true;

  static void log(String message) {
    if (isLoggable) {
      print(message);
    }
  }
}
