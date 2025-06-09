import 'package:flutter/material.dart';
import 'audio_therapy_page.dart';
import 'ai_consultation_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: const _HomeBody(),
      bottomNavigationBar: const _BottomNavigationWidget(),
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
            _GreetingSection(),
            SizedBox(height: 20),
            _WeeklyMoodTracker(),
            SizedBox(height: 20),
            _ProgressIndicator(),
            SizedBox(height: 20),
            _QuickAccessButtons(),
            SizedBox(height: 24),
            _RecentActivitiesSection(),
            SizedBox(height: 24),
            _MoodStatisticsSection(),
            SizedBox(height: 24),
            _RecommendationsSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Hi, Ica! 👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Jan 2025',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Color(0xFF1E3A8A),
              ),
            ],
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final bool isSelected = index == 2; // Tuesday is selected
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                Text(
                  _weekDays[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
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
                          style: const TextStyle(fontSize: 20),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _dayNumbers[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E3A8A),
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
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '72',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const Text(
              '/ 100 Points',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.72,
          backgroundColor: const Color(0xFFE2E8F0),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
          minHeight: 8,
        ),
      ],
    );
  }
}

class _QuickAccessButtons extends StatelessWidget {
  const _QuickAccessButtons();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAccessButton(context, Icons.games, 'Games', () {}),
          _buildQuickAccessButton(
            context,
            Icons.headphones,
            'Audio Therapy',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AudioTherapyPage(),
                ),
              );
            },
          ),
          _buildQuickAccessButton(context, Icons.book, 'Journal', () {}),
          _buildQuickAccessButton(
            context,
            Icons.chat_bubble_outline,
            'AI Consultation',
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
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentActivitiesSection extends StatelessWidget {
  const _RecentActivitiesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          icon: Icons.self_improvement,
          title: 'Evening Meditation',
          subtitle: 'Deep Breathing',
          time: '16:30',
          duration: '15 min',
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          icon: Icons.fitness_center,
          title: 'Mindful Exercise',
          subtitle: 'Yoga Flow Session',
          time: '14:15',
          duration: '30 min',
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mood Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_emojis[index], style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Container(
                    width: 20,
                    height: 120 * _heights[index],
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dates[index],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations for You',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(_getRecommendationImage(index)),
                    fit: BoxFit.cover,
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
}

class _BottomNavigationWidget extends StatelessWidget {
  const _BottomNavigationWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 'Home', isSelected: true),
              _buildBottomNavItem(
                Icons.people_outline,
                'Community',
                isSelected: false,
              ),
              _buildBottomNavItem(
                Icons.person_outline,
                'Profile',
                isSelected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label, {
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
