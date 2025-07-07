import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../page/welcome.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'auth_wrapper.dart';
import '../../features/mood/presentation/pages/mood_input_page.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../page/audio_therapy_page.dart';
import '../../page/audio_player_page.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/community/pages/community_page.dart';
import '../../features/ai_chat/pages/ai_chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';
import '../../features/profile/presentation/pages/privacy_policy_page.dart';
import '../../features/games/presentation/pages/games_page.dart';

class AppRouter {
  static const String welcome = '/';
  static const String auth = '/auth';
  static const String register = '/register';
  static const String home = '/home';
  static const String moodInput = '/mood-input';
  static const String journal = '/journal';
  static const String audioTherapy = '/audio-therapy';
  static const String audioPlayer = '/audio-player';
  static const String aiConsultation = '/ai-consultation';
  static const String community = '/community';
  static const String profile = '/profile';
  static const String helpSupport = '/help-support';
  static const String privacyPolicy = '/privacy-policy';
  static const String games = '/games';

  static final GoRouter _router = GoRouter(
    initialLocation: welcome,
    routes: [
      GoRoute(
        path: welcome,
        name: 'welcome',
        builder: (context, state) => const AuthWrapper(),
      ),

      GoRoute(
        path: '/welcome-page',
        name: 'welcome-page',
        builder: (context, state) => const WelcomePage(),
      ),

      GoRoute(
        path: auth,
        name: 'auth',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      GoRoute(
        path: moodInput,
        name: 'mood-input',
        builder: (context, state) => const MoodInputPage(),
      ),

      GoRoute(
        path: journal,
        name: 'journal',
        builder: (context, state) => const JournalPage(),
      ),

      GoRoute(
        path: audioTherapy,
        name: 'audio-therapy',
        builder: (context, state) => const AudioTherapyPage(),
      ),

      GoRoute(
        path: audioPlayer,
        name: 'audio-player',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AudioPlayerPage(
            imageUrl: extra?['imageUrl'] ?? '',
            title: extra?['title'] ?? '',
            artist: extra?['artist'] ?? '',
          );
        },
      ),

      GoRoute(
        path: aiConsultation,
        name: 'ai-consultation',
        builder: (context, state) => const AiChatPage(),
      ),

      GoRoute(
        path: community,
        name: 'community',
        builder: (context, state) => const CommunityPage(),
      ),

      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      GoRoute(
        path: helpSupport,
        name: 'help-support',
        builder: (context, state) => const HelpSupportPage(),
      ),

      GoRoute(
        path: privacyPolicy,
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),

      GoRoute(
        path: games,
        name: 'games',
        builder: (context, state) => const GamesPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.fullPath}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}

// Extension for easy navigation
extension AppRouterExtension on BuildContext {
  void goToWelcome() => go(AppRouter.welcome);
  void goToAuth() => go(AppRouter.auth);
  void goToHome() => go(AppRouter.home);
  void goToMoodInput() => go(AppRouter.moodInput);
  void goToJournal() => go(AppRouter.journal);
  void goToAudioTherapy() => go(AppRouter.audioTherapy);
  void goToAiConsultation() => go(AppRouter.aiConsultation);
  void goToCommunity() => go(AppRouter.community);
  void goToProfile() => go(AppRouter.profile);
  void goToGames() => go(AppRouter.games);

  void goToAudioPlayer({
    required String audioUrl,
    required String title,
    required String artist,
  }) {
    go(
      AppRouter.audioPlayer,
      extra: {'audioUrl': audioUrl, 'title': title, 'artist': artist},
    );
  }
}
