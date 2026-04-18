import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'auth_service.dart';

class ApiService {
 static String get baseUrl => AuthService.baseUrl;
  
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      // Filter out non-JSON encodable values (like nested objects/enums)
      final safeData = <String, dynamic>{};
      deviceInfo.data.forEach((key, value) {
        if (value is String || value is num || value is bool) {
          safeData[key] = value;
        } else if (value != null) {
          safeData[key] = value.toString();
        }
      });
      return safeData;
    } catch (e) {
      return {'platform': Platform.operatingSystem, 'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> logLocalPrediction({
    required String diseaseCode,
    required double confidence,
    required String imageName,
    required double processingTimeMs,
  }) async {
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final userId = user != null ? user['id'] : null;

      print('📤 Logging prediction...');
      print('   Disease: $diseaseCode');
      print('   Confidence: $confidence');
      print('   User ID: $userId');
      if (token != null) print('   Token: ${token.substring(0, 20)}...');

      if (token == null) {
        print('❌ No token found - user not logged in');
        return {'error': 'Not logged in'};
      }
      
      final deviceInfo = await _getDeviceInfo();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-Device-Info': jsonEncode(deviceInfo),
      };

      if (token != null) headers['Authorization'] = 'Bearer $token';
      if (user != null) headers['X-User-ID'] = user['id'] ?? '';
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/predict/log-local'),
        headers: headers,
        body: jsonEncode({
          'disease_code': diseaseCode,
          'confidence': confidence,
          'image_name': imageName,
          'processing_time_ms': processingTimeMs,
        }),
      ).timeout(const Duration(seconds: 15));
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Prediction logged successfully!');
        return data;
      } else if (response.statusCode == 401 && token != null) {
        print('❌ Token expired - need to login again');
        await AuthService.logout();
        throw Exception('Session expired');
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        return {'error': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Network error: $e');
      return {'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> cloudPredict(File image) async {
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      
      final deviceInfo = await _getDeviceInfo();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/predict/'),
      );
      
      final headers = <String, String>{
        'X-Device-Info': jsonEncode(deviceInfo),
      };

      if (token != null) headers['Authorization'] = 'Bearer $token';
      if (user != null) headers['X-User-ID'] = user['id'] ?? '';

      request.headers.addAll(headers);
      
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );
      
      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 401 && token != null) {
        await AuthService.logout();
        throw Exception('Session expired');
      }
    } catch (e) {
      print('Cloud prediction failed: $e');
    }
    return {};
  }

  static Future<void> submitFeedback({
    required String predictionId,
    required bool wasCorrect,
    String? actualDisease,
    String? comments,
  }) async {
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) headers['Authorization'] = 'Bearer $token';
      if (user != null) headers['X-User-ID'] = user['id'] ?? '';
      
      await http.post(
        Uri.parse('$baseUrl/api/predict/feedback'),
        headers: headers,
        body: jsonEncode({
          'prediction_id': predictionId,
          'was_correct': wasCorrect,
          'actual_disease': actualDisease,
          'comments': comments,
        }),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      print('Feedback submittion failed: $e');
    }
  }
}
