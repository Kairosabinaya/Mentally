import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AudioProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const AudioProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final progress =
        widget.duration.inMilliseconds > 0
            ? widget.position.inMilliseconds / widget.duration.inMilliseconds
            : 0.0;

    return Column(
      children: [
        // Progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.textSecondary.withOpacity(0.3),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: _isDragging ? _dragValue : progress.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                _isDragging = true;
                _dragValue = value;
              });
            },
            onChangeEnd: (value) {
              final newPosition = Duration(
                milliseconds: (value * widget.duration.inMilliseconds).round(),
              );
              widget.onSeek(newPosition);
              setState(() {
                _isDragging = false;
              });
            },
          ),
        ),

        const SizedBox(height: 8),

        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(
                _isDragging
                    ? Duration(
                      milliseconds:
                          (_dragValue * widget.duration.inMilliseconds).round(),
                    )
                    : widget.position,
              ),
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatDuration(widget.duration),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
