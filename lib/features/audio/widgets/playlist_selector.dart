import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/audio_model.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';

class PlaylistSelector extends StatelessWidget {
  const PlaylistSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (state.status == AudioStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.playlists.isEmpty) {
          return const Center(
            child: Text(
              'No playlists available',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: state.playlists.length,
            itemBuilder: (context, index) {
              final playlist = state.playlists[index];
              // Check if this playlist is currently loaded
              final isSelected =
                  state.currentPlaylist.isNotEmpty &&
                  state.getPlaylistById(playlist.id)?.tracks.isNotEmpty ==
                      true &&
                  state.currentPlaylist.first.id ==
                      state.getPlaylistById(playlist.id)?.tracks.first.id;

              return _PlaylistCard(
                playlist: playlist,
                isSelected: isSelected,
                onTap: () {
                  context.read<AudioBloc>().add(
                    AudioLoadPlaylistByIdEvent(playlist.id),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final AudioPlaylist playlist;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.playlist,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist artwork
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image:
                        playlist.artworkUrl != null
                            ? (playlist.artworkUrl!.startsWith('http')
                                ? CachedNetworkImageProvider(
                                  playlist.artworkUrl!,
                                )
                                : AssetImage(playlist.artworkUrl!)
                                    as ImageProvider)
                            : const AssetImage('assets/images/Mood1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Play button overlay
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                      // Track count
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${playlist.tracks.length} tracks',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Playlist info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(playlist.category),
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          playlist.formattedTotalDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(AudioCategory category) {
    switch (category) {
      case AudioCategory.meditation:
        return Icons.self_improvement;
      case AudioCategory.sleep:
        return Icons.bedtime;
      case AudioCategory.focus:
        return Icons.psychology;
      case AudioCategory.anxiety:
        return Icons.favorite;
      case AudioCategory.nature:
        return Icons.nature;
      case AudioCategory.breathing:
        return Icons.air;
      case AudioCategory.therapy:
        return Icons.healing;
      case AudioCategory.depression:
        return Icons.mood;
      case AudioCategory.stress:
        return Icons.spa;
      case AudioCategory.relaxation:
        return Icons.waves;
    }
  }
}
