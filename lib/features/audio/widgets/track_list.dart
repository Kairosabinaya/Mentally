import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/audio_model.dart';

class TrackList extends StatelessWidget {
  final List<AudioTrack> tracks;
  final AudioTrack? currentTrack;
  final Function(AudioTrack, int) onTrackTap;

  const TrackList({
    super.key,
    required this.tracks,
    this.currentTrack,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const Center(
        child: Text(
          'No tracks available',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrentTrack = currentTrack?.id == track.id;

        return _TrackListItem(
          track: track,
          index: index,
          isCurrentTrack: isCurrentTrack,
          onTap: () => onTrackTap(track, index),
        );
      },
    );
  }
}

class _TrackListItem extends StatelessWidget {
  final AudioTrack track;
  final int index;
  final bool isCurrentTrack;
  final VoidCallback onTap;

  const _TrackListItem({
    required this.track,
    required this.index,
    required this.isCurrentTrack,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isCurrentTrack
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            isCurrentTrack
                ? Border.all(color: AppColors.primary.withOpacity(0.3))
                : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            // Track artwork
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image:
                      track.artworkUrl != null
                          ? (track.artworkUrl!.startsWith('http')
                              ? CachedNetworkImageProvider(track.artworkUrl!)
                              : AssetImage(track.artworkUrl!) as ImageProvider)
                          : const AssetImage('assets/images/Mood1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Play indicator overlay
            if (isCurrentTrack)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withOpacity(0.8),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),

        title: Text(
          track.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isCurrentTrack ? AppColors.primary : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              track.artist,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getCategoryIcon(track.category),
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  track.formattedDuration,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (track.rating > 0) ...[
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    track.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Track number
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isCurrentTrack
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentTrack ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // More options
            IconButton(
              onPressed: () {
                _showTrackOptions(context, track);
              },
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),

        onTap: onTap,
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

  void _showTrackOptions(BuildContext context, AudioTrack track) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Play'),
                  onTap: () {
                    Navigator.pop(context);
                    onTap();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Add to Favorites'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add to favorites logic
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('Add to Playlist'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add to playlist logic
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    // Share logic
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Track Info'),
                  onTap: () {
                    Navigator.pop(context);
                    _showTrackInfo(context, track);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showTrackInfo(BuildContext context, AudioTrack track) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(track.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Artist: ${track.artist}'),
                Text('Album: ${track.album}'),
                Text('Duration: ${track.formattedDuration}'),
                Text('Category: ${track.category.name}'),
                if (track.rating > 0)
                  Text('Rating: ${track.rating.toStringAsFixed(1)} ⭐'),
                if (track.tags.isNotEmpty)
                  Text('Tags: ${track.tags.join(', ')}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
