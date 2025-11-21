import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// PRODUCTION Authentication Service
/// Real Firebase Authentication implementation
class AuthServiceReal extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize auth state listener
  AuthServiceReal() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      // Load user data from Firestore
      await _loadUserData(firebaseUser.uid);
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading user data: $e');
      }
    }
  }

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
    GeoPoint? location,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }

      // Create user document in Firestore
      final userData = {
        'username': username,
        'email': email,
        'country': country,
        'languages': languages,
        'travelIntent': travelIntent,
        'preferences': preferences,
        'socialVibe': socialVibe,
        'trustScore': 50.0,
        'location': location ?? const GeoPoint(0, 0),
        'isOnline': true,
        'emailVerified': false,
        'phoneVerified': false,
        'idVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'isPremium': false,
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // Load the created user data
      await _loadUserData(userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ User signed up: $username');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('❌ Sign up error: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('❌ Sign up error: $e');
      }
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }

      // Update last seen
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // Load user data
      await _loadUserData(userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ User signed in: ${_currentUser?.username}');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('❌ Sign in error: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
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
    try {
      // Update online status
      if (_currentUser != null) {
        await _firestore.collection('users').doc(_currentUser!.id).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      await _auth.signOut();
      _currentUser = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('✅ User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sign out error: $e');
      }
    }
  }

  /// Update user location
  Future<void> updateLocation(double latitude, double longitude) async {
    if (_currentUser != null) {
      try {
        final newLocation = GeoPoint(latitude, longitude);
        
        await _firestore.collection('users').doc(_currentUser!.id).update({
          'location': newLocation,
          'lastSeen': FieldValue.serverTimestamp(),
        });

        _currentUser = _currentUser!.copyWith(location: newLocation);
        notifyListeners();

        if (kDebugMode) {
          debugPrint('✅ Location updated: $latitude, $longitude');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Location update error: $e');
        }
      }
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toFirestore());

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
      try {
        await _firestore.collection('users').doc(_currentUser!.id).update({
          'isPremium': true,
        });

        _currentUser = _currentUser!.copyWith(isPremium: true);
        notifyListeners();

        if (kDebugMode) {
          debugPrint('✅ Upgraded to premium');
        }

        return true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Premium upgrade error: $e');
        }
      }
    }
    return false;
  }

  /// Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication error: $code';
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
