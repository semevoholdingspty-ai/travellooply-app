import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/circle_model.dart';

/// Proximity-based Circle Matching Algorithm
/// Groups travelers within 300m-1200m based on:
/// - Location proximity
/// - Activity intent
/// - Social vibe compatibility
/// - Language overlap
class CircleMatchingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Proximity thresholds
  static const double MIN_RADIUS_METERS = 300;
  static const double MAX_RADIUS_METERS = 1200;
  static const int MIN_CIRCLE_SIZE = 2;
  static const int MAX_CIRCLE_SIZE = 10;
  
  /// Find or create matching circle for a user
  static Future<CircleModel?> findOrCreateCircle({
    required UserModel currentUser,
    String? preferredActivity,
  }) async {
    try {
      // Step 1: Find nearby users (within 1200m)
      final nearbyUsers = await _findNearbyUsers(
        currentUser.location,
        radiusKm: MAX_RADIUS_METERS / 1000,
      );
      
      if (nearbyUsers.isEmpty) {
        if (kDebugMode) {
          debugPrint('No nearby users found');
        }
        return null;
      }
      
      // Step 2: Filter compatible users
      final compatibleUsers = _filterCompatibleUsers(
        currentUser,
        nearbyUsers,
        preferredActivity: preferredActivity,
      );
      
      if (compatibleUsers.isEmpty) {
        if (kDebugMode) {
          debugPrint('No compatible users found');
        }
        return null;
      }
      
      // Step 3: Check for existing circles
      final existingCircle = await _findExistingCircle(
        currentUser,
        compatibleUsers,
        preferredActivity: preferredActivity,
      );
      
      if (existingCircle != null) {
        if (kDebugMode) {
          debugPrint('Found existing circle: ${existingCircle.id}');
        }
        return existingCircle;
      }
      
      // Step 4: Create new circle if enough users
      if (compatibleUsers.length >= MIN_CIRCLE_SIZE - 1) {
        return await _createNewCircle(
          currentUser,
          compatibleUsers.take(MAX_CIRCLE_SIZE - 1).toList(),
          preferredActivity: preferredActivity,
        );
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in circle matching: $e');
      }
      return null;
    }
  }
  
  /// Find users within radius
  static Future<List<UserModel>> _findNearbyUsers(
    GeoPoint userLocation,
    {required double radiusKm}
  ) async {
    try {
      // Simple approach: Get all online users and filter by distance
      // For production: Use GeoFlutterFire or Firestore Extensions
      final snapshot = await _firestore
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .limit(100)
          .get();
      
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      // Filter by distance
      final nearbyUsers = users.where((user) {
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          user.location.latitude,
          user.location.longitude,
        );
        return distance <= radiusKm && distance >= (MIN_RADIUS_METERS / 1000);
      }).toList();
      
      return nearbyUsers;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error finding nearby users: $e');
      }
      return [];
    }
  }
  
  /// Filter users by compatibility
  static List<UserModel> _filterCompatibleUsers(
    UserModel currentUser,
    List<UserModel> candidates,
    {String? preferredActivity}
  ) {
    return candidates.where((candidate) {
      // Skip self
      if (candidate.id == currentUser.id) return false;
      
      // Calculate compatibility score
      final score = _calculateCompatibilityScore(
        currentUser,
        candidate,
        preferredActivity: preferredActivity,
      );
      
      // Threshold: 0.4 or higher
      return score >= 0.4;
    }).toList()
      ..sort((a, b) {
        final scoreA = _calculateCompatibilityScore(currentUser, a, preferredActivity: preferredActivity);
        final scoreB = _calculateCompatibilityScore(currentUser, b, preferredActivity: preferredActivity);
        return scoreB.compareTo(scoreA); // Descending
      });
  }
  
  /// Calculate compatibility score (0.0 - 1.0)
  static double _calculateCompatibilityScore(
    UserModel user1,
    UserModel user2,
    {String? preferredActivity}
  ) {
    double score = 0.0;
    
    // 1. Activity intent match (40% weight)
    if (preferredActivity != null) {
      if (user2.preferences.contains(preferredActivity)) {
        score += 0.4;
      }
    } else if (user1.travelIntent == user2.travelIntent) {
      score += 0.4;
    }
    
    // 2. Social vibe compatibility (30% weight)
    final vibeScore = _calculateVibeCompatibility(user1.socialVibe, user2.socialVibe);
    score += vibeScore * 0.3;
    
    // 3. Language overlap (20% weight)
    final commonLanguages = user1.languages.toSet().intersection(user2.languages.toSet());
    if (commonLanguages.isNotEmpty) {
      score += 0.2;
    }
    
    // 4. Preference overlap (10% weight)
    final commonPreferences = user1.preferences.toSet().intersection(user2.preferences.toSet());
    final overlapRatio = commonPreferences.length / max(user1.preferences.length, user2.preferences.length);
    score += overlapRatio * 0.1;
    
    return score.clamp(0.0, 1.0);
  }
  
  /// Calculate social vibe compatibility
  static double _calculateVibeCompatibility(String vibe1, String vibe2) {
    if (vibe1 == vibe2) return 1.0;
    
    // Compatibility matrix
    final compatibilityMap = {
      'Introvert': {'Introvert': 1.0, 'Friendly': 0.6, 'Highly Social': 0.3},
      'Friendly': {'Introvert': 0.6, 'Friendly': 1.0, 'Highly Social': 0.8},
      'Highly Social': {'Introvert': 0.3, 'Friendly': 0.8, 'Highly Social': 1.0},
    };
    
    return compatibilityMap[vibe1]?[vibe2] ?? 0.5;
  }
  
  /// Find existing circle that matches criteria
  static Future<CircleModel?> _findExistingCircle(
    UserModel currentUser,
    List<UserModel> compatibleUsers,
    {String? preferredActivity}
  ) async {
    try {
      // Find circles within radius
      final snapshot = await _firestore
          .collection('circles')
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .get();
      
      for (var doc in snapshot.docs) {
        final circle = CircleModel.fromFirestore(doc.data(), doc.id);
        
        // Check if circle is within proximity
        final distance = _calculateDistance(
          currentUser.location.latitude,
          currentUser.location.longitude,
          circle.centerLocation.latitude,
          circle.centerLocation.longitude,
        );
        
        if (distance > (MAX_RADIUS_METERS / 1000)) continue;
        
        // Check activity match
        if (preferredActivity != null && circle.activityType != preferredActivity) {
          continue;
        }
        
        // Check if any compatible user is in this circle
        final hasCompatibleMember = compatibleUsers.any(
          (user) => circle.memberIds.contains(user.id)
        );
        
        if (hasCompatibleMember && circle.memberIds.length < MAX_CIRCLE_SIZE) {
          return circle;
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error finding existing circle: $e');
      }
      return null;
    }
  }
  
  /// Create new circle
  static Future<CircleModel> _createNewCircle(
    UserModel currentUser,
    List<UserModel> members,
    {String? preferredActivity}
  ) async {
    // Calculate center location (average of all members)
    double sumLat = currentUser.location.latitude;
    double sumLng = currentUser.location.longitude;
    
    for (var member in members) {
      sumLat += member.location.latitude;
      sumLng += member.location.longitude;
    }
    
    final centerLat = sumLat / (members.length + 1);
    final centerLng = sumLng / (members.length + 1);
    
    // Determine activity type
    final activityType = preferredActivity ?? currentUser.travelIntent;
    
    // Create circle
    final now = DateTime.now();
    final circle = CircleModel(
      id: '',
      activityType: activityType,
      memberIds: [currentUser.id, ...members.map((m) => m.id)],
      radius: 800, // Default 800m
      centerLocation: GeoPoint(centerLat, centerLng),
      status: 'active',
      creatorId: currentUser.id,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
    
    // Save to Firestore
    final docRef = await _firestore.collection('circles').add(circle.toFirestore());
    
    if (kDebugMode) {
      debugPrint('✅ Created new circle: ${docRef.id} with ${circle.memberIds.length} members');
    }
    
    return circle.copyWith(id: docRef.id);
  }
  
  /// Calculate distance between two points (Haversine formula)
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

extension CircleModelCopyWith on CircleModel {
  CircleModel copyWith({String? id}) {
    return CircleModel(
      id: id ?? this.id,
      activityType: activityType,
      memberIds: memberIds,
      radius: radius,
      centerLocation: centerLocation,
      status: status,
      creatorId: creatorId,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}
