import 'package:flutter/material.dart';

class JournalingPage extends StatefulWidget {
  const JournalingPage({super.key});

  @override
  State<JournalingPage> createState() => _JournalingPageState();
}

class _JournalingPageState extends State<JournalingPage> {
  // Enhanced color palette matching home page
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
  static const Color _accentGreen = Color(0xFF10B981);

  // step 1: buat variabel untuk menyimpan state dari data user
  int _selectedDay = 7;
  int _selectedMonth = 2;
  int _selectedMood = -1; // -1 means no mood selected
  final List<String> _feelings = [
    'Anxiety',
    'Depression',
    'Stress',
    'Normal',
    'Happy',
    'Excited',
    'Calm',
  ];
  final Set<String> _selectedFeelings = {};
  final TextEditingController _journalController = TextEditingController();

  // Mood emojis
  final List<String> _moodEmojis = ['😡', '😔', '😐', '😊', '😍'];
  final List<String> _moodLabels = [
    'Angry',
    'Sad',
    'Neutral',
    'Happy',
    'Excited',
  ];

  // step 2: Generate calendar data dynamically based on the current date.
  List<Map<String, dynamic>> _generateWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final daysOfWeek = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return {'dayName': daysOfWeek[index], 'dayNumber': date.day};
    });
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: _textDark),
        ),
        title: Row(
          children: [
            Text(
              'Hello, Ica! ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: 'Jan 2025',
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _primaryPurple,
                  ),
                  underline: Container(),
                  items:
                      <String>[
                        'Jan 2025',
                        'Feb 2025',
                        'Mar 2025',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {},
                ),
              ],
            ),
          ),

          // Calendar week view
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDateSelector(),
          ),

          // Journal form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How are you feeling today?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mood selector
                      _buildMoodSelector(),

                      const SizedBox(height: 32),

                      Text(
                        'What emotions are you experiencing?',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Feelings chips
                      _buildFeelingsSelector(),

                      const SizedBox(height: 32),

                      Text(
                        'Tell me about your day',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Journal text field
                      TextField(
                        controller: _journalController,
                        maxLines: 6,
                        style: TextStyle(color: _textDark),
                        decoration: InputDecoration(
                          hintText:
                              'Write about your thoughts, feelings, and experiences today...',
                          hintStyle: TextStyle(color: _textGray),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: _lightGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _primaryPurple,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryPurple, _primaryBlue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryPurple.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: Icon(
                              Icons.save_rounded,
                              color: _surfaceWhite,
                            ),
                            label: Text(
                              'Save Journal Entry',
                              style: TextStyle(
                                color: _surfaceWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final weekDays = _generateWeekDays();

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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              weekDays.map((day) {
                final isSelected = day['dayNumber'] == _selectedDay;
                final isToday = day['dayNumber'] == DateTime.now().day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day['dayNumber'];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? _primaryPurple
                              : isToday
                              ? _softPink
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day['dayName'],
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: isSelected ? _surfaceWhite : _textGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day['dayNumber']}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color:
                                isSelected
                                    ? _surfaceWhite
                                    : isToday
                                    ? _primaryPurple
                                    : _textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_moodEmojis.length, (index) {
        final isSelected = _selectedMood == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = index;
            });
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? _softPink : _lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border:
                  isSelected
                      ? Border.all(color: _primaryPurple, width: 2)
                      : null,
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: _primaryPurple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_moodEmojis[index], style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 2),
                Text(
                  _moodLabels[index],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? _primaryPurple : _textGray,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeelingsSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _feelings.map((feeling) {
            final isSelected = _selectedFeelings.contains(feeling);

            return FilterChip(
              label: Text(
                feeling,
                style: TextStyle(
                  color: isSelected ? _surfaceWhite : _textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedFeelings.add(feeling);
                  } else {
                    _selectedFeelings.remove(feeling);
                  }
                });
              },
              backgroundColor: _lightGray.withOpacity(0.3),
              selectedColor: _primaryPurple,
              checkmarkColor: _surfaceWhite,
              side: BorderSide(
                color: isSelected ? _primaryPurple : _lightGray,
                width: 1,
              ),
              elevation: isSelected ? 2 : 0,
              shadowColor: _primaryPurple.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
    );
  }

  void _handleSubmit() {
    if (_selectedMood == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your mood'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something about your day'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Here you would save the journal entry
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry saved successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Clear the form
    setState(() {
      _selectedMood = -1;
      _selectedFeelings.clear();
      _journalController.clear();
    });
  }
}
