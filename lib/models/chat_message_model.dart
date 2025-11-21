import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String circleId;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final DateTime expiresAt;

  ChatMessageModel({
    required this.id,
    required this.circleId,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.expiresAt,
  });

  factory ChatMessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatMessageModel(
      id: id,
      circleId: data['circleId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      message: data['message'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? 
          DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'senderId': senderId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
