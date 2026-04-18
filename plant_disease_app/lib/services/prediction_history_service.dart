import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class PredictionHistoryService {
  static String get baseUrl => AuthService.baseUrl;
  
  static Future<List<Map<String, dynamic>>> getHistory({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final userId = user != null ? user['id'] : null;

      print('📥 Fetching history for user: $userId');
      
      if (token == null) {
        print('❌ No token, cannot fetch history');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/predict/history?limit=$limit&skip=$skip'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-User-ID': userId ?? '',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📥 History response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Got ${data.length} history items');
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Failed to get history: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Failed to get history: $e');
    }
    return [];
  }
  
  static Future<int> getHistoryCount() async {
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final userId = user != null ? user['id'] : null;
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/predict/history/count'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-User-ID': userId ?? '',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['total'];
      }
    } catch (e) {
      print('Failed to get count: $e');
    }
    return 0;
  }
  
  static Future<bool> deletePrediction(String predictionId) async {
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final userId = user != null ? user['id'] : null;
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/predict/history/$predictionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'X-User-ID': userId ?? '',
        },
      ).timeout(const Duration(seconds: 15));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to delete: $e');
      return false;
    }
  }
}
