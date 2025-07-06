import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class MoodSelector extends StatefulWidget {
  final String? selectedMood;
  final int? selectedIntensity;
  final Function(String moodType, String emoji) onMoodSelected;

  const MoodSelector({
    super.key,
    this.selectedMood,
    this.selectedIntensity,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with TickerProviderStateMixin {
  String? _selectedMood;
  int _selectedIntensity = 5;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.selectedMood;
    _selectedIntensity = widget.selectedIntensity ?? 5;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectMood(String moodType, String emoji) {
    setState(() {
      _selectedMood = moodType;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onMoodSelected(moodType, emoji);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),

        // Mood Emojis
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(AppConstants.moodTypes.length, (index) {
              final moodType = AppConstants.moodTypes[index];
              final emoji = AppConstants.moodEmojis[index];
              final moodImage = AppConstants.moodImages[index];
              final isSelected = _selectedMood == moodType;

              return GestureDetector(
                onTap: () => _selectMood(moodType, emoji),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 1.0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.getMoodColor(
                                  moodType,
                                ).withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.getMoodColor(moodType),
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              moodImage,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 30),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
