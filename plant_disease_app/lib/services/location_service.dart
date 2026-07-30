import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const _kLocationEnabled = 'location_access_enabled';
  static const _kLastLat = 'last_lat';
  static const _kLastLng = 'last_lng';
  static const _kLastCity = 'last_city';
  static const _kLastState = 'last_state';
  static const _kLastCountry = 'last_country';
  static const _kLastFormatted = 'last_formatted_location';

  /// Checks if location permission is granted in the OS.
  static Future<bool> hasOSPermission() async {
    final status = await Permission.location.status;
    return status.isGranted || status.isLimited;
  }

  /// Checks if location features are enabled in app preferences.
  static Future<bool> isLocationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPerm = await hasOSPermission();
    if (!hasPerm) {
      // Force app preference to false if OS permission was revoked
      await prefs.setBool(_kLocationEnabled, false);
      return false;
    }
    return prefs.getBool(_kLocationEnabled) ?? false;
  }

  /// Sets the location preference state.
  static Future<void> setLocationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLocationEnabled, enabled);
    if (enabled) {
      await updateCurrentLocation();
    }
  }

  /// Reverse geocoding helper using native Flutter geocoding package.
  static Future<Map<String, String>> _getAddressFromCoordinates(double lat, double lng) async {
    String city = 'Bagalkot';
    String state = 'Karnataka';
    String country = 'India';
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(lat, lng).timeout(const Duration(seconds: 4));
      if (placeMarks.isNotEmpty) {
        Placemark place = placeMarks.first;
        city = place.locality ?? place.subAdministrativeArea ?? place.subLocality ?? 'Bagalkot';
        state = place.administrativeArea ?? 'Karnataka';
        country = place.country ?? 'India';
      }
    } catch (_) {
      // Fallback to Nominatim if native geocoding fails or times out
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1');
        final response = await http.get(url, headers: {'User-Agent': 'PlantSenseAI_App/1.0'}).timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final address = data['address'] ?? {};
          city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? 'Bagalkot';
          state = address['state'] ?? address['state_district'] ?? 'Karnataka';
          country = address['country'] ?? 'India';
        }
      } catch (_) {}
    }
    return {'city': city, 'state': state, 'country': country};
  }

  /// Fetches the current location data (either fresh from GPS or cached fallback).
  static Future<Map<String, dynamic>> getCurrentLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPerm = await hasOSPermission();
    if (!hasPerm) {
      return {'location_access': false};
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final lat = position.latitude;
      final lng = position.longitude;
      
      // Get address
      final address = await _getAddressFromCoordinates(lat, lng);
      final city = address['city']!;
      final state = address['state']!;
      final country = address['country']!;
      final formatted = '$city, $state';
      
      await prefs.setDouble(_kLastLat, lat);
      await prefs.setDouble(_kLastLng, lng);
      await prefs.setString(_kLastCity, city);
      await prefs.setString(_kLastState, state);
      await prefs.setString(_kLastCountry, country);
      await prefs.setString(_kLastFormatted, formatted);

      return {
        'location_access': true,
        'latitude': lat,
        'longitude': lng,
        'city': city,
        'state': state,
        'country': country,
        'location': formatted,
        'formatted_coords': '${lat.toStringAsFixed(5)}° N, ${lng.toStringAsFixed(5)}° E'
      };
    } catch (e) {
      final lat = prefs.getDouble(_kLastLat);
      final lng = prefs.getDouble(_kLastLng);
      final city = prefs.getString(_kLastCity) ?? 'Bagalkot';
      final state = prefs.getString(_kLastState) ?? 'Karnataka';
      final country = prefs.getString(_kLastCountry) ?? 'India';
      final formatted = prefs.getString(_kLastFormatted) ?? '$city, $state';
      
      if (lat != null && lng != null) {
        return {
          'location_access': true,
          'latitude': lat,
          'longitude': lng,
          'city': city,
          'state': state,
          'country': country,
          'location': formatted,
          'formatted_coords': '${lat.toStringAsFixed(5)}° N, ${lng.toStringAsFixed(5)}° E',
          'cached': true,
        };
      }
      return {'location_access': true, 'error': 'Could not fetch GPS coordinates'};
    }
  }

  /// Request permissions via Geolocator (compatibility helper).
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      await setLocationEnabled(true);
      return true;
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    return false;
  }

  /// Forces an update of the current location cached data.
  static Future<void> updateCurrentLocation() async {
    final hasPerm = await hasOSPermission();
    if (!hasPerm) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      final lat = position.latitude;
      final lng = position.longitude;
      
      final address = await _getAddressFromCoordinates(lat, lng);
      final city = address['city']!;
      final state = address['state']!;
      final country = address['country']!;
      final formatted = '$city, $state';
      
      await prefs.setDouble(_kLastLat, lat);
      await prefs.setDouble(_kLastLng, lng);
      await prefs.setString(_kLastCity, city);
      await prefs.setString(_kLastState, state);
      await prefs.setString(_kLastCountry, country);
      await prefs.setString(_kLastFormatted, formatted);
    } catch (_) {}
  }
}
