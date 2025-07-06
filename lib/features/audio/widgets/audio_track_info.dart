import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/audio_model.dart';

class AudioTrackInfo extends StatelessWidget {
  final AudioTrack? track;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const AudioTrackInfo({
    super.key,
    required this.track,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (track == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Track title
        Text(
          track!.title,
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Artist and album
        Text(
          '${track!.artist} • ${track!.album}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 16),

        // Category and favorite button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getCategoryDisplayName(track!.category),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Favorite button
            GestureDetector(
              onTap: onFavoriteToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isFavorite
                          ? AppColors.error.withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.error : AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Duration
        Text(
          track!.formattedDuration,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(AudioCategory category) {
    switch (category) {
      case AudioCategory.meditation:
        return 'Meditation';
      case AudioCategory.therapy:
        return 'Therapy';
      case AudioCategory.sleep:
        return 'Sleep';
      case AudioCategory.nature:
        return 'Nature';
      case AudioCategory.breathing:
        return 'Breathing';
      case AudioCategory.focus:
        return 'Focus';
      case AudioCategory.anxiety:
        return 'Anxiety Relief';
      case AudioCategory.depression:
        return 'Depression';
      case AudioCategory.stress:
        return 'Stress Relief';
      case AudioCategory.relaxation:
        return 'Relaxation';
    }
  }
}
