import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ai_consultation_model.dart';

class ConversationStarters extends StatelessWidget {
  final List<String> starters;
  final ConsultationCategory category;
  final Function(String) onStarterTap;

  const ConversationStarters({
    super.key,
    required this.starters,
    required this.category,
    required this.onStarterTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryStarters = _getCategoryStarters(category);
    final allStarters = [...starters, ...categoryStarters];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Welcome message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to AI Consultation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'I\'m here to provide mental health support and guidance. You can start by selecting one of the suggestions below or typing your own message.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),


          // Conversation starters
          if (allStarters.isNotEmpty) ...[
            Text(
              'Suggested conversation starters:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: allStarters.length,
                itemBuilder: (context, index) {
                  final starter = allStarters[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildStarterCard(starter),
                  );
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Type your message below to start the conversation',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarterCard(String starter) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: () => onStarterTap(starter),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  starter,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
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
      case ConsultationCategory.relationships:
        return 'Relationships';
      case ConsultationCategory.sleep:
        return 'Sleep Issues';
      case ConsultationCategory.selfEsteem:
        return 'Self-Esteem';
      case ConsultationCategory.stress:
        return 'Stress Management';
      case ConsultationCategory.grief:
        return 'Grief & Loss';
      case ConsultationCategory.trauma:
        return 'Trauma & PTSD';
      case ConsultationCategory.addiction:
        return 'Addiction Recovery';
    }
  }

  List<String> _getCategoryStarters(ConsultationCategory category) {
    switch (category) {
      case ConsultationCategory.general:
        return [
          "I'm feeling overwhelmed and need someone to talk to",
          "Can you help me understand my emotions better?",
          "I'm going through a difficult time and need support",
        ];

      case ConsultationCategory.anxiety:
        return [
          "I've been feeling anxious lately and don't know why",
          "Can you help me with techniques to manage anxiety?",
          "I'm having panic attacks and need coping strategies",
          "How can I deal with social anxiety?",
        ];

      case ConsultationCategory.depression:
        return [
          "I've been feeling down and unmotivated",
          "Can you help me understand depression better?",
          "I'm struggling with negative thoughts",
          "How can I improve my mood and energy levels?",
        ];

      case ConsultationCategory.relationships:
        return [
          "I'm having relationship problems and need advice",
          "How can I improve communication with my partner?",
          "I'm struggling with loneliness and isolation",
          "Can you help me build better relationships?",
        ];

      case ConsultationCategory.sleep:
        return [
          "I'm having trouble sleeping and staying asleep",
          "Can you help me with sleep hygiene tips?",
          "I have insomnia and need strategies to cope",
          "How can I improve my sleep quality?",
        ];

      case ConsultationCategory.selfEsteem:
        return [
          "I need help building my self-confidence",
          "How can I be more kind to myself?",
          "I'm struggling with self-esteem issues",
          "Can you help me develop a positive self-image?",
        ];
      
      case ConsultationCategory.stress:
        return [
          "I'm feeling overwhelmed with stress",
          "Can you help me with stress management techniques?",
          "I need better ways to cope with pressure",
          "How can I reduce stress in my daily life?",
        ];
      
      case ConsultationCategory.grief:
        return [
          "I'm dealing with loss and need support",
          "Can you help me process my grief?",
          "I'm struggling with the stages of grief",
          "How can I honor my loved one's memory?",
        ];

      case ConsultationCategory.trauma:
        return [
          "I'm dealing with traumatic experiences",
          "Can you help me process difficult memories?",
          "I'm having flashbacks and need support",
          "How can I heal from past trauma?",
        ];

      case ConsultationCategory.addiction:
        return [
          "I'm struggling with addiction and need help",
          "Can you support me in my recovery journey?",
          "I'm having cravings and need coping strategies",
          "How can I build a sober lifestyle?",
        ];
    }
  }
}
