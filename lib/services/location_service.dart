import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Location Service
/// Handles GPS location tracking and permissions
class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  String? get error => _error;
  
  GeoPoint? get currentGeoPoint {
    if (_currentPosition != null) {
      return GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);
    }
    return null;
  }

  /// Check and request location permissions
  Future<bool> checkPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled';
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions denied';
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions permanently denied';
        notifyListeners();
        return false;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error checking permissions: $e';
      notifyListeners();
      if (kDebugMode) {
        debugPrint('❌ Permission check error: $e');
      }
      return false;
    }
  }

  /// Get current location once
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('✅ Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      }

      return _currentPosition;
    } catch (e) {
      _error = 'Error getting location: $e';
      notifyListeners();
      if (kDebugMode) {
        debugPrint('❌ Location error: $e');
      }
      return null;
    }
  }

  /// Start continuous location tracking
  Future<void> startTracking() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return;

    _isTracking = true;
    notifyListeners();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    ).listen(
      (Position position) {
        _currentPosition = position;
        notifyListeners();
        
        if (kDebugMode) {
          debugPrint('📍 Location updated: ${position.latitude}, ${position.longitude}');
        }
      },
      onError: (error) {
        _error = 'Tracking error: $error';
        _isTracking = false;
        notifyListeners();
        
        if (kDebugMode) {
          debugPrint('❌ Tracking error: $error');
        }
      },
    );
  }

  /// Stop location tracking
  void stopTracking() {
    _isTracking = false;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🛑 Location tracking stopped');
    }
  }

  /// Calculate distance between two points (in kilometers)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Calculate distance from current position (in kilometers)
  double? distanceFromCurrent(double latitude, double longitude) {
    if (_currentPosition == null) return null;
    
    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Check if user is within radius of a point
  bool isWithinRadius({
    required double targetLat,
    required double targetLon,
    required double radiusKm,
  }) {
    if (_currentPosition == null) return false;
    
    final distance = calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetLat,
      targetLon,
    );
    
    return distance <= radiusKm;
  }

  /// Get mock location for demo purposes
  Position getMockLocation() {
    // San Francisco coordinates
    return Position(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  /// Use mock location for testing
  void useMockLocation() {
    _currentPosition = getMockLocation();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('📍 Using mock location: San Francisco');
    }
  }
}
