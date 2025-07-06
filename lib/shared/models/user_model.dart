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
        isActive = true;

  // Create from Firebase document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      points: data['points'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      achievements: List<String>.from(data['achievements'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
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
  ];

  @override
  bool get stringify => true;
}
