import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

// ── Result model ───────────────────────────────────────────────
class PredictionResult {
  final String plantName;
  final String diseaseName;
  final double confidence;
  final double probGap;
  final bool isUnknown;
  final String rawClassName;

  const PredictionResult({
    required this.plantName,
    required this.diseaseName,
    required this.confidence,
    required this.probGap,
    required this.isUnknown,
    required this.rawClassName,
  });

  bool get isHealthy => diseaseName.toLowerCase() == 'healthy';

  String get recommendation {
    const advice = {
      'late blight':          'Apply fungicide and remove infected leaves immediately.',
      'early blight':         'Remove infected leaves and rotate crops next season.',
      'septoria leaf spot':   'Remove infected leaves and apply copper-based fungicide.',
      'leaf mold':            'Improve air circulation and reduce humidity.',
      'bacterial spot':       'Use copper-based sprays; avoid overhead watering.',
      'black rot':            'Prune infected areas; apply fungicide before wet periods.',
      'powdery mildew':       'Apply sulfur-based fungicide; improve air circulation.',
      'common rust':          'Apply fungicide early. Use resistant varieties next season.',
      'northern leaf blight': 'Use resistant hybrids and apply fungicide if severe.',
      'healthy':              'Plant is healthy! Maintain regular irrigation and nutrition.',
    };
    final key = diseaseName.toLowerCase();
    for (final entry in advice.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return 'Diagnosis complete. Consult an agricultural expert for specific treatment.';
  }
}

// ── TFLite service ─────────────────────────────────────────────
class TFLiteService {
  static const int    _imgSize       = 224;
  static const int    _numClasses    = 38;
  static const double _strictThresh  = 85.0;
  static const double _gapThresh     = 15.0;

  Interpreter?      _interpreter;
  Map<int, String>  _classLabels = {};
  bool              _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/plant_disease_model.tflite',
      );

      final jsonStr = await rootBundle.loadString('assets/class_indices.json');
      final raw = jsonDecode(jsonStr) as Map<String, dynamic>;
      _classLabels = raw.map((k, v) => MapEntry(v as int, k));

      _loaded = true;
    } catch (e) {
      _loaded = false;
      rethrow;
    }
  }

  Future<PredictionResult> predict(File imageFile) async {
    if (!_loaded || _interpreter == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    // ── 1. Decode & resize ─────────────────────────────────────
    final bytes    = await imageFile.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('Could not decode image.');
    final resized = img.copyResize(original, width: _imgSize, height: _imgSize);

    // ── 2. Build input as Float32List (CRITICAL FIX) ───────────
    // Shape: [1, 224, 224, 3]  dtype: float32
    // Pixel values kept as 0–255 (matches Python's img_array / 1.0)
    final inputSize = 1 * _imgSize * _imgSize * 3;
    final inputBuffer = Float32List(inputSize);

    int idx = 0;
    for (int y = 0; y < _imgSize; y++) {
      for (int x = 0; x < _imgSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[idx++] = pixel.r.toDouble(); // 0–255, no division
        inputBuffer[idx++] = pixel.g.toDouble();
        inputBuffer[idx++] = pixel.b.toDouble();
      }
    }

    // Reshape Float32List into [1][224][224][3] that TFLite expects
    final input = inputBuffer.reshape([1, _imgSize, _imgSize, 3]);

    // ── 3. Output buffer
    // Shape: [1, 38]  dtype: float32
    var output = List.filled(1 * _numClasses, 0.0).reshape([1, _numClasses]);

    // ── 4. Run inference ───────────────────────────────────────
    _interpreter!.run(input, output);

    // ── 5. Parse results ───────────────────────────────────────
    final probs = (output[0] as List).cast<double>();

    // Find top-1 and top-2
    int top1 = 0;
    int top2 = 1;
    for (int i = 1; i < _numClasses; i++) {
      if (probs[i] > probs[top1]) {
        top2 = top1;
        top1 = i;
      } else if (probs[i] > probs[top2]) {
        top2 = i;
      }
    }

    final confidence = probs[top1] * 100.0;
    final probGap    = (probs[top1] - probs[top2]) * 100.0;
    final isUnknown  = confidence < _strictThresh || probGap < _gapThresh;

    final rawName   = _classLabels[top1] ?? 'Unknown___Unknown';
    String plantName   = rawName;
    String diseaseName = 'Unknown';

    if (rawName.contains('___')) {
      final parts = rawName.split('___');
      plantName   = parts[0].replaceAll('_', ' ');
      diseaseName = parts[1].replaceAll('_', ' ');
    }

    return PredictionResult(
      plantName:    plantName,
      diseaseName:  diseaseName,
      confidence:   confidence,
      probGap:      probGap,
      isUnknown:    isUnknown,
      rawClassName: rawName,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _loaded = false;
  }
}
