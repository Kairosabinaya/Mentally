import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/audio_model.dart';

class MiniPlayer extends StatelessWidget {
  final AudioTrack track;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onExpand;

  const MiniPlayer({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExpand,
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Track artwork
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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

            // Track info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
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
                      track.artist,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Play/Pause button
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: onPlayPause,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
