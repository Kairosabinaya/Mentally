import 'package:flutter/material.dart';
import 'audio_therapy_page.dart';
import 'ai_consultation_page.dart';
import 'games_page.dart';
import 'journaling.dart';

class _CalendarModal extends StatefulWidget {
  const _CalendarModal();

  @override
  State<_CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<_CalendarModal> {
  int _selectedView = 0; // 0 = Month, 1 = Year
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _textGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: _primaryPurple),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildViewToggle('Month', 0),
                    const SizedBox(width: 8),
                    _buildViewToggle('Year', 1),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: _primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Calendar content
          Expanded(
            child: _selectedView == 0 ? _buildMonthView() : _buildYearView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(String text, int index) {
    final isSelected = _selectedView == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : _textGray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? _surfaceWhite : _textGray,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Calendar grid would go here
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: _textGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Calendar View', style: TextStyle(color: _textGray)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearView() {
    return const Center(
      child: Text('Year View', style: TextStyle(color: _textGray)),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Enhanced color palette for mental health app
  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _lightBackground = Color(0xFFFAFBFF);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _lightGray = Color(0xFFE2E8F0);
  static const Color _softPink = Color(0xFFFDF2F8);
  static const Color _softBlue = Color(0xFFEFF6FF);
  static const Color _softGreen = Color(0xFFF0FDF4);
  static const Color _accentOrange = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
      ),
      body: const _HomeBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: _primaryPurple.withOpacity(0.1),
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: _textGray),
              selectedIcon: Icon(Icons.home_rounded, color: _primaryPurple),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, color: _textGray),
              selectedIcon: Icon(Icons.people_rounded, color: _primaryPurple),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: _textGray),
              selectedIcon: Icon(Icons.person_rounded, color: _primaryPurple),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  // Color constants
  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _softPink = Color(0xFFFDF2F8);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _softPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('👋', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hello, Ica!',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'How are you feeling today?',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: _textGray, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _WeeklyMoodTracker(),
            const SizedBox(height: 20),
            const _ProgressIndicator(),
            const SizedBox(height: 20),
            const _QuickAccessButtons(),
            const SizedBox(height: 20),
            const _RecentActivitiesSection(),
            const SizedBox(height: 20),
            const _MoodStatisticsSection(),
            const SizedBox(height: 20),
            const _RecommendationsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WeeklyMoodTracker extends StatefulWidget {
  const _WeeklyMoodTracker();

  @override
  State<_WeeklyMoodTracker> createState() => _WeeklyMoodTrackerState();
}

class _WeeklyMoodTrackerState extends State<_WeeklyMoodTracker> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentWeek = 1;

  static const List<String> _weekDays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  // Different weeks data
  static const List<List<String>> _weekDayNumbers = [
    ['29', '30', '31', '1', '2', '3', '4'], // Previous week
    ['5', '6', '7', '8', '9', '10', '11'], // Current week
    ['12', '13', '14', '15', '16', '17', '18'], // Next week
  ];

  static const List<List<String>> _weekMoodEmojis = [
    ['😊', '🥰', '😔', '😌', '🤗', '😴', '😊'], // Previous week
    ['🥰', '😊', '😤', '', '', '', ''], // Current week
    ['', '', '', '', '', '', ''], // Next week
  ];

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _softPink = Color(0xFFFDF2F8);
  static const Color _softBlue = Color(0xFFEFF6FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'January 2025',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _textGray,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: _primaryPurple,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Week days labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                return SizedBox(
                  width: 40,
                  child: Text(
                    _weekDays[index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _textGray,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            // Week days with dates - Flo style
            SizedBox(
              height: 52,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentWeek = index;
                  });
                },
                itemCount: 3,
                itemBuilder: (context, weekIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (dayIndex) {
                      final bool isToday =
                          weekIndex == 1 && dayIndex == 4; // Friday is today
                      final bool hasMood =
                          _weekMoodEmojis[weekIndex][dayIndex].isNotEmpty;
                      final String dayNumber =
                          _weekDayNumbers[weekIndex][dayIndex];

                      return GestureDetector(
                        onTap: () {
                          // Handle day selection
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isToday
                                    ? _primaryPurple
                                    : hasMood
                                    ? _softPink
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                            border:
                                hasMood && !isToday
                                    ? Border.all(
                                      color: _primaryPurple.withOpacity(0.3),
                                      width: 1,
                                    )
                                    : null,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  dayNumber,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isToday ? _surfaceWhite : _textDark,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (hasMood && !isToday)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _surfaceWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _weekMoodEmojis[weekIndex][dayIndex],
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator();

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _softGreen = Color(0xFFF0FDF4);
  static const Color _accentGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 20,
                        color: _accentGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Progress Points',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: _primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
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
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: _accentGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ 100 Points',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+12 today',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: _textGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.72,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_accentGreen, _accentGreen.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButtons extends StatelessWidget {
  const _QuickAccessButtons();

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _softPink = Color(0xFFFDF2F8);
  static const Color _softBlue = Color(0xFFEFF6FF);
  static const Color _softGreen = Color(0xFFF0FDF4);
  static const Color _softYellow = Color(0xFFFEFCE8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAccessButton(
                  context,
                  Icons.sports_esports_rounded,
                  'Games',
                  _softPink,
                  _primaryPurple,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GamesPage(),
                      ),
                    );
                  },
                ),
                _buildQuickAccessButton(
                  context,
                  Icons.headphones_rounded,
                  'Audio\nTherapy',
                  _softBlue,
                  _primaryBlue,
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
                  Icons.menu_book_rounded,
                  'Journal',
                  _softYellow,
                  const Color(0xFFF59E0B),
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const JournalingPage(),
                      ),
                    );
                  },
                ),
                _buildQuickAccessButton(
                  context,
                  Icons.psychology_rounded,
                  'AI Chat',
                  _softGreen,
                  const Color(0xFF10B981),
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
    Color backgroundColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _textDark,
                height: 1.2,
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

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _softBlue = Color(0xFFEFF6FF);
  static const Color _softPink = Color(0xFFFDF2F8);

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
                  color: _textDark,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: _primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          icon: Icons.self_improvement_rounded,
          title: 'Evening Meditation',
          subtitle: 'Deep Breathing Session',
          time: '16:30',
          duration: '15 min',
          backgroundColor: _softBlue,
          iconColor: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          icon: Icons.video_call_rounded,
          title: 'AI Consultation',
          subtitle: 'Mental Health Check-in',
          time: '14:15',
          duration: '20 min',
          backgroundColor: _softPink,
          iconColor: _primaryPurple,
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
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _textGray),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    duration,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodStatisticsSection extends StatelessWidget {
  const _MoodStatisticsSection();

  // Last 7 days
  static final List<String> _dates = _getLast7Days();
  static const List<String> _emojis = ['🥰', '😊', '😐', '😔', '😠'];

  // Single mood line data for 7 days
  static const List<double> _moodData = [0.7, 0.4, 0.6, 0.8, 0.3, 0.9, 0.6];

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);

  static List<String> _getLast7Days() {
    final now = DateTime.now();
    final List<String> days = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      days.add('${date.day}');
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mood Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: _primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Line chart container with emoji Y-axis
            Container(
              height: 160,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _textGray.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  // Y-axis with emojis
                  SizedBox(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          _emojis.map((emoji) {
                            return Text(
                              emoji,
                              style: const TextStyle(fontSize: 16),
                            );
                          }).toList(),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Chart area
                  Expanded(
                    child: SizedBox(
                      height: double.infinity,
                      child: CustomPaint(
                        painter: _MoodLinePainter(),
                        child: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // X-axis labels (7 days)
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 16, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    _dates.map((date) {
                      return Text(
                        date,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _textGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodLinePainter extends CustomPainter {
  // Single mood line data for 7 days
  static const List<double> _moodData = [0.7, 0.4, 0.6, 0.8, 0.3, 0.9, 0.6];
  static const Color _lineColor = Color(0xFF3B82F6); // Blue

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..color = _lineColor;

    final dotPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = _lineColor;

    final path = Path();
    final points = <Offset>[];

    // Calculate points for the single line
    for (int i = 0; i < _moodData.length; i++) {
      final x = (i / (_moodData.length - 1)) * size.width;
      final y = size.height - (_moodData[i] * size.height);
      points.add(Offset(x, y));
    }

    // Draw the single line
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);

      // Draw dots on data points
      for (final point in points) {
        canvas.drawCircle(point, 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _textDark = Color(0xFF1E293B);

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
              color: _textDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 240,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
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
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getRecommendationTitle(index),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getRecommendationSubtitle(index),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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

  String _getRecommendationSubtitle(int index) {
    final List<String> subtitles = [
      'Start your day peacefully',
      'Connect with nature',
      'Move mindfully',
      'End with gratitude',
    ];
    return subtitles[index % subtitles.length];
  }
}
