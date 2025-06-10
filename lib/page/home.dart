import 'package:flutter/material.dart';
import 'audio_therapy_page.dart';
import 'ai_consultation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Custom color palette
  static const Color _primaryBlue = Color(0xFF1E3A8A);
  static const Color _lightBackground = Color(0xFFF0F4FF);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textGray = Color(0xFF64748B);
  static const Color _lightGray = Color(0xFFE2E8F0);
  static const Color _lightBlueContainer = Color(0xFFE0F2FE);
  static const Color _accentYellow = Color(0xFFFBBF24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _lightBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'Hi, Ica! 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: _surfaceWhite,
                foregroundColor: _primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jan 2025',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: _primaryBlue),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: _primaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: const _HomeBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: _surfaceWhite,
        indicatorColor: _primaryBlue.withOpacity(0.1),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: _textGray),
            selectedIcon: Icon(Icons.home, color: _primaryBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline, color: _textGray),
            selectedIcon: Icon(Icons.people, color: _primaryBlue),
            label: 'Community',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: _textGray),
            selectedIcon: Icon(Icons.person, color: _primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _WeeklyMoodTracker(),
            SizedBox(height: 24),
            _ProgressIndicator(),
            SizedBox(height: 24),
            _QuickAccessButtons(),
            SizedBox(height: 24),
            _RecentActivitiesSection(),
            SizedBox(height: 24),
            _MoodStatisticsSection(),
            SizedBox(height: 24),
            _RecommendationsSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WeeklyMoodTracker extends StatelessWidget {
  const _WeeklyMoodTracker();

  static const List<String> _weekDays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];
  static const List<String> _dayNumbers = ['5', '6', '7', '8', '9', '10', '11'];
  static const List<String> _moodEmojis = ['🙂', '😄', '😠', '', '', '', ''];

  static const Color _primaryBlue = Color(0xFF1E3A8A);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textGray = Color(0xFF64748B);
  static const Color _lightGray = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: _surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Mood Tracker',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _weekDays.length,
                itemBuilder: (context, index) {
                  final bool isSelected = index == 2; // Tuesday is selected
                  return Container(
                    width: 72,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Text(
                          _weekDays[index],
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? _primaryBlue : _textGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryBlue : _surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_moodEmojis[index].isNotEmpty)
                                Text(
                                  _moodEmojis[index],
                                  style: const TextStyle(fontSize: 18),
                                ),
                              if (_moodEmojis[index].isNotEmpty)
                                const SizedBox(height: 2),
                              Text(
                                _dayNumbers[index],
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected ? _surfaceWhite : _primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator();

  static const Color _primaryBlue = Color(0xFF1E3A8A);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textGray = Color(0xFF64748B);
  static const Color _lightGray = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: _surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress Points',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _primaryBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(color: _primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '72',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ 100 Points',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: _textGray),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.72,
              backgroundColor: _lightGray,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryBlue),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButtons extends StatelessWidget {
  const _QuickAccessButtons();

  static const Color _primaryBlue = Color(0xFF1E3A8A);
  static const Color _surfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: _surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAccessButton(
                  context,
                  Icons.games_outlined,
                  'Games',
                  () {},
                ),
                _buildQuickAccessButton(
                  context,
                  Icons.headphones_outlined,
                  'Audio\nTherapy',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AudioTherapyPage(),
                      ),
                    );
                  },
                ),
                _buildQuickAccessButton(
                  context,
                  Icons.book_outlined,
                  'Journal',
                  () {},
                ),
                _buildQuickAccessButton(
                  context,
                  Icons.chat_bubble_outline,
                  'AI\nConsultation',
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AiConsultationPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _primaryBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: _surfaceWhite, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: _primaryBlue,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitiesSection extends StatelessWidget {
  const _RecentActivitiesSection();

  static const Color _primaryBlue = Color(0xFF1E3A8A);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textGray = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('View All', style: TextStyle(color: _primaryBlue)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildActivityCard(
          context,
          icon: Icons.self_improvement_outlined,
          title: 'Evening Meditation',
          subtitle: 'Deep Breathing',
          time: '16:30',
          duration: '15 min',
        ),
        const SizedBox(height: 8),
        _buildActivityCard(
          context,
          icon: Icons.fitness_center_outlined,
          title: 'Mindful Exercise',
          subtitle: 'Yoga Flow Session',
          time: '14:15',
          duration: '30 min',
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String duration,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: _surfaceWhite,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _primaryBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _surfaceWhite, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: _primaryBlue,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: _textGray),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              duration,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: _textGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodStatisticsSection extends StatelessWidget {
  const _MoodStatisticsSection();

  static const List<String> _dates = [
    '1/1',
    '2/1',
    '3/1',
    '4/1',
    '5/1',
    '6/1',
    '7/1',
  ];
  static const List<String> _emojis = [
    '😄',
    '😔',
    '🙂',
    '😔',
    '😐',
    '😄',
    '😠',
  ];
  static const List<double> _heights = [0.8, 0.3, 0.6, 0.3, 0.4, 0.8, 0.2];

  static const Color _primaryBlue = Color(0xFF1E3A8A);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textGray = Color(0xFF64748B);
  static const Color _lightBlueContainer = Color(0xFFE0F2FE);
  static const Color _accentYellow = Color(0xFFFBBF24);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: _surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mood Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _primaryBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(color: _primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lightBlueContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _emojis[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 16,
                        height: 100 * _heights[index],
                        decoration: BoxDecoration(
                          color: _accentYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _dates[index],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  static const Color _primaryBlue = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Recommendations for You',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(right: 12),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_getRecommendationImage(index)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getRecommendationTitle(index),
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getRecommendationImage(int index) {
    final List<String> images = [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=200&fit=crop',
      'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=200&fit=crop',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=200&fit=crop',
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=200&fit=crop',
    ];
    return images[index % images.length];
  }

  String _getRecommendationTitle(int index) {
    final List<String> titles = [
      'Morning Meditation',
      'Nature Therapy',
      'Mindful Walking',
      'Evening Reflection',
    ];
    return titles[index % titles.length];
  }
}
