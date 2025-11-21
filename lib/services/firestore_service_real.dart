import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/circle_model.dart';
import '../models/micro_event_model.dart';
import '../models/chat_message_model.dart';

/// PRODUCTION Firestore Service
/// Real Firebase Firestore implementation
class FirestoreServiceReal {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get nearby circles using Firestore queries
  static Future<List<CircleModel>> getNearbyCircles({
    required GeoPoint userLocation,
    double radiusKm = 5.0,
  }) async {
    try {
      // Query active circles
      // Note: For production, consider using GeoFlutterFire for precise geo queries
      final QuerySnapshot snapshot = await _firestore
          .collection('circles')
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .get();

      final circles = snapshot.docs
          .map((doc) => CircleModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      // Filter by distance (simple implementation)
      // For production: Use GeoFlutterFire or Firestore Extensions
      final nearbyCircles = circles.where((circle) {
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          circle.centerLocation.latitude,
          circle.centerLocation.longitude,
        );
        return distance <= radiusKm;
      }).toList();

      if (kDebugMode) {
        debugPrint('✅ Found ${nearbyCircles.length} nearby circles');
      }

      return nearbyCircles;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting nearby circles: $e');
      }
      return [];
    }
  }

  /// Get circle by ID
  static Future<CircleModel?> getCircleById(String circleId) async {
    try {
      final doc = await _firestore.collection('circles').doc(circleId).get();

      if (doc.exists) {
        return CircleModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting circle: $e');
      }
      return null;
    }
  }

  /// Create a new circle
  static Future<String?> createCircle(CircleModel circle) async {
    try {
      final docRef = await _firestore.collection('circles').add(circle.toFirestore());

      if (kDebugMode) {
        debugPrint('✅ Circle created: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error creating circle: $e');
      }
      return null;
    }
  }

  /// Join a circle
  static Future<bool> joinCircle(String circleId, String userId) async {
    try {
      await _firestore.collection('circles').doc(circleId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });

      if (kDebugMode) {
        debugPrint('✅ Joined circle: $circleId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error joining circle: $e');
      }
      return false;
    }
  }

  /// Leave a circle
  static Future<bool> leaveCircle(String circleId, String userId) async {
    try {
      await _firestore.collection('circles').doc(circleId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });

      if (kDebugMode) {
        debugPrint('✅ Left circle: $circleId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error leaving circle: $e');
      }
      return false;
    }
  }

  /// Get nearby events
  static Future<List<MicroEventModel>> getNearbyEvents({
    required GeoPoint userLocation,
    double radiusKm = 5.0,
  }) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'upcoming')
          .where('startTime', isGreaterThan: Timestamp.now())
          .get();

      final events = snapshot.docs
          .map((doc) => MicroEventModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      // Filter by distance
      final nearbyEvents = events.where((event) {
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          event.location.latitude,
          event.location.longitude,
        );
        return distance <= radiusKm;
      }).toList();

      if (kDebugMode) {
        debugPrint('✅ Found ${nearbyEvents.length} nearby events');
      }

      return nearbyEvents;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting nearby events: $e');
      }
      return [];
    }
  }

  /// Create a new event
  static Future<String?> createEvent(MicroEventModel event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toFirestore());

      if (kDebugMode) {
        debugPrint('✅ Event created: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error creating event: $e');
      }
      return null;
    }
  }

  /// Join an event
  static Future<bool> joinEvent(String eventId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'participantIds': FieldValue.arrayUnion([userId]),
      });

      if (kDebugMode) {
        debugPrint('✅ Joined event: $eventId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error joining event: $e');
      }
      return false;
    }
  }

  /// Leave an event
  static Future<bool> leaveEvent(String eventId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'participantIds': FieldValue.arrayRemove([userId]),
      });

      if (kDebugMode) {
        debugPrint('✅ Left event: $eventId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error leaving event: $e');
      }
      return false;
    }
  }

  /// Get messages for a circle
  static Future<List<ChatMessageModel>> getCircleMessages(String circleId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .where('circleId', isEqualTo: circleId)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .orderBy('timestamp', descending: false)
          .get();

      final messages = snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      return messages;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting messages: $e');
      }
      return [];
    }
  }

  /// Send a message to a circle
  static Future<bool> sendMessage(ChatMessageModel message) async {
    try {
      await _firestore.collection('messages').add(message.toFirestore());

      if (kDebugMode) {
        debugPrint('✅ Message sent to circle: ${message.circleId}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending message: $e');
      }
      return false;
    }
  }

  /// Stream circle messages (real-time)
  static Stream<List<ChatMessageModel>> streamCircleMessages(String circleId) {
    return _firestore
        .collection('messages')
        .where('circleId', isEqualTo: circleId)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList();
    });
  }

  /// Clean up expired messages (Cloud Function recommended for production)
  static Future<void> cleanExpiredMessages() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('messages')
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        debugPrint('✅ Cleaned ${snapshot.docs.length} expired messages');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cleaning messages: $e');
      }
    }
  }

  /// Clean up expired circles
  static Future<void> cleanExpiredCircles() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('circles')
          .where('expiresAt', isLessThan: Timestamp.now())
          .where('status', isEqualTo: 'active')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'expired'});
      }

      await batch.commit();

      if (kDebugMode) {
        debugPrint('✅ Cleaned ${snapshot.docs.length} expired circles');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cleaning circles: $e');
      }
    }
  }

  /// Calculate distance between two points in kilometers
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
