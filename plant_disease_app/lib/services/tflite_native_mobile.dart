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
    print('\n--- TFLITE PROCESSING START ---');
    print('Loading image from: $imagePath');

    var input = Float32List(1 * 224 * 224 * 3);

    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      print('Bytes loaded: ${imageBytes.length}');
      
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        print('ERROR: Failed to decode image bytes into image.dart Image object');
        return {'error': 'Failed to decode image format'};
      }
      print('Image decoded successfully. Original size: ${originalImage.width}x${originalImage.height}');

      img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);
      print('Image resized to 224x224');

      var buffer = Float32List.view(input.buffer);
      int pixelIndex = 0;

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // EfficientNet expects pixel inputs in the range [0, 255]
          buffer[pixelIndex++] = pixel.r.toDouble();
          buffer[pixelIndex++] = pixel.g.toDouble();
          buffer[pixelIndex++] = pixel.b.toDouble();
        }
      }
      print('Image converted to Float32 array successfully');
    } catch (e, stacktrace) {
      print('!!! CRITICAL TFLITE PREPROCESSING ERROR !!!');
      print(e.toString());
      print(stacktrace.toString());
      return {'error': 'Image processing crash: $e'};
    }

    try {
      print('Running TFLite Interpreter...');

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

      // stricter thresholds since EfficientNet can be overconfident on random objects
      const double strictThreshold = 65.0; // Needs at least 65% confidence
      const double gapThreshold = 10.0;   // Needs at least a 10% gap from the 2nd best guess
      
      // DEBUG: Print exactly what the model sees
      print('\n--- TFLITE DEBUG INFO ---');
      print('Raw Predicted Class: $className');
      print('Confidence: $confidence%');
      print('Probability Gap: $probGap%');
      print('-------------------------\n');

      bool isUnknown = (confidence < strictThreshold) || (probGap < gapThreshold);

      if (isUnknown) {
        plant = 'Not a Plant / Unrecognized';
        disease = 'N/A';
      }

      return {
        'plant': plant,
        'disease': disease,
        'confidence': confidence,
        'probGap': probGap,
        'isUnknown': isUnknown,
        'rawLabel': className,
      };
    } catch (e, stacktrace) {
      print('!!! CRITICAL TFLITE INFERENCE ERROR !!!');
      print(e.toString());
      print(stacktrace.toString());
      return {'error': 'Inference crash: $e'};
    }
  }
}
