import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Conditional imports to avoid FFI errors on Web
import 'tflite_native_stub.dart' 
    if (dart.library.io) 'tflite_native_mobile.dart';

class TFLiteService {
  dynamic _interpreter;
  late Map<int, String> _classIndices;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      if (kIsWeb) {
        // Mock loading for Web Preview
        final jsonString = await rootBundle.loadString('assets/class_indices.json');
        final Map<String, dynamic> rawIndices = json.decode(jsonString);
        _classIndices = rawIndices.map((key, value) => MapEntry(int.parse(key), value.toString()));
        _isLoaded = true;
        return;
      }

      // 1. Load Model (Mobile Only)
      _interpreter = await TFLiteNative.loadModel('assets/plant_disease_model.tflite');
      
      // 2. Load Labels
      final jsonString = await rootBundle.loadString('assets/class_indices.json');
      final Map<String, dynamic> rawIndices = json.decode(jsonString);
      _classIndices = rawIndices.map((key, value) => MapEntry(int.parse(key), value.toString()));
      
      _isLoaded = true;
    } catch (e, stacktrace) {
      print('!!! ERROR LOADING MODEL OR LABELS !!!');
      print(e.toString());
      print(stacktrace.toString());
      _isLoaded = false;
    }

  Future<Map<String, dynamic>> predict(String imagePath) async {
    print('--- PREDICTION REQUESTED ---');
    print('Checking model status...');
    
    if (!_isLoaded) {
      print('Model not loaded yet. Attempting to load now...');
      await loadModel();
      
      if (!_isLoaded) {
        print('FATAL: Model completely failed to load.');
        return {'error': 'Model failed to load during prediction request'};
      }
    }

    if (kIsWeb) {
      // Mock prediction for Web Preview
      return {
        'plant': 'Web Preview',
        'disease': 'AI only works on Mobile',
        'confidence': 99.9,
        'probGap': 20.0,
        'isUnknown': false,
        'rawLabel': 'web_preview',
      };
    }

    try {
      // Only runs on Mobile
      return await TFLiteNative.runInference(_interpreter, imagePath, _classIndices);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  void dispose() {
    if (!kIsWeb && _isLoaded) {
      TFLiteNative.close(_interpreter);
    }
  }
}
