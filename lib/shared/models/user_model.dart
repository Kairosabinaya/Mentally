import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> achievements;
  final Map<String, dynamic> preferences;
  final bool isActive;

  // Additional fields from database
  final String? gender;
  final DateTime? dateOfBirth;
  final String? phone;
  final int? age;
  final int? totalPointsEarned;
  final List<String>? favoriteTrackIds;
  final bool? emailVerified;
  final String? uid;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
    required this.achievements,
    required this.preferences,
    required this.isActive,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.age,
    this.totalPointsEarned,
    this.favoriteTrackIds,
    this.emailVerified,
    this.uid,
  });

  // Empty constructor for initial state
  UserModel.empty()
    : id = '',
      email = '',
      name = '',
      photoUrl = null,
      points = 0,
      createdAt = DateTime(2024, 1, 1),
      updatedAt = DateTime(2024, 1, 1),
      achievements = const [],
      preferences = const {},
      isActive = true,
      gender = null,
      dateOfBirth = null,
      phone = null,
      age = null,
      totalPointsEarned = null,
      favoriteTrackIds = null,
      emailVerified = null,
      uid = null;

  // Create from Firebase document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('User document data is null');
    }

    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      points: (data['points'] as num?)?.toInt() ?? 0,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      achievements: _parseStringList(data['achievements']),
      preferences: data['preferences'] is Map
          ? Map<String, dynamic>.from(data['preferences'])
          : <String, dynamic>{},
      isActive: data['isActive'] as bool? ?? true,
      gender: data['gender'] as String?,
      dateOfBirth: _parseTimestamp(data['dateOfBirth']),
      phone: data['phone'] as String?,
      age: (data['age'] as num?)?.toInt(),
      totalPointsEarned: (data['totalPointsEarned'] as num?)?.toInt(),
      favoriteTrackIds: _parseStringList(data['favoriteTrackIds']),
      emailVerified: data['emailVerified'] as bool?,
      uid: data['uid'] as String?,
    );
  }

  // Helper method to safely parse Timestamp
  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  // Helper method to safely parse List<String>
  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'achievements': achievements,
      'preferences': preferences,
      'isActive': isActive,
      'gender': gender,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'phone': phone,
      'age': age,
      'totalPointsEarned': totalPointsEarned,
      'favoriteTrackIds': favoriteTrackIds,
      'emailVerified': emailVerified,
      'uid': uid,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
      points: json['points'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      achievements: List<String>.from(json['achievements'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      isActive: json['isActive'] ?? true,
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      phone: json['phone'],
      age: json['age'],
      totalPointsEarned: json['totalPointsEarned'],
      favoriteTrackIds: json['favoriteTrackIds'] != null
          ? List<String>.from(json['favoriteTrackIds'])
          : null,
      emailVerified: json['emailVerified'],
      uid: json['uid'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'achievements': achievements,
      'preferences': preferences,
      'isActive': isActive,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phone': phone,
      'age': age,
      'totalPointsEarned': totalPointsEarned,
      'favoriteTrackIds': favoriteTrackIds,
      'emailVerified': emailVerified,
      'uid': uid,
    };
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    int? points,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? achievements,
    Map<String, dynamic>? preferences,
    bool? isActive,
    String? gender,
    DateTime? dateOfBirth,
    String? phone,
    int? age,
    int? totalPointsEarned,
    List<String>? favoriteTrackIds,
    bool? emailVerified,
    String? uid,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      favoriteTrackIds: favoriteTrackIds ?? this.favoriteTrackIds,
      emailVerified: emailVerified ?? this.emailVerified,
      uid: uid ?? this.uid,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    points,
    createdAt,
    updatedAt,
    achievements,
    preferences,
    isActive,
    gender,
    dateOfBirth,
    phone,
    age,
    totalPointsEarned,
    favoriteTrackIds,
    emailVerified,
    uid,
  ];

  @override
  bool get stringify => true;
}
