import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/ai_consultation_fab.dart';
import '../widgets/hero_stats_card.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../mood/bloc/mood_bloc.dart';
import '../../../mood/bloc/mood_event.dart';
import '../../../mood/bloc/mood_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  UserModel? currentUser;
  List<MoodModel> todayMoods = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load today's moods and refresh user data
    _loadTodaysMoods();
    _refreshUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadTodaysMoods() {
    context.read<MoodBloc>().add(const MoodTodayRequested());
  }

  void _refreshUserData() {
    context.read<AuthBloc>().add(const AuthRefreshUserRequested());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app resumes
      _loadTodaysMoods();
      _refreshUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<MoodBloc>().add(const MoodTodayRequested());
            context.read<AuthBloc>().add(const AuthRefreshUserRequested());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Hero Stats Card
                _buildHeroStats(),
                const SizedBox(height: 24),

                // Feature Cards Grid
                _buildFeatureGrid(),
                const SizedBox(height: 24),

                // Quick Mood Tracking Card
                _buildQuickMoodCard(),
                const SizedBox(height: 24),

                // Wellness Tip
                _buildWellnessTip(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentRoute: '/home'),
      floatingActionButton: const AiConsultationFab(),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          currentUser = state.user;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              currentUser?.name ?? 'Welcome',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickMoodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your mood and earn points!',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Navigate to mood input page
              context.push('/mood-input');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Track Mood')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatureButton(
              title: 'Audio Therapy',
              icon: Icons.headphones,
              color: AppColors.secondary,
              onTap: () => context.push('/audio-therapy'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureButton(
              title: 'Journal',
              icon: Icons.book,
              color: AppColors.moodVeryHappy,
              onTap: () => context.push('/journal'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeatureButton(
              title: 'Games',
              icon: Icons.games,
              color: AppColors.moodNeutral,
              onTap: () => context.push('/games'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'Wellness Tip of the Day',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Take a 5-minute break every hour to practice deep breathing. This can help reduce stress and improve focus throughout your day.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStats() {
    return BlocBuilder<MoodBloc, MoodState>(
      builder: (context, moodState) {
        // Calculate real stats from mood data
        double averageMoodScore = 0.0;
        int totalEntries = 0;
        int currentStreak = 0;

        if (moodState is MoodTodayLoaded) {
          final moods = moodState.todayMoods;
          totalEntries = moods.length;

          if (moods.isNotEmpty) {
            // Use mood type mapping (1-5) instead of intensity
            final totalMoodScore = moods.fold(
              0.0,
              (sum, mood) => sum + _getMoodScore(mood.moodType),
            );
            averageMoodScore = totalMoodScore / moods.length;

            // Simple streak calculation (consecutive days with mood entries)
            currentStreak = _calculateStreak(moods);
          }
        }

        return HeroStatsCard(
          averageMoodScore: averageMoodScore,
          currentStreak: currentStreak,
          totalPoints: currentUser?.points ?? 0,
          totalEntries: totalEntries,
        );
      },
    );
  }

  // Helper method to convert mood type to score (1-5)
  double _getMoodScore(String moodType) {
    switch (moodType) {
      case 'very_sad':
        return 1.0;
      case 'sad':
        return 2.0;
      case 'neutral':
        return 3.0;
      case 'happy':
        return 4.0;
      case 'very_happy':
        return 5.0;
      default:
        return 3.0; // Default to neutral
    }
  }

  int _calculateStreak(List<MoodModel> moods) {
    if (moods.isEmpty) return 0;

    // Simple implementation - return 1 if there's a mood today, 0 otherwise
    final today = DateTime.now();
    final hasToday = moods.any((mood) {
      final moodDate = mood.createdAt;
      return moodDate.year == today.year &&
          moodDate.month == today.month &&
          moodDate.day == today.day;
    });

    return hasToday ? 1 : 0;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  String _getMoodImage(String moodType) {
    final moodIndex = AppConstants.moodTypes.indexOf(moodType);
    if (moodIndex != -1 && moodIndex < AppConstants.moodImages.length) {
      return AppConstants.moodImages[moodIndex];
    }
    return 'assets/images/Mood2.png'; // Default image
  }
}
