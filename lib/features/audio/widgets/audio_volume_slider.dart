import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../../core/theme/app_colors.dart';

class AudioVolumeSlider extends StatefulWidget {
  final double volume;
  final Function(double) onVolumeChanged;

  const AudioVolumeSlider({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  State<AudioVolumeSlider> createState() => _AudioVolumeSliderState();
}

class _AudioVolumeSliderState extends State<AudioVolumeSlider> {
  double _systemVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _getSystemVolume();
  }

  Future<void> _getSystemVolume() async {
    try {
      final volume = await VolumeController().getVolume();
      setState(() {
        _systemVolume = volume;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _setSystemVolume(double volume) async {
    try {
      VolumeController().setVolume(volume);
      setState(() {
        _systemVolume = volume;
      });
      // Also call the original callback for app volume if needed
      widget.onVolumeChanged(volume);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Volume icon
        Icon(_getVolumeIcon(), color: AppColors.textSecondary, size: 20),

        const SizedBox(width: 8),

        // Volume slider
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.textSecondary.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _systemVolume.clamp(0.0, 1.0),
              onChanged: _setSystemVolume,
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Volume percentage
        Text(
          '${(_systemVolume * 100).round()}%',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getVolumeIcon() {
    if (_systemVolume == 0) {
      return Icons.volume_off;
    } else if (_systemVolume < 0.5) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }
}
