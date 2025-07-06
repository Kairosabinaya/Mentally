import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityPostModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final List<String> imageUrls;
  final String? moodType;
  final String? emoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  final bool isAnonymous;
  final bool isActive;
  final int pointsEarned;
  final Map<String, dynamic> metadata;

  const CommunityPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.imageUrls,
    this.moodType,
    this.emoji,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isAnonymous,
    required this.isActive,
    required this.pointsEarned,
    required this.metadata,
  });

  // Empty constructor for initial state
  CommunityPostModel.empty()
      : id = '',
        userId = '',
        userName = '',
        userPhotoUrl = null,
        content = '',
        imageUrls = const [],
        moodType = null,
        emoji = null,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now(),
        tags = const [],
        likes = 0,
        comments = 0,
        shares = 0,
        isAnonymous = false,
        isActive = true,
        pointsEarned = 0,
        metadata = const {};

  // Create from Firebase document
  factory CommunityPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      moodType: data['moodType'],
      emoji: data['emoji'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      shares: data['shares'] ?? 0,
      isAnonymous: data['isAnonymous'] ?? false,
      isActive: data['isActive'] ?? true,
      pointsEarned: data['pointsEarned'] ?? 0,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'imageUrls': imageUrls,
      'moodType': moodType,
      'emoji': emoji,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isAnonymous': isAnonymous,
      'isActive': isActive,
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      moodType: json['moodType'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? false,
      isActive: json['isActive'] ?? true,
      pointsEarned: json['pointsEarned'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'imageUrls': imageUrls,
      'moodType': moodType,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isAnonymous': isAnonymous,
      'isActive': isActive,
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }

  // Copy with method for immutability
  CommunityPostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? content,
    List<String>? imageUrls,
    String? moodType,
    String? emoji,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? likes,
    int? comments,
    int? shares,
    bool? isAnonymous,
    bool? isActive,
    int? pointsEarned,
    Map<String, dynamic>? metadata,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      moodType: moodType ?? this.moodType,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isActive: isActive ?? this.isActive,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper method to get time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userPhotoUrl,
        content,
        imageUrls,
        moodType,
        emoji,
        createdAt,
        updatedAt,
        tags,
        likes,
        comments,
        shares,
        isAnonymous,
        isActive,
        pointsEarned,
        metadata,
      ];

  @override
  bool get stringify => true;
} 