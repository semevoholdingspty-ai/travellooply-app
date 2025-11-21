import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verification_tier.dart';

class VerificationService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Send email verification
  static Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        if (kDebugMode) {
          debugPrint('✅ Email verification sent to: ${user.email}');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending email verification: $e');
      }
      return false;
    }
  }
  
  /// Check if email is verified
  static Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      await user.reload();
      final isVerified = _auth.currentUser?.emailVerified ?? false;
      
      if (isVerified) {
        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
        });
        
        if (kDebugMode) {
          debugPrint('✅ Email verified for: ${user.email}');
        }
      }
      
      return isVerified;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking email verification: $e');
      }
      return false;
    }
  }
  
  /// Get user verification status
  static Future<VerificationStatus?> getVerificationStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      
      return VerificationStatus.fromFirestore(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting verification status: $e');
      }
      return null;
    }
  }
  
  /// Update verification status
  static Future<void> updateVerificationStatus({
    required String userId,
    bool? emailVerified,
    bool? phoneVerified,
    bool? idVerified,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (emailVerified != null) updates['emailVerified'] = emailVerified;
      if (phoneVerified != null) updates['phoneVerified'] = phoneVerified;
      if (idVerified != null) updates['idVerified'] = idVerified;
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
        
        if (kDebugMode) {
          debugPrint('✅ Verification status updated: $updates');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating verification status: $e');
      }
    }
  }
  
  /// Check feature access
  static Future<bool> canAccessFeature(String userId, String feature) async {
    final status = await getVerificationStatus(userId);
    if (status == null) return false;
    
    switch (feature) {
      case 'browse':
        return status.canBrowse;
      case 'view_circles':
        return status.canViewCircles;
      case 'join_circles':
        return status.canJoinCircles;
      case 'create_circles':
        return status.canCreateCircles;
      case 'create_events':
        return status.canCreateEvents;
      case 'send_messages':
        return status.canSendMessages;
      case 'premium':
        return status.canAccessPremium;
      case 'host_large_events':
        return status.canHostLargeEvents;
      default:
        return false;
    }
  }
  
  /// Show verification required dialog
  static String getVerificationMessage(String feature, VerificationStatus status) {
    if (!status.emailVerified) {
      return 'Please verify your email to $feature. Check your inbox for the verification link.';
    }
    
    if (status.trustScore < 30) {
      return 'Build your trust score to $feature. Join more circles and attend events!';
    }
    
    switch (feature) {
      case 'create_circles':
        return 'You need a trust score of 40+ to create circles.';
      case 'create_events':
        return 'You need a trust score of 50+ to create events.';
      case 'premium':
        return 'Verify your phone number to access premium features.';
      case 'host_large_events':
        return 'Verify your ID and reach trust score 70+ to host large events.';
      default:
        return 'You need higher verification to access this feature.';
    }
  }
}
