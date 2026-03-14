import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteNative {
  static Future<Interpreter> loadModel(String assetPath) async {
    return await Interpreter.fromAsset(assetPath);
  }

  static void close(dynamic interpreter) {
    if (interpreter is Interpreter) {
      interpreter.close();
    }
  }

  static Future<Map<String, dynamic>> runInference(
      Interpreter interpreter, String imagePath, Map<int, String> classIndices) async {
    
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return {'error': 'Failed to decode image'};

    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    var input = Float32List(1 * 224 * 224 * 3);
    var buffer = Float32List.view(input.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // Normalize pixel values to [0.0, 1.0] to match Python training exactly
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    var output = List<double>.filled(classIndices.length, 0).reshape([1, classIndices.length]);
    interpreter.run(input.reshape([1, 224, 224, 3]), output);

    List<double> scores = List<double>.from(output[0]);
    int maxIndex = 0;
    double maxScore = -1.0;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    double confidence = maxScore * 100;
    List<double> sortedScores = List<double>.from(scores)..sort((a, b) => b.compareTo(a));
    double top1 = sortedScores[0];
    double top2 = sortedScores[1];
    double probGap = (top1 - top2) * 100;

    String className = classIndices[maxIndex] ?? 'Unknown';
    String plant = 'Unknown';
    String disease = 'Unknown';

    if (className.contains('___')) {
      final parts = className.split('___');
      plant = parts[0];
      disease = parts[1].replaceAll('_', ' ');
    }

    const double strictThreshold = 50.0;
    const double gapThreshold = 5.0;
    bool isUnknown = (confidence < strictThreshold) || (probGap < gapThreshold);

    return {
      'plant': plant,
      'disease': disease,
      'confidence': confidence,
      'probGap': probGap,
      'isUnknown': isUnknown,
      'rawLabel': className,
    };
  }
}
