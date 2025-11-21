import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Push Notification Service
/// Handles FCM notifications for circles, events, and messages
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;
  
  /// Initialize notifications
  static Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          debugPrint('✅ Notification permission granted');
        }
        
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        if (kDebugMode) {
          debugPrint('📱 FCM Token: $_fcmToken');
        }
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
        
        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Notification permission denied');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing notifications: $e');
      }
    }
  }
  
  /// Get FCM token
  static String? get fcmToken => _fcmToken;
  
  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('📬 Foreground message: ${message.notification?.title}');
    }
    
    // Show notification UI
    // You can use flutter_local_notifications for custom UI
  }
  
  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('👆 Notification tapped: ${message.data}');
    }
    
    // Navigate based on notification type
    final type = message.data['type'];
    switch (type) {
      case 'circle_invite':
        // Navigate to circle details
        break;
      case 'event_reminder':
        // Navigate to event details
        break;
      case 'new_message':
        // Navigate to chat
        break;
    }
  }
  
  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        debugPrint('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subscribing to topic: $e');
      }
    }
  }
  
  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        debugPrint('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error unsubscribing from topic: $e');
      }
    }
  }
}

/// Background message handler (top-level function required)
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('📭 Background message: ${message.notification?.title}');
  }
}
