import 'package:flutter/material.dart';

class JournalingPage extends StatefulWidget {
  const JournalingPage({super.key});

  @override
  State<JournalingPage> createState() => _JournalingPageState();
}

class _JournalingPageState extends State<JournalingPage> {
  // step 1: buat variabel untuk menyimpan state dari data user
  int _selectedDay = 7;
  int _selectedMonth = 2;
  final List<String> _feelings = [
    'Anxiety',
    'Bipolar',
    'Depression',
    'Normal',
    'Personality disorder',
    'Stress',
    'Suicidal',
  ];
  final Set<String> _selectedFeelings = {};

  // step 2: Generate calendar data dynamically based on the current date.
  List<Map<String, dynamic>> _generateWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final daysOfWeek = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return {
        'dayName': daysOfWeek[index],
        'dayNumber': date.day,
      };
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Row(
          children: [
            Text(
              'Hai, Ica!',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(width: 8),
            Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: DropdownButton<String>(
              value: 'Jan 2025',
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
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
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {},
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildDateSelector(),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bagaimana mood kamu hari ini?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text('😡', style: TextStyle(fontSize: 32)),
                        Text('😴', style: TextStyle(fontSize: 32)),
                        Text('😐', style: TextStyle(fontSize: 32)),
                        Text('😊', style: TextStyle(fontSize: 32)),
                        Text('😍', style: TextStyle(fontSize: 32)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Apa yang kamu rasakan?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _feelings.map((feeling) {
                            final selected = _selectedFeelings.contains(
                              feeling,
                            );
                            return ChoiceChip(
                              label: Text(feeling),
                              selected: selected,
                              onSelected: (bool selectedNow) {
                                setState(() {
                                  if (selectedNow) {
                                    _selectedFeelings.add(feeling);
                                  } else {
                                    _selectedFeelings.remove(feeling);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ceritakan harimu!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'ceritakan hari kamu!',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F1F1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // handle kirim
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Kirim'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method buat build widget-widget lainnya.
  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          _dayCalender.entries.map((entry) {
            final dayName = entry.key;
            final dayNumber = int.parse(entry.value);
            final isSelected = dayNumber == _selectedDay;
            String emoji = '';
            switch (dayName) {
              case 'MIN':
                emoji = '😞';
                break;
              case 'SEN':
                emoji = '😊';
                break;
              case 'SEL':
                emoji = '😠';
                break;
            }
            return GestureDetector(
              onTap: () => setState(() => _selectedDay = dayNumber),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? const Color(0xFF0D47A1) : Colors.white,
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child:
                          emoji.isNotEmpty
                              ? Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              )
                              : Text(
                                dayNumber.toString(),
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
