import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/ai_consultation_fab.dart';
import '../widgets/mood_selector.dart';
import '../../bloc/mood_bloc.dart';
import '../../bloc/mood_event.dart';
import '../../bloc/mood_state.dart';
import '../../../../shared/models/mood_model.dart';

class MoodInputPage extends StatefulWidget {
  const MoodInputPage({super.key});

  @override
  State<MoodInputPage> createState() => _MoodInputPageState();
}

class _MoodInputPageState extends State<MoodInputPage> {
  final _noteController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedMoodType;
  String? _selectedEmoji;
  int _selectedIntensity = 5;
  List<String> _selectedTriggers = [];
  List<String> _selectedActivities = [];
  bool _isLoading = false;

  final List<String> _availableTriggers = [
    'Work stress',
    'Relationship issues',
    'Family problems',
    'Financial concerns',
    'Health issues',
    'Sleep problems',
    'Social anxiety',
    'Loneliness',
    'Academic pressure',
    'Life changes',
    'Weather',
    'Exercise',
    'Social media',
    'News/Politics',
    'Traffic',
  ];

  final List<String> _availableActivities = [
    'Working',
    'Exercising',
    'Socializing',
    'Studying',
    'Sleeping',
    'Eating',
    'Watching TV',
    'Reading',
    'Gaming',
    'Cooking',
    'Shopping',
    'Traveling',
    'Meditation',
    'Music',
    'Art/Creativity',
    'Walking',
    'Family time',
    'Cleaning',
    'Relaxing',
    'Online browsing',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMoodSelected(String moodType, String emoji) {
    setState(() {
      _selectedMoodType = moodType;
      _selectedEmoji = emoji;
      // Set intensity based on mood type (1-5 mapping)
      _selectedIntensity = _getMoodIntensity(moodType);
    });
  }

  int _getMoodIntensity(String moodType) {
    switch (moodType) {
      case 'very_sad':
        return 1;
      case 'sad':
        return 2;
      case 'neutral':
        return 3;
      case 'happy':
        return 4;
      case 'very_happy':
        return 5;
      default:
        return 3; // Default to neutral
    }
  }

  void _toggleTrigger(String trigger) {
    setState(() {
      if (_selectedTriggers.contains(trigger)) {
        _selectedTriggers.remove(trigger);
      } else {
        _selectedTriggers.add(trigger);
      }
    });
  }

  void _toggleActivity(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
    });
  }

  void _saveMood() {
    if (_selectedMoodType == null || _selectedEmoji == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your mood first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<MoodBloc>().add(
      MoodLogRequested(
        moodType: _selectedMoodType!,
        emoji: _selectedEmoji!,
        intensity: _selectedIntensity,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        triggers: _selectedTriggers,
        activities: _selectedActivities,
      ),
    );
  }

  void _showSuccessDialog(int pointsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            const Text('Mood Logged!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thank you for tracking your mood!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '+$pointsEarned points',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/journal'); // Go to journal page
            },
            child: const Text('View Journal'),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (_) => onToggle(item),
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Your Mood'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<MoodBloc, MoodState>(
        listener: (context, state) {
          if (state is MoodLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is MoodLogSuccess) {
            _showSuccessDialog(state.pointsEarned);
          } else if (state is MoodError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Selector
              MoodSelector(
                selectedMood: _selectedMoodType,
                selectedIntensity: _selectedIntensity,
                onMoodSelected: _onMoodSelected,
              ),
              const SizedBox(height: 32),

              // Note Section
              CustomTextField(
                label: 'How was your day? (Optional)',
                hint: 'Tell us more about your mood...',
                controller: _noteController,
                maxLines: 4,
                maxLength: 500,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Triggers Section
              _buildChipSection(
                title: 'What triggered this mood?',
                items: _availableTriggers,
                selectedItems: _selectedTriggers,
                onToggle: _toggleTrigger,
              ),
              const SizedBox(height: 24),

              // Activities Section
              _buildChipSection(
                title: 'What were you doing?',
                items: _availableActivities,
                selectedItems: _selectedActivities,
                onToggle: _toggleActivity,
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMoodType != null
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save),
                            const SizedBox(width: 8),
                            const Text('Save Mood Entry'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: const AiConsultationFab(),
    );
  }
}
