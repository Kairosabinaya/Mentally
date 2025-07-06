import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ai_consultation_model.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AiConsultation? consultation;
  final VoidCallback? onOptionsPressed;
  final VoidCallback? onEndPressed;

  const ChatAppBar({
    super.key,
    this.consultation,
    this.onOptionsPressed,
    this.onEndPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI Consultation',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (consultation != null) ...[const SizedBox(height: 2)],
        ],
      ),
      titleSpacing: 0,
      actions: [
        // End consultation
        if (onEndPressed != null)
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: onEndPressed,
            color: AppColors.error,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  String _getCategoryDisplayName(ConsultationCategory category) {
    switch (category) {
      case ConsultationCategory.general:
        return 'General Support';
      case ConsultationCategory.anxiety:
        return 'Anxiety & Stress';
      case ConsultationCategory.depression:
        return 'Depression & Mood';
      case ConsultationCategory.stress:
        return 'Stress Management';
      case ConsultationCategory.relationships:
        return 'Relationships';
      case ConsultationCategory.sleep:
        return 'Sleep Issues';
      case ConsultationCategory.selfEsteem:
        return 'Self-Esteem';
      case ConsultationCategory.grief:
        return 'Grief & Loss';
      case ConsultationCategory.trauma:
        return 'Trauma & PTSD';
      case ConsultationCategory.addiction:
        return 'Addiction Recovery';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
