import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CreatePostCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CreatePostCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'What\'s on your mind?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.photo_library_outlined, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
