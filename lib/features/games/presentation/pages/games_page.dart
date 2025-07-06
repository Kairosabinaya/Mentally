import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/ai_consultation_fab.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  final List<Map<String, String>> games = const [
    {
      'title': 'Betwixt—The Mental Health Game',
      'description':
          'Story-based immersive game that helps manage emotions & stress through CBT, DBT, mindfulness, and journaling.',
      'url':
          'https://play.google.com/store/apps/details?hl=en_US&id=betwixt.web.app',
      'icon': '🎮',
    },
    {
      'title': 'MindDoc: Mental Health Support',
      'description':
          'Mood tracker & journal with Cognitive Behavioral Therapy-based courses for depression, anxiety, insomnia.',
      'url':
          'https://play.google.com/store/apps/details?id=de.moodpath.android',
      'icon': '📱',
    },
    {
      'title': 'Quabble: Daily Mental Health',
      'description':
          'Self-care app with mental health games, meditation, mood tracking, and support community.',
      'url':
          'https://play.google.com/store/apps/details?id=com.museLIVE.quabbleapp',
      'icon': '🎯',
    },
    {
      'title': 'BetterMe: Mental Health',
      'description':
          'All-in-one mindfulness & CBT-based routines, meditation, breathing exercises, and sleep stories.',
      'url':
          'https://play.google.com/store/apps/details?id=com.gen.bettermeditation',
      'icon': '🧘',
    },
    {
      'title': 'Headspace: Meditation & Health',
      'description':
          'Guided meditation, tools for stress, anxiety, insomnia, and therapy support & AI partner.',
      'url':
          'https://play.google.com/store/apps/details?id=com.getsomeheadspace.android',
      'icon': '🧠',
    },
    {
      'title': 'Wysa: Mental Wellbeing AI',
      'description':
          'AI chatbot offering journaling, CBT, DBT, meditation, and guided sleep—privacy protected.',
      'url': 'https://play.google.com/store/apps/details?id=bot.touchkin',
      'icon': '🤖',
    },
    {
      'title': 'What\'s Up? – Mental Health App',
      'description':
          'Free app for CBT & ACT: diary, habit tracker, catastrophe scale, and techniques to overcome negative thinking patterns.',
      'url':
          'https://play.google.com/store/apps/details?id=com.jacksontempra.apps.whatsup',
      'icon': '💭',
    },
    {
      'title': 'MyPossibleSelf: Mental Health',
      'description':
          'Supports anxiety, sleep, stress, depression—with mood tracker & wellness exercises.',
      'url':
          'https://play.google.com/store/apps/details?hl=en&id=com.mypossibleself.app',
      'icon': '🌟',
    },
    {
      'title': 'VOS: Mental Health, AI Therapy',
      'description':
          'Mood tracker, AI journal, meditation, breathing, and ChatMind—all designed as a pocket psychologist.',
      'url': 'https://play.google.com/store/apps/details?id=com.vos.app',
      'icon': '🧬',
    },
    {
      'title': 'Innerworld: Mental Health Help',
      'description':
          'Award-winning app with immersive CBT tools, journaling, group therapy, and virtual relaxation environments.',
      'url':
          'https://play.google.com/store/apps/details?id=com.VeryRealHelp.HelpClub',
      'icon': '🌍',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mental Wellness Games',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Games List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _launchUrl(game['url']!),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                game['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game['title']!,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  game['description']!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Arrow
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer Note
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tap any game to visit its Play Store page',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentRoute: '/games'),
      floatingActionButton: const AiConsultationFab(),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // For Play Store URLs, try market:// first
      if (url.contains('play.google.com/store/apps/details')) {
        String packageId = '';
        final regex = RegExp(r'id=([^&]+)');
        final match = regex.firstMatch(url);
        if (match != null) {
          packageId = match.group(1)!;
          final marketUri = Uri.parse('market://details?id=$packageId');

          try {
            await launchUrl(marketUri, mode: LaunchMode.externalApplication);
            print('Successfully launched Play Store app: $packageId');
            return;
          } catch (e) {
            print('Market launch failed, trying web: $e');
          }
        }
      }

      // Fallback to web browser
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('Successfully launched URL in browser: $url');
    } catch (e) {
      print('Failed to launch URL: $e');
      // Show user-friendly error message
      if (url.contains('play.google.com')) {
        print('Please open Google Play Store and search for the app manually');
      }
    }
  }
}
