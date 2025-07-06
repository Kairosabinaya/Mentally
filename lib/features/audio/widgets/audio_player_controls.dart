import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/audio_model.dart';

class AudioPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const AudioPlayerControls({
    super.key,
    required this.isPlaying,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          _buildControlButton(
            icon: Icons.skip_previous,
            isActive: true,
            onPressed: canGoPrevious ? onPrevious : null,
            size: 32,
          ),

          // Play/Pause button (larger)
          _buildPlayPauseButton(),

          // Next button
          _buildControlButton(
            icon: Icons.skip_next,
            isActive: true,
            onPressed: canGoNext ? onNext : null,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    VoidCallback? onPressed,
    double size = 24,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: size,
          color:
              onPressed != null
                  ? (isActive
                      ? AppColors.primary
                      : AppColors.textOnPrimary.withOpacity(0.8))
                  : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: onPlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 32,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }


}
