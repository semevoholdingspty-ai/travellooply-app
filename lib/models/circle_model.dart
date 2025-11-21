import 'package:cloud_firestore/cloud_firestore.dart';

class CircleModel {
  final String id;
  final String activityType;
  final List<String> memberIds;
  final double radius;
  final GeoPoint centerLocation;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;
  final String? creatorId;

  CircleModel({
    required this.id,
    required this.activityType,
    required this.memberIds,
    required this.radius,
    required this.centerLocation,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.creatorId,
  });

  factory CircleModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CircleModel(
      id: id,
      activityType: data['activityType'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      radius: (data['radius'] as num?)?.toDouble() ?? 800.0,
      centerLocation: data['centerLocation'] as GeoPoint? ?? const GeoPoint(0, 0),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(hours: 24)),
      status: data['status'] as String? ?? 'active',
      creatorId: data['creatorId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'activityType': activityType,
      'memberIds': memberIds,
      'radius': radius,
      'centerLocation': centerLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status,
      'creatorId': creatorId,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get memberCount => memberIds.length;
}
