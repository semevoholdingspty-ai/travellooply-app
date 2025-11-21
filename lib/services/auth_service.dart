import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication Service
/// Handles user authentication, registration, and session management
class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String country,
    required List<String> languages,
    required String travelIntent,
    required List<String> preferences,
    required String socialVibe,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Mock user creation for demo
      // In production: Use Firebase Auth here
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      _currentUser = UserModel(
        id: userId,
        username: username,
        email: email,
        country: country,
        languages: languages,
        travelIntent: travelIntent,
        preferences: preferences,
        socialVibe: socialVibe,
        trustScore: 50.0,
        location: const GeoPoint(37.7749, -122.4194), // San Francisco default
        isOnline: true,
        createdAt: DateTime.now(),
        isPremium: false,
      );

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ User signed up: ${_currentUser!.username}');
      }

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('❌ Sign up error: $e');
      }
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Mock sign in for demo
      // In production: Use Firebase Auth here
      _currentUser = UserModel(
        id: 'demo_user_123',
        username: 'Demo Traveler',
        email: email,
        country: 'United States',
        languages: ['English'],
        travelIntent: 'Explore',
        preferences: ['Coffee', 'Photography', 'Walk', 'Eat', 'Museums'],
        socialVibe: 'Friendly',
        trustScore: 85.0,
        location: const GeoPoint(37.7749, -122.4194),
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastSeen: DateTime.now(),
        isPremium: false,
      );

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ User signed in: ${_currentUser!.username}');
      }

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('❌ Sign in error: $e');
      }
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('✅ User signed out');
    }
  }

  /// Update user location
  Future<void> updateLocation(double latitude, double longitude) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        location: GeoPoint(latitude, longitude),
      );
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('✅ Location updated: $latitude, $longitude');
      }
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _currentUser = updatedUser;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('✅ Profile updated');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Profile update error: $e');
      }
      return false;
    }
  }

  /// Check if user has premium
  bool get hasPremium => _currentUser?.isPremium ?? false;

  /// Upgrade to premium
  Future<bool> upgradeToPremium() async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isPremium: true);
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('✅ Upgraded to premium');
      }
      
      return true;
    }
    return false;
  }
}
