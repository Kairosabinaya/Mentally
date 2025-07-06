import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HeroStatsCard extends StatelessWidget {
  final double averageMoodScore;
  final int currentStreak;
  final int totalPoints;
  final int totalEntries;

  const HeroStatsCard({
    super.key,
    this.averageMoodScore = 0.0,
    this.currentStreak = 0,
    this.totalPoints = 0,
    this.totalEntries = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Remove statistics navigation - stats are now only shown on home
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Main Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildMainStat(
                    'Mood Score',
                    averageMoodScore.toStringAsFixed(1),
                    '/5.0',
                    Icons.mood,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMainStat(
                    'Streak',
                    currentStreak.toString(),
                    ' days',
                    Icons.local_fire_department,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Points and Entries - Full Width Horizontal Layout
            Row(
              children: [
                Expanded(
                  child: _buildWideQuickStat('Points', totalPoints.toString()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWideQuickStat(
                    'Entries',
                    totalEntries.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStat(
    String title,
    String value,
    String suffix,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              suffix,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideQuickStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
