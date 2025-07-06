import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AiConsultationFab extends StatelessWidget {
  const AiConsultationFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push('/ai-consultation'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      child: const Icon(Icons.chat),
    );
  }
}
