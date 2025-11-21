import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/circle_model.dart';
import '../models/micro_event_model.dart';
import '../models/chat_message_model.dart';

/// Firestore Service
/// Handles all Firestore database operations
class FirestoreService {
  // Mock data storage for demo (replace with actual Firestore in production)
  static final List<CircleModel> _mockCircles = [];
  static final List<MicroEventModel> _mockEvents = [];
  static final Map<String, List<ChatMessageModel>> _mockMessages = {};

  // Initialize mock data
  static void initializeMockData() {
    if (_mockCircles.isEmpty) {
      _mockCircles.addAll([
        CircleModel(
          id: 'circle_1',
          activityType: 'Explore',
          memberIds: ['user1', 'user2', 'user3', 'user4', 'user5'],
          radius: 800.0,
          centerLocation: const GeoPoint(37.7749, -122.4194),
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          expiresAt: DateTime.now().add(const Duration(hours: 18)),
          status: 'active',
          creatorId: 'user1',
        ),
        CircleModel(
          id: 'circle_2',
          activityType: 'Coffee',
          memberIds: ['user2', 'user3', 'user4'],
          radius: 500.0,
          centerLocation: const GeoPoint(37.7849, -122.4094),
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          expiresAt: DateTime.now().add(const Duration(hours: 12)),
          status: 'active',
          creatorId: 'user2',
        ),
        CircleModel(
          id: 'circle_3',
          activityType: 'Nightlife',
          memberIds: ['user1', 'user3', 'user5', 'user6', 'user7', 'user8', 'user9'],
          radius: 1000.0,
          centerLocation: const GeoPoint(37.7649, -122.4294),
          createdAt: DateTime.now().subtract(const Duration(hours: 18)),
          expiresAt: DateTime.now().add(const Duration(hours: 6)),
          status: 'active',
          creatorId: 'user5',
        ),
        CircleModel(
          id: 'circle_4',
          activityType: 'Eat',
          memberIds: ['user4', 'user5', 'user6', 'user7'],
          radius: 600.0,
          centerLocation: const GeoPoint(37.7549, -122.4394),
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          expiresAt: DateTime.now().add(const Duration(hours: 20)),
          status: 'active',
          creatorId: 'user4',
        ),
      ]);
    }

    if (_mockEvents.isEmpty) {
      _mockEvents.addAll([
        MicroEventModel(
          id: 'event_1',
          creatorId: 'user1',
          type: 'Coffee',
          description: 'Coffee Meetup at Central Cafe',
          maxParticipants: 5,
          participantIds: ['user1', 'user2', 'user3'],
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
          location: const GeoPoint(37.7749, -122.4194),
          status: 'upcoming',
          circleId: 'circle_2',
        ),
        MicroEventModel(
          id: 'event_2',
          creatorId: 'user3',
          type: 'Photography',
          description: 'Photography Walk in Old Town',
          maxParticipants: 8,
          participantIds: ['user3', 'user4', 'user5', 'user6'],
          startTime: DateTime.now().add(const Duration(hours: 4, minutes: 30)),
          endTime: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
          location: const GeoPoint(37.7649, -122.4294),
          status: 'upcoming',
        ),
        MicroEventModel(
          id: 'event_3',
          creatorId: 'user5',
          type: 'Eat',
          description: 'Dinner at Local Restaurant',
          maxParticipants: 10,
          participantIds: ['user5', 'user6', 'user7', 'user8', 'user9'],
          startTime: DateTime.now().add(const Duration(hours: 6)),
          endTime: DateTime.now().add(const Duration(hours: 7, minutes: 30)),
          location: const GeoPoint(37.7549, -122.4394),
          status: 'upcoming',
        ),
      ]);
    }
  }

  /// Get nearby circles (mock implementation)
  static Future<List<CircleModel>> getNearbyCircles({
    required GeoPoint userLocation,
    double radiusKm = 5.0,
  }) async {
    initializeMockData();
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    // In production: Use Firestore geo queries
    return _mockCircles.where((circle) => circle.status == 'active').toList();
  }

  /// Get circle by ID
  static Future<CircleModel?> getCircleById(String circleId) async {
    initializeMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _mockCircles.firstWhere((circle) => circle.id == circleId);
    } catch (e) {
      return null;
    }
  }

  /// Join a circle
  static Future<bool> joinCircle(String circleId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final circleIndex = _mockCircles.indexWhere((c) => c.id == circleId);
    if (circleIndex != -1) {
      final circle = _mockCircles[circleIndex];
      if (!circle.memberIds.contains(userId) && circle.memberIds.length < 10) {
        circle.memberIds.add(userId);
        
        if (kDebugMode) {
          debugPrint('✅ Joined circle: $circleId');
        }
        return true;
      }
    }
    return false;
  }

  /// Leave a circle
  static Future<bool> leaveCircle(String circleId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final circleIndex = _mockCircles.indexWhere((c) => c.id == circleId);
    if (circleIndex != -1) {
      _mockCircles[circleIndex].memberIds.remove(userId);
      
      if (kDebugMode) {
        debugPrint('✅ Left circle: $circleId');
      }
      return true;
    }
    return false;
  }

  /// Get nearby events
  static Future<List<MicroEventModel>> getNearbyEvents({
    required GeoPoint userLocation,
    double radiusKm = 5.0,
  }) async {
    initializeMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockEvents.where((event) => event.status == 'upcoming').toList();
  }

  /// Create a new event
  static Future<String?> createEvent(MicroEventModel event) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _mockEvents.add(event);
    
    if (kDebugMode) {
      debugPrint('✅ Event created: ${event.type}');
    }
    
    return event.id;
  }

  /// Join an event
  static Future<bool> joinEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final eventIndex = _mockEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _mockEvents[eventIndex];
      if (!event.participantIds.contains(userId) && !event.isFull) {
        event.participantIds.add(userId);
        
        if (kDebugMode) {
          debugPrint('✅ Joined event: $eventId');
        }
        return true;
      }
    }
    return false;
  }

  /// Get messages for a circle
  static Future<List<ChatMessageModel>> getCircleMessages(String circleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _mockMessages[circleId] ?? [];
  }

  /// Send a message to a circle
  static Future<bool> sendMessage(ChatMessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_mockMessages.containsKey(message.circleId)) {
      _mockMessages[message.circleId] = [];
    }
    
    _mockMessages[message.circleId]!.add(message);
    
    if (kDebugMode) {
      debugPrint('✅ Message sent to circle: ${message.circleId}');
    }
    
    return true;
  }

  /// Stream circle messages (real-time)
  static Stream<List<ChatMessageModel>> streamCircleMessages(String circleId) {
    // In production: Use Firestore snapshots
    return Stream.periodic(const Duration(seconds: 2), (_) {
      return _mockMessages[circleId] ?? [];
    });
  }

  /// Clean up expired messages (auto-delete after 24h)
  static Future<void> cleanExpiredMessages() async {
    final now = DateTime.now();
    
    _mockMessages.forEach((circleId, messages) {
      messages.removeWhere((msg) => msg.expiresAt.isBefore(now));
    });
    
    if (kDebugMode) {
      debugPrint('✅ Cleaned expired messages');
    }
  }
}
