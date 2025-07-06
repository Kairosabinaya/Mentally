import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/ai_consultation_fab.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  void initState() {
    super.initState();
    context.read<JournalBloc>().add(const JournalEntriesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journal', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to mood input page
              context.go('/mood-input');
            },
          ),
        ],
      ),
      body: BlocBuilder<JournalBloc, JournalState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.error ?? 'An error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<JournalBloc>().add(
                        const JournalEntriesRequested(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.isLoaded) {
            if (state.entries.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No journal entries yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start writing your thoughts and feelings',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<JournalBloc>().add(
                  const JournalEntriesRequested(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Date Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title.isNotEmpty
                                      ? entry.title
                                      : 'Untitled',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  entry.formattedDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Content Preview - Better formatting for mood data
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show note if available
                              if (entry.reflections.containsKey('note') &&
                                  entry.reflections['note'] != null &&
                                  entry.reflections['note']
                                      .toString()
                                      .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    entry.reflections['note'].toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              // Show activities if available
                              if (entry.reflections.containsKey('activities') &&
                                  entry.reflections['activities'] is List &&
                                  (entry.reflections['activities'] as List)
                                      .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children:
                                        (entry.reflections['activities']
                                                as List)
                                            .take(3) // Show max 3 activities
                                            .map(
                                              (activity) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  activity.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),

                              // Show triggers if available
                              if (entry.reflections.containsKey('triggers') &&
                                  entry.reflections['triggers'] is List &&
                                  (entry.reflections['triggers'] as List)
                                      .isNotEmpty)
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children:
                                      (entry.reflections['triggers'] as List)
                                          .take(3) // Show max 3 triggers
                                          .map(
                                            (trigger) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                trigger.toString(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Bottom Row - Just show time
                          Row(
                            children: [
                              const Spacer(),

                              // Show time only
                              Text(
                                '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentRoute: '/journal'),
      floatingActionButton: const AiConsultationFab(),
    );
  }

  // Helper methods for mood display
  String _getMoodDisplayName(String moodType) {
    switch (moodType) {
      case 'very_happy':
        return 'Great';
      case 'happy':
        return 'Good';
      case 'neutral':
        return 'Okay';
      case 'sad':
        return 'Low';
      case 'very_sad':
        return 'Poor';
      default:
        return moodType
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) =>
                  word.isEmpty
                      ? word
                      : word[0].toUpperCase() + word.substring(1),
            )
            .join(' ');
    }
  }

  String _getMoodEmoji(String moodType) {
    switch (moodType) {
      case 'very_happy':
        return '😄';
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😔';
      case 'very_sad':
        return '😢';
      default:
        return '😐';
    }
  }

  Color _getMoodColor(String moodType) {
    switch (moodType) {
      case 'very_happy':
        return const Color(0xFF4CAF50); // Green
      case 'happy':
        return const Color(0xFF8BC34A); // Light Green
      case 'neutral':
        return const Color(0xFFFF9800); // Orange
      case 'sad':
        return const Color(0xFFFF5722); // Deep Orange
      case 'very_sad':
        return const Color(0xFFF44336); // Red
      default:
        return AppColors.textSecondary;
    }
  }
}
