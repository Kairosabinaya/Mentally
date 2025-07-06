import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ConsultationEndDialog extends StatefulWidget {
  final Function(double?, String?) onEnd;

  const ConsultationEndDialog({super.key, required this.onEnd});

  @override
  State<ConsultationEndDialog> createState() => _ConsultationEndDialogState();
}

class _ConsultationEndDialogState extends State<ConsultationEndDialog> {
  double? _moodAfter;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'End Consultation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Mood after rating
            const Text(
              'How are you feeling now?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            // Mood selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  // Mood images
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(AppConstants.moodImages.length, (
                      index,
                    ) {
                      final emoji = AppConstants.moodEmojis[index];
                      final moodImage = AppConstants.moodImages[index];
                      final moodType = AppConstants.moodTypes[index];
                      final moodValue = (index + 1).toDouble(); // 1.0 to 5.0
                      final isSelected = _moodAfter == moodValue;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _moodAfter = moodValue;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                isSelected
                                    ? Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    )
                                    : null,
                          ),
                          child: Column(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  moodImage,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 24),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getMoodLabel(moodType),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  if (_moodAfter != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Rating: ${_moodAfter!.toStringAsFixed(1)}/5.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notes section
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Any thoughts or reflections about this consultation...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderFocus),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onEnd(
                        _moodAfter,
                        _notesController.text.trim().isEmpty
                            ? null
                            : _notesController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'End Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodLabel(String moodType) {
    switch (moodType) {
      case 'very_happy':
        return 'Great';
      case 'happy':
        return 'Good';
      case 'neutral':
        return 'Okay';
      case 'sad':
        return 'Low';
      case 'very_sad':
        return 'Poor';
      default:
        return 'Unknown';
    }
  }
}
