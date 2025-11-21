import 'package:cloud_firestore/cloud_firestore.dart';

class TrustEventModel {
  final String id;
  final String userId;
  final String eventType;
  final double delta;
  final double previousScore;
  final double newScore;
  final String? details;
  final DateTime timestamp;

  TrustEventModel({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.delta,
    required this.previousScore,
    required this.newScore,
    this.details,
    required this.timestamp,
  });

  factory TrustEventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TrustEventModel(
      id: id,
      userId: data['userId'] as String,
      eventType: data['eventType'] as String,
      delta: (data['delta'] as num).toDouble(),
      previousScore: (data['previousScore'] as num).toDouble(),
      newScore: (data['newScore'] as num).toDouble(),
      details: data['details'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'eventType': eventType,
      'delta': delta,
      'previousScore': previousScore,
      'newScore': newScore,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
