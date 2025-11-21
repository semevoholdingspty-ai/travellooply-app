import 'package:cloud_firestore/cloud_firestore.dart';

class MicroEventModel {
  final String id;
  final String creatorId;
  final String type;
  final String description;
  final int maxParticipants;
  final List<String> participantIds;
  final DateTime startTime;
  final DateTime endTime;
  final GeoPoint location;
  final String status;
  final String? circleId;

  MicroEventModel({
    required this.id,
    required this.creatorId,
    required this.type,
    required this.description,
    required this.maxParticipants,
    required this.participantIds,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.status,
    this.circleId,
  });

  factory MicroEventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MicroEventModel(
      id: id,
      creatorId: data['creatorId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      description: data['description'] as String? ?? '',
      maxParticipants: data['maxParticipants'] as int? ?? 5,
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(minutes: 30)),
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      status: data['status'] as String? ?? 'upcoming',
      circleId: data['circleId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creatorId': creatorId,
      'type': type,
      'description': description,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'status': status,
      'circleId': circleId,
    };
  }

  bool get isFull => participantIds.length >= maxParticipants;
  bool get hasStarted => DateTime.now().isAfter(startTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);
  int get spotsLeft => maxParticipants - participantIds.length;
}
