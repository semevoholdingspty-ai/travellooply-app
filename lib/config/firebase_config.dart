/// Firebase Configuration
/// 
/// Toggle this to switch between mock and real Firebase implementations.
/// 
/// - **false**: Uses mock services with in-memory data (for demo/testing)
/// - **true**: Uses real Firebase services (requires firebase_options.dart)

class FirebaseConfig {
  /// Set to true to use real Firebase backend
  static const bool USE_REAL_FIREBASE = true;
}
