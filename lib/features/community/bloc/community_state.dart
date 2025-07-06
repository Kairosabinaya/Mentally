import 'package:equatable/equatable.dart';
import '../../../shared/models/community_post_model.dart';
import '../../../shared/models/community_comment_model.dart';

enum CommunityStatus {
  initial,
  loading,
  loaded,
  error,
  creating,
  updating,
  deleting,
}

class CommunityState extends Equatable {
  final CommunityStatus status;
  final List<CommunityPostModel> posts;
  final Map<String, List<CommunityCommentModel>> comments;
  final List<String> trendingTags;
  final Map<String, bool> likedPosts;
  final Map<String, bool> likedComments;
  final Map<String, bool> followedUsers;
  final Map<String, bool> blockedUsers;
  final String? error;
  final bool hasReachedMax;
  final bool isRefreshing;
  final String? currentFilter;
  final String? currentMoodFilter;
  final List<String> searchResults;
  final bool isSearching;
  final String? searchQuery;
  final Map<String, dynamic> metadata;

  const CommunityState({
    this.status = CommunityStatus.initial,
    this.posts = const [],
    this.comments = const {},
    this.trendingTags = const [],
    this.likedPosts = const {},
    this.likedComments = const {},
    this.followedUsers = const {},
    this.blockedUsers = const {},
    this.error,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.currentFilter,
    this.currentMoodFilter,
    this.searchResults = const [],
    this.isSearching = false,
    this.searchQuery,
    this.metadata = const {},
  });

  // Helper getters
  bool get isLoading => status == CommunityStatus.loading;
  bool get isLoaded => status == CommunityStatus.loaded;
  bool get hasError => status == CommunityStatus.error;
  bool get isCreating => status == CommunityStatus.creating;
  bool get isUpdating => status == CommunityStatus.updating;
  bool get isDeleting => status == CommunityStatus.deleting;

  // Get comments for a specific post
  List<CommunityCommentModel> getCommentsForPost(String postId) {
    return comments[postId] ?? [];
  }

  // Check if a post is liked by current user
  bool isPostLiked(String postId) {
    return likedPosts[postId] ?? false;
  }

  // Check if a comment is liked by current user
  bool isCommentLiked(String commentId) {
    return likedComments[commentId] ?? false;
  }

  // Check if a user is followed by current user
  bool isUserFollowed(String userId) {
    return followedUsers[userId] ?? false;
  }

  // Check if a user is blocked by current user
  bool isUserBlocked(String userId) {
    return blockedUsers[userId] ?? false;
  }

  // Get filtered posts based on current filters
  List<CommunityPostModel> get filteredPosts {
    var filtered = posts;

    // Filter by tag
    if (currentFilter != null && currentFilter!.isNotEmpty) {
      filtered =
          filtered.where((post) => post.tags.contains(currentFilter)).toList();
    }

    // Filter by mood type
    if (currentMoodFilter != null && currentMoodFilter!.isNotEmpty) {
      filtered =
          filtered.where((post) => post.moodType == currentMoodFilter).toList();
    }

    // Filter out blocked users
    filtered = filtered.where((post) => !isUserBlocked(post.userId)).toList();

    return filtered;
  }

  // Get trending posts (posts with high engagement)
  List<CommunityPostModel> get trendingPosts {
    final sorted = List<CommunityPostModel>.from(posts);
    sorted.sort((a, b) {
      final aScore = a.likes + a.comments + a.shares;
      final bScore = b.likes + b.comments + b.shares;
      return bScore.compareTo(aScore);
    });
    return sorted.take(10).toList();
  }

  // Get recent posts (sorted by creation date)
  List<CommunityPostModel> get recentPosts {
    final sorted = List<CommunityPostModel>.from(posts);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  // Copy with method for immutability
  CommunityState copyWith({
    CommunityStatus? status,
    List<CommunityPostModel>? posts,
    Map<String, List<CommunityCommentModel>>? comments,
    List<String>? trendingTags,
    Map<String, bool>? likedPosts,
    Map<String, bool>? likedComments,
    Map<String, bool>? followedUsers,
    Map<String, bool>? blockedUsers,
    String? error,
    bool? hasReachedMax,
    bool? isRefreshing,
    String? currentFilter,
    String? currentMoodFilter,
    List<String>? searchResults,
    bool? isSearching,
    String? searchQuery,
    Map<String, dynamic>? metadata,
  }) {
    return CommunityState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      trendingTags: trendingTags ?? this.trendingTags,
      likedPosts: likedPosts ?? this.likedPosts,
      likedComments: likedComments ?? this.likedComments,
      followedUsers: followedUsers ?? this.followedUsers,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentFilter: currentFilter ?? this.currentFilter,
      currentMoodFilter: currentMoodFilter ?? this.currentMoodFilter,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for updating specific collections
  CommunityState updatePost(CommunityPostModel updatedPost) {
    final updatedPosts =
        posts.map((post) {
          return post.id == updatedPost.id ? updatedPost : post;
        }).toList();

    return copyWith(posts: updatedPosts);
  }

  CommunityState removePost(String postId) {
    final updatedPosts = posts.where((post) => post.id != postId).toList();
    final updatedComments = Map<String, List<CommunityCommentModel>>.from(
      comments,
    );
    updatedComments.remove(postId);

    return copyWith(posts: updatedPosts, comments: updatedComments);
  }

  CommunityState addPost(CommunityPostModel newPost) {
    final updatedPosts = [newPost, ...posts];
    return copyWith(posts: updatedPosts);
  }

  CommunityState updateComments(
    String postId,
    List<CommunityCommentModel> postComments,
  ) {
    final updatedComments = Map<String, List<CommunityCommentModel>>.from(
      comments,
    );
    updatedComments[postId] = postComments;
    return copyWith(comments: updatedComments);
  }

  CommunityState addComment(String postId, CommunityCommentModel newComment) {
    final updatedComments = Map<String, List<CommunityCommentModel>>.from(
      comments,
    );
    final existingComments = updatedComments[postId] ?? [];
    updatedComments[postId] = [newComment, ...existingComments];

    // Update post comment count
    final updatedPosts =
        posts.map((post) {
          if (post.id == postId) {
            return post.copyWith(comments: post.comments + 1);
          }
          return post;
        }).toList();

    return copyWith(comments: updatedComments, posts: updatedPosts);
  }

  CommunityState removeComment(String postId, String commentId) {
    final updatedComments = Map<String, List<CommunityCommentModel>>.from(
      comments,
    );
    final existingComments = updatedComments[postId] ?? [];
    updatedComments[postId] =
        existingComments.where((comment) => comment.id != commentId).toList();

    // Update post comment count
    final updatedPosts =
        posts.map((post) {
          if (post.id == postId) {
            return post.copyWith(comments: post.comments - 1);
          }
          return post;
        }).toList();

    return copyWith(comments: updatedComments, posts: updatedPosts);
  }

  CommunityState togglePostLike(String postId, bool isLiked) {
    final updatedLikedPosts = Map<String, bool>.from(likedPosts);
    updatedLikedPosts[postId] = isLiked;

    // Update post like count
    final updatedPosts =
        posts.map((post) {
          if (post.id == postId) {
            final newLikeCount = isLiked ? post.likes + 1 : post.likes - 1;
            return post.copyWith(likes: newLikeCount);
          }
          return post;
        }).toList();

    return copyWith(likedPosts: updatedLikedPosts, posts: updatedPosts);
  }

  CommunityState toggleCommentLike(String commentId, bool isLiked) {
    final updatedLikedComments = Map<String, bool>.from(likedComments);
    updatedLikedComments[commentId] = isLiked;

    // Update comment like count in all posts
    final updatedComments = Map<String, List<CommunityCommentModel>>.from(
      comments,
    );
    for (final postId in updatedComments.keys) {
      final postComments = updatedComments[postId]!;
      final updatedPostComments =
          postComments.map((comment) {
            if (comment.id == commentId) {
              final newLikeCount =
                  isLiked ? comment.likes + 1 : comment.likes - 1;
              return comment.copyWith(likes: newLikeCount);
            }
            return comment;
          }).toList();
      updatedComments[postId] = updatedPostComments;
    }

    return copyWith(
      likedComments: updatedLikedComments,
      comments: updatedComments,
    );
  }

  CommunityState toggleUserFollow(String userId, bool isFollowing) {
    final updatedFollowedUsers = Map<String, bool>.from(followedUsers);
    updatedFollowedUsers[userId] = isFollowing;
    return copyWith(followedUsers: updatedFollowedUsers);
  }

  CommunityState toggleUserBlock(String userId, bool isBlocked) {
    final updatedBlockedUsers = Map<String, bool>.from(blockedUsers);
    updatedBlockedUsers[userId] = isBlocked;
    return copyWith(blockedUsers: updatedBlockedUsers);
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    comments,
    trendingTags,
    likedPosts,
    likedComments,
    followedUsers,
    blockedUsers,
    error,
    hasReachedMax,
    isRefreshing,
    currentFilter,
    currentMoodFilter,
    searchResults,
    isSearching,
    searchQuery,
    metadata,
  ];

  @override
  bool get stringify => true;
}
