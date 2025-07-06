import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AudioSpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final Function(double) onSpeedChanged;

  static const List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  const AudioSpeedSelector({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSpeedDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              '${currentSpeed}x',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Playback Speed',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  speedOptions.map((speed) {
                    final isSelected = speed == currentSpeed;
                    return InkWell(
                      onTap: () {
                        onSpeedChanged(speed);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              isSelected
                                  ? Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  )
                                  : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${speed}x',
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                              ),
                            ),
                            Text(
                              _getSpeedDescription(speed),
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
    );
  }

  String _getSpeedDescription(double speed) {
    switch (speed) {
      case 0.5:
        return 'Very Slow';
      case 0.75:
        return 'Slow';
      case 1.0:
        return 'Normal';
      case 1.25:
        return 'Fast';
      case 1.5:
        return 'Faster';
      case 2.0:
        return 'Very Fast';
      default:
        return 'Custom';
    }
  }
}
