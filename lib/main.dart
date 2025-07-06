import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/services/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/mood/bloc/mood_bloc.dart';
import 'features/community/bloc/community_bloc.dart';
import 'features/journal/bloc/journal_bloc.dart';
import 'features/ai_chat/bloc/ai_chat_bloc.dart';
import 'features/audio/bloc/audio_bloc.dart';
import 'features/mood/bloc/mood_event.dart';
import 'model/user.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(const AuthStarted()),
        ),
        BlocProvider<MoodBloc>(
          create: (context) => di.sl<MoodBloc>()..add(const MoodStarted()),
        ),
        BlocProvider<CommunityBloc>(
          create: (context) => di.sl<CommunityBloc>(),
        ),
        BlocProvider<JournalBloc>(create: (context) => di.sl<JournalBloc>()),
        BlocProvider<AiChatBloc>(create: (context) => di.sl<AiChatBloc>()),
        BlocProvider<AudioBloc>(create: (context) => di.sl<AudioBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
