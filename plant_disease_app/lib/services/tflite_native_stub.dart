// Stub for platforms where TFLite is not available (like Web)
class TFLiteNative {
  static Future<dynamic> loadModel(String assetPath) async => null;
  static Future<Map<String, dynamic>> runInference(dynamic interpreter, String imagePath, Map<int, String> labels) async => {};
  static void close(dynamic interpreter) {}
}
