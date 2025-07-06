import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityCommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final bool isAnonymous;
  final bool isActive;
  final String? parentCommentId; // For nested replies
  final List<String> mentionedUsers;
  final Map<String, dynamic> metadata;

  const CommunityCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.isAnonymous,
    required this.isActive,
    this.parentCommentId,
    required this.mentionedUsers,
    required this.metadata,
  });

  // Empty constructor for initial state
  CommunityCommentModel.empty()
    : id = '',
      postId = '',
      userId = '',
      userName = '',
      userPhotoUrl = null,
      content = '',
      createdAt = DateTime.now(),
      updatedAt = DateTime.now(),
      likes = 0,
      isAnonymous = false,
      isActive = true,
      parentCommentId = null,
      mentionedUsers = const [],
      metadata = const {};

  // Create from Firebase document
  factory CommunityCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityCommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      isAnonymous: data['isAnonymous'] ?? false,
      isActive: data['isActive'] ?? true,
      parentCommentId: data['parentCommentId'],
      mentionedUsers: List<String>.from(data['mentionedUsers'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  // Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'isAnonymous': isAnonymous,
      'isActive': isActive,
      'parentCommentId': parentCommentId,
      'mentionedUsers': mentionedUsers,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    return CommunityCommentModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhotoUrl: json['userPhotoUrl'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      likes: json['likes'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? false,
      isActive: json['isActive'] ?? true,
      parentCommentId: json['parentCommentId'],
      mentionedUsers: List<String>.from(json['mentionedUsers'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likes': likes,
      'isAnonymous': isAnonymous,
      'isActive': isActive,
      'parentCommentId': parentCommentId,
      'mentionedUsers': mentionedUsers,
      'metadata': metadata,
    };
  }

  // Copy with method for immutability
  CommunityCommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    bool? isAnonymous,
    bool? isActive,
    String? parentCommentId,
    List<String>? mentionedUsers,
    Map<String, dynamic>? metadata,
  }) {
    return CommunityCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isActive: isActive ?? this.isActive,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
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

  // Check if this is a reply to another comment
  bool get isReply => parentCommentId != null;

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    userName,
    userPhotoUrl,
    content,
    createdAt,
    updatedAt,
    likes,
    isAnonymous,
    isActive,
    parentCommentId,
    mentionedUsers,
    metadata,
  ];

  @override
  bool get stringify => true;
}
