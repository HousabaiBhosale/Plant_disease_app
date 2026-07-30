import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class PermissionProvider extends ChangeNotifier {
  PermissionStatus _status = PermissionStatus.denied;
  bool _isLoading = false;

  PermissionStatus get status => _status;
  bool get isLoading => _isLoading;

  bool get isGranted =>
      _status == PermissionStatus.granted ||
      _status == PermissionStatus.limited;

  bool get isDenied =>
      _status == PermissionStatus.denied;

  bool get isPermanentlyDenied =>
      _status == PermissionStatus.permanentlyDenied;

  /// Check current permission status
  Future<void> checkPermissionStatus() async {
    _isLoading = true;
    notifyListeners();

    _status = await Permission.location.status;

    _isLoading = false;
    notifyListeners();
  }

  /// Request location permission (Android native dialog)
  Future<bool> requestLocationPermission() async {
    _isLoading = true;
    notifyListeners();

    _status = await Permission.location.request();

    if (isGranted) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();

        // Check again after returning from Settings
        serviceEnabled = await Geolocator.isLocationServiceEnabled();

        if (!serviceEnabled) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      await LocationService.setLocationEnabled(true);

      try {
        await LocationService.updateCurrentLocation();
      } catch (_) {
        // Ignore location update errors
      }
    } else {
      await LocationService.setLocationEnabled(false);
    }

    _isLoading = false;
    notifyListeners();

    return isGranted;
  }

  /// Refresh permission status after returning from Settings
  Future<void> refreshStatus() async {
    _status = await Permission.location.status;

    if (isGranted) {
      await LocationService.setLocationEnabled(true);

      try {
        await LocationService.updateCurrentLocation();
      } catch (_) {
        // Ignore location update errors
      }
    } else {
      await LocationService.setLocationEnabled(false);
    }

    notifyListeners();
  }

  /// Open App Settings
  Future<void> openSettings() async {
    await openAppSettings();
  }
}