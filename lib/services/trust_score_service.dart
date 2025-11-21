import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trust_event_model.dart';

/// Trust Score Management System
/// Tracks user behavior and adjusts trust scores dynamically
class TrustScoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Trust score ranges
  static const double MIN_SCORE = 0.0;
  static const double MAX_SCORE = 100.0;
  static const double INITIAL_SCORE = 50.0;
  
  /// Update trust score based on event
  static Future<bool> updateTrustScore({
    required String userId,
    required String eventType,
    required double delta,
    String? details,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) return false;
      
      final currentScore = (userDoc.data()?['trustScore'] as num?)?.toDouble() ?? INITIAL_SCORE;
      final newScore = (currentScore + delta).clamp(MIN_SCORE, MAX_SCORE);
      
      // Update user's trust score
      await userRef.update({'trustScore': newScore});
      
      // Log trust event
      final trustEvent = TrustEventModel(
        id: '',
        userId: userId,
        eventType: eventType,
        delta: delta,
        previousScore: currentScore,
        newScore: newScore,
        details: details,
        timestamp: DateTime.now(),
      );
      
      await _firestore.collection('trust_events').add(trustEvent.toFirestore());
      
      if (kDebugMode) {
        debugPrint('✅ Trust score updated: $userId | $eventType | $currentScore → $newScore');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating trust score: $e');
      }
      return false;
    }
  }
  
  /// Positive events (increase trust score)
  static Future<void> recordCircleJoined(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'circle_joined',
      delta: 2.0,
      details: 'Joined a circle',
    );
  }
  
  static Future<void> recordEventCreated(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'event_created',
      delta: 5.0,
      details: 'Created a micro-event',
    );
  }
  
  static Future<void> recordEventAttended(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'event_attended',
      delta: 3.0,
      details: 'Attended an event',
    );
  }
  
  static Future<void> recordMessageSent(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'message_sent',
      delta: 0.5,
      details: 'Sent a message',
    );
  }
  
  static Future<void> recordProfileCompleted(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'profile_completed',
      delta: 10.0,
      details: 'Completed profile setup',
    );
  }
  
  static Future<void> recordIdentityVerified(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'identity_verified',
      delta: 15.0,
      details: 'Verified identity',
    );
  }
  
  /// Negative events (decrease trust score)
  static Future<void> recordCircleAbandoned(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'circle_abandoned',
      delta: -5.0,
      details: 'Left circle without notice',
    );
  }
  
  static Future<void> recordEventNoShow(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'event_no_show',
      delta: -8.0,
      details: 'No-show for event',
    );
  }
  
  static Future<void> recordSpamReport(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'spam_reported',
      delta: -20.0,
      details: 'Reported for spam',
    );
  }
  
  static Future<void> recordInappropriateBehavior(String userId) async {
    await updateTrustScore(
      userId: userId,
      eventType: 'inappropriate_behavior',
      delta: -15.0,
      details: 'Inappropriate behavior reported',
    );
  }
  
  /// Get trust score history
  static Future<List<TrustEventModel>> getTrustHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('trust_events')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs
          .map((doc) => TrustEventModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching trust history: $e');
      }
      return [];
    }
  }
  
  /// Get trust score badge
  static String getTrustBadge(double score) {
    if (score >= 90) return 'Legendary Traveler';
    if (score >= 80) return 'Trusted Traveler';
    if (score >= 70) return 'Verified Traveler';
    if (score >= 60) return 'Active Traveler';
    if (score >= 50) return 'New Traveler';
    if (score >= 30) return 'Cautious Traveler';
    return 'Low Trust';
  }
  
  /// Get trust score color
  static int getTrustColor(double score) {
    if (score >= 80) return 0xFF4CAF50; // Green
    if (score >= 60) return 0xFF2196F3; // Blue
    if (score >= 40) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }
}
