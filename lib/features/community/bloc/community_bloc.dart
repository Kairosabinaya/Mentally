import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/community_repository.dart';
import '../../../shared/models/community_post_model.dart';
import '../../../shared/models/community_comment_model.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _repository;
  StreamSubscription? _postsSubscription;
  final Map<String, StreamSubscription> _commentSubscriptions = {};

  CommunityBloc({required CommunityRepository repository})
    : _repository = repository,
      super(const CommunityState()) {
    on<LoadPosts>(_onLoadPosts);
    on<RefreshPosts>(_onRefreshPosts);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<LikePost>(_onLikePost);
    on<SharePost>(_onSharePost);
    on<LoadComments>(_onLoadComments);
    on<CreateComment>(_onCreateComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<LikeComment>(_onLikeComment);
    on<FollowUser>(_onFollowUser);
    on<BlockUser>(_onBlockUser);
    on<ReportContent>(_onReportContent);
    on<SearchPosts>(_onSearchPosts);
    on<GetTrendingTags>(_onGetTrendingTags);
    on<GetUserPosts>(_onGetUserPosts);
    on<SubscribeToPostUpdates>(_onSubscribeToPostUpdates);
    on<UnsubscribeFromPostUpdates>(_onUnsubscribeFromPostUpdates);
    on<ResetCommunityState>(_onResetCommunityState);
    on<ClearPostsCache>(_onClearPostsCache);
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    for (final subscription in _commentSubscriptions.values) {
      subscription.cancel();
    }
    return super.close();
  }

  Future<void> _onLoadPosts(
    LoadPosts event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      if (state.posts.isEmpty) {
        emit(state.copyWith(status: CommunityStatus.loading));
      }

      final posts = await _repository.getPosts(
        limit: event.limit,
        lastPostId: event.lastPostId,
        filterTag: event.filterTag,
        filterMoodType: event.filterMoodType,
      );

      // Load user interactions for these posts
      final postIds = posts.map((p) => p.id).toList();
      final interactions = await _repository.getUserInteractions(postIds);

      List<CommunityPostModel> updatedPosts;
      if (event.lastPostId == null) {
        // First load or refresh
        updatedPosts = posts;
      } else {
        // Pagination - append to existing posts
        updatedPosts = [...state.posts, ...posts];
      }

      emit(
        state.copyWith(
          status: CommunityStatus.loaded,
          posts: updatedPosts,
          likedPosts: {...state.likedPosts, ...interactions},
          hasReachedMax: posts.length < event.limit,
          currentFilter: event.filterTag,
          currentMoodFilter: event.filterMoodType,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onRefreshPosts(
    RefreshPosts event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      emit(state.copyWith(isRefreshing: true));

      final posts = await _repository.getPosts(
        limit: 10,
        filterTag: event.filterTag,
        filterMoodType: event.filterMoodType,
      );

      // Load user interactions for these posts
      final postIds = posts.map((p) => p.id).toList();
      final interactions = await _repository.getUserInteractions(postIds);

      emit(
        state.copyWith(
          status: CommunityStatus.loaded,
          posts: posts,
          likedPosts: interactions,
          hasReachedMax: posts.length < 10,
          currentFilter: event.filterTag,
          currentMoodFilter: event.filterMoodType,
          isRefreshing: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          error: e.toString(),
          isRefreshing: false,
        ),
      );
    }
  }

  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CommunityStatus.creating));

      final newPost = await _repository.createPost(
        content: event.content,
        imageUrls: event.imageUrls,
        moodType: event.moodType,
        emoji: event.emoji,
        tags: event.tags,
        isAnonymous: event.isAnonymous,
      );

      emit(
        state
            .addPost(newPost)
            .copyWith(status: CommunityStatus.loaded, error: null),
      );
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onUpdatePost(
    UpdatePost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CommunityStatus.updating));

      await _repository.updatePost(
        postId: event.postId,
        content: event.content,
        tags: event.tags,
      );

      // Update the post in the local state
      final updatedPost = state.posts
          .firstWhere((post) => post.id == event.postId)
          .copyWith(
            content: event.content,
            tags: event.tags,
            updatedAt: DateTime.now(),
          );

      emit(
        state
            .updatePost(updatedPost)
            .copyWith(status: CommunityStatus.loaded, error: null),
      );
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CommunityStatus.deleting));

      await _repository.deletePost(event.postId);

      emit(
        state
            .removePost(event.postId)
            .copyWith(status: CommunityStatus.loaded, error: null),
      );
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLikePost(LikePost event, Emitter<CommunityState> emit) async {
    try {
      // Optimistic update
      emit(state.togglePostLike(event.postId, event.isLiked));

      await _repository.likePost(event.postId, event.isLiked);
    } catch (e) {
      // Revert optimistic update on error
      emit(state.togglePostLike(event.postId, !event.isLiked));
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onSharePost(
    SharePost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      await _repository.sharePost(event.postId);

      // Update share count in local state
      final updatedPost = state.posts
          .firstWhere((post) => post.id == event.postId)
          .copyWith(
            shares:
                state.posts
                    .firstWhere((post) => post.id == event.postId)
                    .shares +
                1,
          );

      emit(state.updatePost(updatedPost));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final comments = await _repository.getComments(
        postId: event.postId,
        limit: event.limit,
        lastCommentId: event.lastCommentId,
      );

      // Load user interactions for these comments
      final commentIds = comments.map((c) => c.id).toList();
      final interactions = await _repository.getCommentInteractions(
        commentIds,
        event.postId,
      );

      List<CommunityCommentModel> updatedComments;
      if (event.lastCommentId == null) {
        // First load
        updatedComments = comments;
      } else {
        // Pagination - append to existing comments
        final existingComments = state.getCommentsForPost(event.postId);
        updatedComments = [...existingComments, ...comments];
      }

      emit(
        state
            .updateComments(event.postId, updatedComments)
            .copyWith(
              likedComments: {...state.likedComments, ...interactions},
              error: null,
            ),
      );
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onCreateComment(
    CreateComment event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final newComment = await _repository.createComment(
        postId: event.postId,
        content: event.content,
        parentCommentId: event.parentCommentId,
        mentionedUsers: event.mentionedUsers,
        isAnonymous: event.isAnonymous,
      );

      emit(state.addComment(event.postId, newComment).copyWith(error: null));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      // Find the post that contains this comment
      String? postId;
      for (final entry in state.comments.entries) {
        if (entry.value.any((comment) => comment.id == event.commentId)) {
          postId = entry.key;
          break;
        }
      }

      if (postId == null) return;

      await _repository.updateComment(
        postId: postId,
        commentId: event.commentId,
        content: event.content,
      );

      // Update comment in local state
      final updatedComments =
          state.getCommentsForPost(postId).map((comment) {
            if (comment.id == event.commentId) {
              return comment.copyWith(
                content: event.content,
                updatedAt: DateTime.now(),
              );
            }
            return comment;
          }).toList();

      emit(state.updateComments(postId, updatedComments).copyWith(error: null));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      await _repository.deleteComment(
        postId: event.postId,
        commentId: event.commentId,
      );

      emit(
        state
            .removeComment(event.postId, event.commentId)
            .copyWith(error: null),
      );
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLikeComment(
    LikeComment event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      // Find the post that contains this comment
      String? postId;
      for (final entry in state.comments.entries) {
        if (entry.value.any((comment) => comment.id == event.commentId)) {
          postId = entry.key;
          break;
        }
      }

      if (postId == null) return;

      // Optimistic update
      emit(state.toggleCommentLike(event.commentId, event.isLiked));

      await _repository.likeComment(
        postId: postId,
        commentId: event.commentId,
        isLiked: event.isLiked,
      );
    } catch (e) {
      // Revert optimistic update on error
      emit(state.toggleCommentLike(event.commentId, !event.isLiked));
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      // Optimistic update
      emit(state.toggleUserFollow(event.userId, event.isFollowing));

      await _repository.followUser(event.userId, event.isFollowing);
    } catch (e) {
      // Revert optimistic update on error
      emit(state.toggleUserFollow(event.userId, !event.isFollowing));
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onBlockUser(
    BlockUser event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      await _repository.blockUser(event.userId, event.isBlocked);

      emit(state.toggleUserBlock(event.userId, event.isBlocked));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onReportContent(
    ReportContent event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      await _repository.reportContent(
        contentId: event.contentId,
        contentType: event.contentType,
        reason: event.reason,
        description: event.description,
      );

      // Content reported successfully - no state change needed
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onSearchPosts(
    SearchPosts event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      emit(state.copyWith(isSearching: true, searchQuery: event.query));

      final posts = await _repository.searchPosts(
        query: event.query,
        tags: event.tags,
        moodType: event.moodType,
      );

      final postIds = posts.map((p) => p.id).toList();

      emit(
        state.copyWith(searchResults: postIds, isSearching: false, error: null),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          error: e.toString(),
          isSearching: false,
        ),
      );
    }
  }

  Future<void> _onGetTrendingTags(
    GetTrendingTags event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final tags = await _repository.getTrendingTags(limit: event.limit);

      emit(state.copyWith(trendingTags: tags, error: null));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onGetUserPosts(
    GetUserPosts event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final posts = await _repository.getUserPosts(
        userId: event.userId,
        limit: event.limit,
        lastPostId: event.lastPostId,
      );

      // For user posts, we might want to handle them differently
      // For now, we'll just update the main posts list
      emit(
        state.copyWith(
          posts: posts,
          status: CommunityStatus.loaded,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onSubscribeToPostUpdates(
    SubscribeToPostUpdates event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      // Cancel existing subscription if any
      _commentSubscriptions[event.postId]?.cancel();

      // Subscribe to comments stream
      _commentSubscriptions[event.postId] = _repository
          .getCommentsStream(event.postId)
          .listen((comments) {
            add(LoadComments(postId: event.postId));
          });
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, error: e.toString()));
    }
  }

  Future<void> _onUnsubscribeFromPostUpdates(
    UnsubscribeFromPostUpdates event,
    Emitter<CommunityState> emit,
  ) async {
    _commentSubscriptions[event.postId]?.cancel();
    _commentSubscriptions.remove(event.postId);
  }

  Future<void> _onResetCommunityState(
    ResetCommunityState event,
    Emitter<CommunityState> emit,
  ) async {
    _postsSubscription?.cancel();
    for (final subscription in _commentSubscriptions.values) {
      subscription.cancel();
    }
    _commentSubscriptions.clear();

    emit(const CommunityState());
  }

  Future<void> _onClearPostsCache(
    ClearPostsCache event,
    Emitter<CommunityState> emit,
  ) async {
    emit(
      state.copyWith(
        posts: [],
        comments: {},
        hasReachedMax: false,
        currentFilter: null,
        currentMoodFilter: null,
      ),
    );
  }
}
