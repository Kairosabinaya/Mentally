import 'package:equatable/equatable.dart';
import '../../../shared/models/community_post_model.dart';
import '../../../shared/models/community_comment_model.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

// Post Events
class LoadPosts extends CommunityEvent {
  final int limit;
  final String? lastPostId;
  final String? filterTag;
  final String? filterMoodType;

  const LoadPosts({
    this.limit = 10,
    this.lastPostId,
    this.filterTag,
    this.filterMoodType,
  });

  @override
  List<Object?> get props => [limit, lastPostId, filterTag, filterMoodType];
}

class RefreshPosts extends CommunityEvent {
  final String? filterTag;
  final String? filterMoodType;

  const RefreshPosts({this.filterTag, this.filterMoodType});

  @override
  List<Object?> get props => [filterTag, filterMoodType];
}

class CreatePost extends CommunityEvent {
  final String content;
  final List<String> imageUrls;
  final String? moodType;
  final String? emoji;
  final List<String> tags;
  final bool isAnonymous;

  const CreatePost({
    required this.content,
    required this.imageUrls,
    this.moodType,
    this.emoji,
    required this.tags,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [
    content,
    imageUrls,
    moodType,
    emoji,
    tags,
    isAnonymous,
  ];
}

class UpdatePost extends CommunityEvent {
  final String postId;
  final String content;
  final List<String> tags;

  const UpdatePost({
    required this.postId,
    required this.content,
    required this.tags,
  });

  @override
  List<Object?> get props => [postId, content, tags];
}

class DeletePost extends CommunityEvent {
  final String postId;

  const DeletePost({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class LikePost extends CommunityEvent {
  final String postId;
  final bool isLiked;

  const LikePost({required this.postId, required this.isLiked});

  @override
  List<Object?> get props => [postId, isLiked];
}

class SharePost extends CommunityEvent {
  final String postId;

  const SharePost({required this.postId});

  @override
  List<Object?> get props => [postId];
}

// Comment Events
class LoadComments extends CommunityEvent {
  final String postId;
  final int limit;
  final String? lastCommentId;

  const LoadComments({
    required this.postId,
    this.limit = 20,
    this.lastCommentId,
  });

  @override
  List<Object?> get props => [postId, limit, lastCommentId];
}

class CreateComment extends CommunityEvent {
  final String postId;
  final String content;
  final String? parentCommentId;
  final List<String> mentionedUsers;
  final bool isAnonymous;

  const CreateComment({
    required this.postId,
    required this.content,
    this.parentCommentId,
    required this.mentionedUsers,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [
    postId,
    content,
    parentCommentId,
    mentionedUsers,
    isAnonymous,
  ];
}

class UpdateComment extends CommunityEvent {
  final String commentId;
  final String content;

  const UpdateComment({required this.commentId, required this.content});

  @override
  List<Object?> get props => [commentId, content];
}

class DeleteComment extends CommunityEvent {
  final String commentId;
  final String postId;

  const DeleteComment({required this.commentId, required this.postId});

  @override
  List<Object?> get props => [commentId, postId];
}

class LikeComment extends CommunityEvent {
  final String commentId;
  final bool isLiked;

  const LikeComment({required this.commentId, required this.isLiked});

  @override
  List<Object?> get props => [commentId, isLiked];
}

// User Interaction Events
class FollowUser extends CommunityEvent {
  final String userId;
  final bool isFollowing;

  const FollowUser({required this.userId, required this.isFollowing});

  @override
  List<Object?> get props => [userId, isFollowing];
}

class ReportContent extends CommunityEvent {
  final String contentId;
  final String contentType; // 'post' or 'comment'
  final String reason;
  final String? description;

  const ReportContent({
    required this.contentId,
    required this.contentType,
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [contentId, contentType, reason, description];
}

class BlockUser extends CommunityEvent {
  final String userId;
  final bool isBlocked;

  const BlockUser({required this.userId, required this.isBlocked});

  @override
  List<Object?> get props => [userId, isBlocked];
}

// Search and Filter Events
class SearchPosts extends CommunityEvent {
  final String query;
  final List<String>? tags;
  final String? moodType;

  const SearchPosts({required this.query, this.tags, this.moodType});

  @override
  List<Object?> get props => [query, tags, moodType];
}

class GetTrendingTags extends CommunityEvent {
  final int limit;

  const GetTrendingTags({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class GetUserPosts extends CommunityEvent {
  final String userId;
  final int limit;
  final String? lastPostId;

  const GetUserPosts({required this.userId, this.limit = 10, this.lastPostId});

  @override
  List<Object?> get props => [userId, limit, lastPostId];
}

// Real-time Events
class SubscribeToPostUpdates extends CommunityEvent {
  final String postId;

  const SubscribeToPostUpdates({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class UnsubscribeFromPostUpdates extends CommunityEvent {
  final String postId;

  const UnsubscribeFromPostUpdates({required this.postId});

  @override
  List<Object?> get props => [postId];
}

// Reset Events
class ResetCommunityState extends CommunityEvent {
  const ResetCommunityState();
}

class ClearPostsCache extends CommunityEvent {
  const ClearPostsCache();
}
