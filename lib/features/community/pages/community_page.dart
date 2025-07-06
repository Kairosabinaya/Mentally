import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/bottom_navigation.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../widgets/post_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    context.read<CommunityBloc>().add(const LoadPosts());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !context.read<CommunityBloc>().state.hasReachedMax) {
      final state = context.read<CommunityBloc>().state;
      final lastPostId = state.posts.isNotEmpty ? state.posts.last.id : null;

      context.read<CommunityBloc>().add(LoadPosts(lastPostId: lastPostId));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onRefresh() {
    context.read<CommunityBloc>().add(const RefreshPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state.status == CommunityStatus.creating) {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          } else if (state.status == CommunityStatus.deleting) {
            // Show loading indicator for delete
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          } else if (state.status == CommunityStatus.loaded) {
            // Hide loading indicator if it was shown
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Show success message (could be for create or delete)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Action completed successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.status == CommunityStatus.error) {
            // Hide loading indicator if it was shown
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Action failed'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: _buildFeedTab(),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: '/community',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostBottomSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeedTab() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Error Banner
              if (state.hasError)
                SliverToBoxAdapter(
                  child: ErrorBanner(
                    message: state.error!,
                    onRetry: _onRefresh,
                  ),
                ),

              // Posts List
              if (state.isLoading && state.posts.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (state.posts.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < state.filteredPosts.length) {
                        final post = state.filteredPosts[index];
                        return PostCard(
                          post: post,
                          isLiked: state.isPostLiked(post.id),
                          currentUserId: FirebaseAuth.instance.currentUser?.uid,
                          onLike: (isLiked) => context
                              .read<CommunityBloc>()
                              .add(LikePost(postId: post.id, isLiked: isLiked)),
                          onDelete: () => context.read<CommunityBloc>().add(
                            DeletePost(postId: post.id),
                          ),
                        );
                      } else {
                        // Loading indicator for pagination
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                    childCount:
                        state.filteredPosts.length +
                        (state.hasReachedMax ? 0 : 1),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({String? message, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message ?? 'No posts yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreatePostBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Create First Post'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();
    bool isAnonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      Text(
                        'Create Post',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          final content = contentController.text.trim();
                          if (content.isNotEmpty) {
                            final tags = tagsController.text
                                .split(' ')
                                .where((tag) => tag.startsWith('#'))
                                .map((tag) => tag.substring(1))
                                .toList();

                            context.read<CommunityBloc>().add(
                              CreatePost(
                                content: content,
                                imageUrls: [],
                                tags: tags,
                                isAnonymous: isAnonymous,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Share'),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Create post form
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content input
                        TextField(
                          controller: contentController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: 'What\'s on your mind?',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tags input
                        TextField(
                          controller: tagsController,
                          decoration: InputDecoration(
                            hintText: 'Add tags (e.g., #mentalhealth #support)',
                            prefixIcon: const Icon(Icons.tag),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Anonymous toggle
                        Row(
                          children: [
                            Switch(
                              value: isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  isAnonymous = value;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Post anonymously',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Anonymous description
                        Text(
                          isAnonymous
                              ? 'Your post will be shown as "Anonymous"'
                              : 'Your post will be shown with your name',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
