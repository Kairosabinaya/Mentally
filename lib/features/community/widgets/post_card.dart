import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/community_post_model.dart';

class PostCard extends StatelessWidget {
  final CommunityPostModel post;
  final bool isLiked;
  final VoidCallback? onUserTap;
  final Function(bool) onLike;
  final String? currentUserId;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    this.onUserTap,
    required this.onLike,
    this.currentUserId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          _buildPostHeader(context),

          // Post content
          if (post.content.isNotEmpty) _buildPostContent(context),

          // Post images
          if (post.imageUrls.isNotEmpty) _buildPostImages(context),

          // Post actions
          _buildPostActions(context),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final isOwnPost = currentUserId != null && currentUserId == post.userId;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User avatar
          GestureDetector(
            onTap: onUserTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              backgroundImage: post.userPhotoUrl != null
                  ? CachedNetworkImageProvider(post.userPhotoUrl!)
                  : null,
              child: post.userPhotoUrl == null
                  ? Icon(
                      post.isAnonymous ? Icons.person_outline : Icons.person,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: GestureDetector(
              onTap: onUserTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post.userName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      if (post.isAnonymous) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.visibility_off,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        post.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (post.moodType != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getMoodColor(
                              post.moodType!,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (post.emoji != null) ...[
                                Text(
                                  post.emoji!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 2),
                              ],
                              Text(
                                post.moodType!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getMoodColor(post.moodType!),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete button (only for own posts)
          if (isOwnPost && onDelete != null)
            IconButton(
              onPressed: () => _showDeleteConfirmation(context),
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: post.tags
                  .map(
                    (tag) => GestureDetector(
                      onTap: () => _onTagTap(context, tag),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPostImages(BuildContext context) {
    if (post.imageUrls.length == 1) {
      return _buildSingleImage(post.imageUrls.first);
    } else if (post.imageUrls.length == 2) {
      return _buildDoubleImages();
    } else {
      return _buildMultipleImages();
    }
  }

  Widget _buildSingleImage(String imageUrl) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 400),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: AppColors.surface,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: AppColors.surface,
          child: Icon(Icons.error_outline, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDoubleImages() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: post.imageUrls[0],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: CachedNetworkImage(
              imageUrl: post.imageUrls[1],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleImages() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: post.imageUrls[0],
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: post.imageUrls[1],
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                if (post.imageUrls.length > 2)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        '+${post.imageUrls.length - 2}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: () => onLike(!isLiked),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.error : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  post.likes.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String moodType) {
    switch (moodType.toLowerCase()) {
      case 'happy':
        return AppColors.success;
      case 'sad':
        return AppColors.info;
      case 'anxious':
        return AppColors.warning;
      case 'angry':
        return AppColors.error;
      case 'calm':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _onTagTap(BuildContext context, String tag) {
    // Navigate to tag page or filter posts by tag
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtering by #$tag'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
