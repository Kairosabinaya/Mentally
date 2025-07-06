import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CommunityFilterBar extends StatelessWidget {
  final String? currentFilter;
  final String? currentMoodFilter;
  final Function(String?, String?) onFilterChanged;

  const CommunityFilterBar({
    super.key,
    this.currentFilter,
    this.currentMoodFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All filter
          _buildFilterChip(
            context,
            'All',
            isSelected: currentFilter == null && currentMoodFilter == null,
            onTap: () => onFilterChanged(null, null),
          ),

          const SizedBox(width: 8),

          // Mood filters
          ...AppConstants.moodTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final mood = entry.value;
            final moodImage = AppConstants.moodImages[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                context,
                mood,
                isSelected: currentMoodFilter == mood,
                onTap:
                    () => onFilterChanged(
                      null,
                      currentMoodFilter == mood ? null : mood,
                    ),
                imagePath: moodImage,
              ),
            );
          }),

          const SizedBox(width: 8),

          // Popular tags
          ..._getPopularTags().map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                context,
                '#$tag',
                isSelected: currentFilter == tag,
                onTap:
                    () => onFilterChanged(
                      currentFilter == tag ? null : tag,
                      null,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
    String? imagePath,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null) ...[
              ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.mood, size: 16);
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getPopularTags() {
    return [
      'mentalhealth',
      'support',
      'wellness',
      'selfcare',
      'motivation',
      'anxiety',
      'depression',
      'mindfulness',
    ];
  }
}
