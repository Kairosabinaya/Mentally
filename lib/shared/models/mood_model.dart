import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MoodModel extends Equatable {
  final String id;
  final String userId;
  final String moodType;
  final String emoji;
  final String? note;
  final int intensity; // 1-10 scale
  final DateTime createdAt;
  final List<String> triggers; // What caused this mood
  final List<String> activities; // What the user was doing
  final int pointsEarned;
  final Map<String, dynamic> metadata;

  const MoodModel({
    required this.id,
    required this.userId,
    required this.moodType,
    required this.emoji,
    this.note,
    required this.intensity,
    required this.createdAt,
    required this.triggers,
    required this.activities,
    required this.pointsEarned,
    required this.metadata,
  });

  // Empty constructor for initial state
  MoodModel.empty()
    : id = '',
      userId = '',
      moodType = '',
      emoji = '',
      note = null,
      intensity = 5,
      createdAt = DateTime.now(),
      triggers = const [],
      activities = const [],
      pointsEarned = 0,
      metadata = const {};

  // Create from Firebase document
  factory MoodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      moodType: data['moodType'] ?? '',
      emoji: data['emoji'] ?? '',
      note: data['note'],
      intensity: data['intensity'] ?? 5,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      triggers: List<String>.from(data['triggers'] ?? []),
      activities: List<String>.from(data['activities'] ?? []),
      pointsEarned: data['pointsEarned'] ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'moodType': moodType,
      'emoji': emoji,
      'note': note,
      'intensity': intensity,
      'createdAt': Timestamp.fromDate(createdAt),
      'triggers': triggers,
      'activities': activities,
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      moodType: json['moodType'] ?? '',
      emoji: json['emoji'] ?? '',
      note: json['note'],
      intensity: json['intensity'] ?? 5,
      createdAt: DateTime.parse(json['createdAt']),
      triggers: List<String>.from(json['triggers'] ?? []),
      activities: List<String>.from(json['activities'] ?? []),
      pointsEarned: json['pointsEarned'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moodType': moodType,
      'emoji': emoji,
      'note': note,
      'intensity': intensity,
      'createdAt': createdAt.toIso8601String(),
      'triggers': triggers,
      'activities': activities,
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }

  // Copy with method for immutability
  MoodModel copyWith({
    String? id,
    String? userId,
    String? moodType,
    String? emoji,
    String? note,
    int? intensity,
    DateTime? createdAt,
    List<String>? triggers,
    List<String>? activities,
    int? pointsEarned,
    Map<String, dynamic>? metadata,
  }) {
    return MoodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodType: moodType ?? this.moodType,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
      triggers: triggers ?? this.triggers,
      activities: activities ?? this.activities,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    moodType,
    emoji,
    note,
    intensity,
    createdAt,
    triggers,
    activities,
    pointsEarned,
    metadata,
  ];

  @override
  bool get stringify => true;
}
