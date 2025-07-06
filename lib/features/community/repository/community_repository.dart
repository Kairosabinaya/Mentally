import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/community_post_model.dart';
import '../../../shared/models/community_comment_model.dart';
import '../../../shared/models/user_model.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CommunityRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Posts Operations
  Future<List<CommunityPostModel>> getPosts({
    int limit = 10,
    String? lastPostId,
    String? filterTag,
    String? filterMoodType,
  }) async {
    try {
      // Simplified query to avoid index requirements
      Query query = _firestore
          .collection(AppConstants.communityPostsCollection)
          .orderBy('createdAt', descending: true);

      // Pagination
      if (lastPostId != null) {
        final lastDoc =
            await _firestore
                .collection(AppConstants.communityPostsCollection)
                .doc(lastPostId)
                .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      // Filter active posts in code instead of query
      final posts =
          snapshot.docs
              .map((doc) => CommunityPostModel.fromFirestore(doc))
              .where((post) => post.isActive)
              .toList();

      return posts;
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<CommunityPostModel> createPost({
    required String content,
    required List<String> imageUrls,
    String? moodType,
    String? emoji,
    required List<String> tags,
    required bool isAnonymous,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user data
      final userDoc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(currentUser!.uid)
              .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final userData = UserModel.fromFirestore(userDoc);
      final now = DateTime.now();

      final post = CommunityPostModel(
        id: '',
        userId: currentUser!.uid,
        userName: isAnonymous ? 'Anonymous' : userData.name,
        userPhotoUrl: isAnonymous ? null : userData.photoUrl,
        content: content,
        imageUrls: imageUrls,
        moodType: moodType,
        emoji: emoji,
        createdAt: now,
        updatedAt: now,
        tags: tags,
        likes: 0,
        comments: 0,
        shares: 0,
        isAnonymous: isAnonymous,
        isActive: true,
        pointsEarned: AppConstants.pointsForPost,
        metadata: {},
      );

      final docRef = await _firestore
          .collection(AppConstants.communityPostsCollection)
          .add(post.toFirestore());

      // Award points to user
      await _awardPointsToUser(currentUser!.uid, AppConstants.pointsForPost);

      return post.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  Future<void> updatePost({
    required String postId,
    required String content,
    required List<String> tags,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .update({
            'content': content,
            'tags': tags,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .update({
            'isActive': false,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  Future<void> likePost(String postId, bool isLiked) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final likeRef = _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('likes')
          .doc(currentUser!.uid);

      final postRef = _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId);

      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post not found');
        }

        final currentLikes = postDoc.data()?['likes'] ?? 0;

        if (isLiked) {
          transaction.set(likeRef, {
            'userId': currentUser!.uid,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          });
          transaction.update(postRef, {'likes': currentLikes + 1});
        } else {
          transaction.delete(likeRef);
          transaction.update(postRef, {'likes': currentLikes - 1});
        }
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  Future<void> sharePost(String postId) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .update({'shares': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Failed to share post: $e');
    }
  }

  // Comments Operations
  Future<List<CommunityCommentModel>> getComments({
    required String postId,
    int limit = 20,
    String? lastCommentId,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('comments')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (lastCommentId != null) {
        final lastDoc =
            await _firestore
                .collection(AppConstants.communityPostsCollection)
                .doc(postId)
                .collection('comments')
                .doc(lastCommentId)
                .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CommunityCommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<CommunityCommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
    required List<String> mentionedUsers,
    required bool isAnonymous,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user data
      final userDoc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(currentUser!.uid)
              .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final userData = UserModel.fromFirestore(userDoc);
      final now = DateTime.now();

      final comment = CommunityCommentModel(
        id: '',
        postId: postId,
        userId: currentUser!.uid,
        userName: isAnonymous ? 'Anonymous' : userData.name,
        userPhotoUrl: isAnonymous ? null : userData.photoUrl,
        content: content,
        createdAt: now,
        updatedAt: now,
        likes: 0,
        isAnonymous: isAnonymous,
        isActive: true,
        parentCommentId: parentCommentId,
        mentionedUsers: mentionedUsers,
        metadata: {},
      );

      final docRef = await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('comments')
          .add(comment.toFirestore());

      // Update post comment count
      await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .update({'comments': FieldValue.increment(1)});

      // Award points to user
      await _awardPointsToUser(currentUser!.uid, AppConstants.pointsForComment);

      return comment.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
            'content': content,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
            'isActive': false,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      // Update post comment count
      await _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .update({'comments': FieldValue.increment(-1)});
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> likeComment({
    required String postId,
    required String commentId,
    required bool isLiked,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final likeRef = _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(currentUser!.uid);

      final commentRef = _firestore
          .collection(AppConstants.communityPostsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);
        if (!commentDoc.exists) {
          throw Exception('Comment not found');
        }

        final currentLikes = commentDoc.data()?['likes'] ?? 0;

        if (isLiked) {
          transaction.set(likeRef, {
            'userId': currentUser!.uid,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          });
          transaction.update(commentRef, {'likes': currentLikes + 1});
        } else {
          transaction.delete(likeRef);
          transaction.update(commentRef, {'likes': currentLikes - 1});
        }
      });
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  // User Interactions
  Future<void> followUser(String userId, bool isFollowing) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final followRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser!.uid)
          .collection('following')
          .doc(userId);

      final followerRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('followers')
          .doc(currentUser!.uid);

      if (isFollowing) {
        await followRef.set({
          'userId': userId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
        await followerRef.set({
          'userId': currentUser!.uid,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        await followRef.delete();
        await followerRef.delete();
      }
    } catch (e) {
      throw Exception('Failed to follow/unfollow user: $e');
    }
  }

  Future<void> blockUser(String userId, bool isBlocked) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final blockRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser!.uid)
          .collection('blocked')
          .doc(userId);

      if (isBlocked) {
        await blockRef.set({
          'userId': userId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        await blockRef.delete();
      }
    } catch (e) {
      throw Exception('Failed to block/unblock user: $e');
    }
  }

  Future<void> reportContent({
    required String contentId,
    required String contentType,
    required String reason,
    String? description,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('reports').add({
        'contentId': contentId,
        'contentType': contentType,
        'reportedBy': currentUser!.uid,
        'reason': reason,
        'description': description,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to report content: $e');
    }
  }

  // Search and Analytics
  Future<List<CommunityPostModel>> searchPosts({
    required String query,
    List<String>? tags,
    String? moodType,
  }) async {
    try {
      // Note: This is a basic implementation. For production,
      // consider using Algolia or similar search service
      Query searchQuery = _firestore
          .collection(AppConstants.communityPostsCollection)
          .where('isActive', isEqualTo: true);

      if (tags != null && tags.isNotEmpty) {
        searchQuery = searchQuery.where('tags', arrayContainsAny: tags);
      }

      if (moodType != null && moodType.isNotEmpty) {
        searchQuery = searchQuery.where('moodType', isEqualTo: moodType);
      }

      final snapshot = await searchQuery.get();
      final posts =
          snapshot.docs
              .map((doc) => CommunityPostModel.fromFirestore(doc))
              .toList();

      // Filter by content (client-side for now)
      return posts
          .where(
            (post) => post.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  Future<List<String>> getTrendingTags({int limit = 10}) async {
    try {
      // This would typically be pre-computed in a real app
      final snapshot =
          await _firestore
              .collection(AppConstants.communityPostsCollection)
              .where('isActive', isEqualTo: true)
              .where(
                'createdAt',
                isGreaterThan: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(days: 7)),
                ),
              )
              .get();

      final tagCounts = <String, int>{};
      for (final doc in snapshot.docs) {
        final post = CommunityPostModel.fromFirestore(doc);
        for (final tag in post.tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }

      final sortedTags =
          tagCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTags.take(limit).map((e) => e.key).toList();
    } catch (e) {
      throw Exception('Failed to get trending tags: $e');
    }
  }

  Future<List<CommunityPostModel>> getUserPosts({
    required String userId,
    int limit = 10,
    String? lastPostId,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.communityPostsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (lastPostId != null) {
        final lastDoc =
            await _firestore
                .collection(AppConstants.communityPostsCollection)
                .doc(lastPostId)
                .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CommunityPostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load user posts: $e');
    }
  }

  // Real-time subscriptions
  Stream<List<CommunityPostModel>> getPostsStream({
    int limit = 10,
    String? filterTag,
    String? filterMoodType,
  }) {
    Query query = _firestore
        .collection(AppConstants.communityPostsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (filterTag != null && filterTag.isNotEmpty) {
      query = query.where('tags', arrayContains: filterTag);
    }

    if (filterMoodType != null && filterMoodType.isNotEmpty) {
      query = query.where('moodType', isEqualTo: filterMoodType);
    }

    query = query.limit(limit);

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => CommunityPostModel.fromFirestore(doc))
              .toList(),
    );
  }

  Stream<List<CommunityCommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection(AppConstants.communityPostsCollection)
        .doc(postId)
        .collection('comments')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CommunityCommentModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Helper method to award points to user
  Future<void> _awardPointsToUser(String userId, int points) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
            'points': FieldValue.increment(points),
            'totalPointsEarned': FieldValue.increment(points),
          });
    } catch (e) {
      // Log error but don't throw to avoid breaking main functionality
      print('Failed to award points: $e');
    }
  }

  // Check user interactions
  Future<Map<String, bool>> getUserInteractions(List<String> postIds) async {
    try {
      if (currentUser == null) {
        return {};
      }

      final interactions = <String, bool>{};

      for (final postId in postIds) {
        final likeDoc =
            await _firestore
                .collection(AppConstants.communityPostsCollection)
                .doc(postId)
                .collection('likes')
                .doc(currentUser!.uid)
                .get();

        interactions[postId] = likeDoc.exists;
      }

      return interactions;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, bool>> getCommentInteractions(
    List<String> commentIds,
    String postId,
  ) async {
    try {
      if (currentUser == null) {
        return {};
      }

      final interactions = <String, bool>{};

      for (final commentId in commentIds) {
        final likeDoc =
            await _firestore
                .collection(AppConstants.communityPostsCollection)
                .doc(postId)
                .collection('comments')
                .doc(commentId)
                .collection('likes')
                .doc(currentUser!.uid)
                .get();

        interactions[commentId] = likeDoc.exists;
      }

      return interactions;
    } catch (e) {
      return {};
    }
  }
}
