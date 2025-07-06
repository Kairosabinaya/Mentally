import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TrendingTags extends StatelessWidget {
  final List<String> tags;
  final Function(String) onTagTap;

  const TrendingTags({super.key, required this.tags, required this.onTagTap});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Tags',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _buildTagChip(context, tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return GestureDetector(
      onTap: () => onTagTap(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              '#$tag',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
