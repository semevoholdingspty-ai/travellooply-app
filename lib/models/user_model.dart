import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String country;
  final List<String> languages;
  final String travelIntent;
  final List<String> preferences;
  final String socialVibe;
  final double trustScore;
  final GeoPoint location;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.country,
    required this.languages,
    required this.travelIntent,
    required this.preferences,
    required this.socialVibe,
    required this.trustScore,
    required this.location,
    required this.isOnline,
    required this.createdAt,
    this.lastSeen,
    this.isPremium = false,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      country: data['country'] as String? ?? '',
      languages: List<String>.from(data['languages'] as List? ?? []),
      travelIntent: data['travelIntent'] as String? ?? '',
      preferences: List<String>.from(data['preferences'] as List? ?? []),
      socialVibe: data['socialVibe'] as String? ?? '',
      trustScore: (data['trustScore'] as num?)?.toDouble() ?? 50.0,
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      isOnline: data['isOnline'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      isPremium: data['isPremium'] as bool? ?? false,
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'country': country,
      'languages': languages,
      'travelIntent': travelIntent,
      'preferences': preferences,
      'socialVibe': socialVibe,
      'trustScore': trustScore,
      'location': location,
      'isOnline': isOnline,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isPremium': isPremium,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? country,
    List<String>? languages,
    String? travelIntent,
    List<String>? preferences,
    String? socialVibe,
    double? trustScore,
    GeoPoint? location,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isPremium,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      languages: languages ?? this.languages,
      travelIntent: travelIntent ?? this.travelIntent,
      preferences: preferences ?? this.preferences,
      socialVibe: socialVibe ?? this.socialVibe,
      trustScore: trustScore ?? this.trustScore,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
