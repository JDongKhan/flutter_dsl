class UniqueKeyGenerator {
  static int counter = 0;

  ///生成唯一key
  static String generateUniqueKey() {
    DateTime now = DateTime.now();
    int timestamp = now.millisecondsSinceEpoch;
    counter++;
    String key = 'page_$timestamp$counter';
    return key;
  }
}
