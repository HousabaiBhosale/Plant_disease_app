import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class PredictionHistoryService {
  static String get baseUrl => AuthService.baseUrl;
  static const String _localHistoryKey = 'local_scan_history';

  static Future<void> saveLocalHistoryItem(Map<String, dynamic> item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existing = prefs.getString(_localHistoryKey);
      List<dynamic> list = [];
      if (existing != null && existing.isNotEmpty) {
        list = jsonDecode(existing);
      }
      list.insert(0, item);
      if (list.length > 100) {
        list = list.sublist(0, 100);
      }
      await prefs.setString(_localHistoryKey, jsonEncode(list));
      print('✅ Saved scan locally: ${item['predicted_disease']}');
    } catch (e) {
      print('❌ Failed to save local history item: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existing = prefs.getString(_localHistoryKey);
      if (existing != null && existing.isNotEmpty) {
        final List<dynamic> list = jsonDecode(existing);
        return List<Map<String, dynamic>>.from(list);
      }
    } catch (e) {
      print('❌ Failed to load local history: $e');
    }
    return [];
  }
  
  static Future<List<Map<String, dynamic>>> getHistory({
    int limit = 20,
    int skip = 0,
  }) async {
    List<Map<String, dynamic>> localHistory = await getLocalHistory();
    List<Map<String, dynamic>> cloudHistory = [];

    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final userId = user != null ? user['id'] : null;

      print('📥 Fetching history for user: $userId');
      
      if (token != null) {
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
          print('✅ Got ${data.length} cloud history items');
          cloudHistory = List<Map<String, dynamic>>.from(data);
        } else {
          print('❌ Failed to get cloud history: ${response.body}');
        }
      } else {
        print('ℹ️ No token found, showing local scan history.');
      }
    } catch (e) {
      print('⚠️ Could not fetch cloud history ($e). Showing local scan history.');
    }

    // Combine and sort by created_at descending
    final Map<String, Map<String, dynamic>> combined = {};
    for (var item in cloudHistory) {
      final id = item['id'] ?? item['_id'] ?? item['created_at'].toString();
      combined[id.toString()] = item;
    }
    for (var item in localHistory) {
      final id = item['id'] ?? item['_id'] ?? item['created_at'].toString();
      if (!combined.containsKey(id.toString())) {
        combined[id.toString()] = item;
      }
    }

    final List<Map<String, dynamic>> result = combined.values.toList();
    result.sort((a, b) {
      final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    if (skip < result.length) {
      return result.sublist(skip, (skip + limit) < result.length ? (skip + limit) : result.length);
    }
    return [];
  }
  
  static Future<int> getHistoryCount() async {
    final localCount = (await getLocalHistory()).length;
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final userId = user != null ? user['id'] : null;
      
      if (token != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/api/predict/history/count'),
          headers: {
            'Authorization': 'Bearer $token',
            'X-User-ID': userId ?? '',
          },
        ).timeout(const Duration(seconds: 15));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final cloudCount = data['total'] as int;
          return cloudCount > localCount ? cloudCount : localCount;
        }
      }
    } catch (e) {
      print('Failed to get count: $e');
    }
    return localCount;
  }
  
  static Future<bool> deletePrediction(String predictionId) async {
    bool localDeleted = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existing = prefs.getString(_localHistoryKey);
      if (existing != null && existing.isNotEmpty) {
        List<dynamic> list = jsonDecode(existing);
        final initialLen = list.length;
        list.removeWhere((item) => (item['id'] == predictionId || item['_id'] == predictionId));
        if (list.length < initialLen) {
          await prefs.setString(_localHistoryKey, jsonEncode(list));
          localDeleted = true;
        }
      }
    } catch (e) {
      print('Failed to delete locally: $e');
    }

    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final userId = user != null ? user['id'] : null;
      
      if (token != null) {
        final response = await http.delete(
          Uri.parse('$baseUrl/api/predict/history/$predictionId'),
          headers: {
            'Authorization': 'Bearer $token',
            'X-User-ID': userId ?? '',
          },
        ).timeout(const Duration(seconds: 15));
        
        if (response.statusCode == 200) {
          return true;
        }
      }
    } catch (e) {
      print('Failed to delete cloud item: $e');
    }
    return localDeleted;
  }
}
