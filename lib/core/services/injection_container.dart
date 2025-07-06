import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/mood/bloc/mood_bloc.dart';
import '../../features/mood/repository/mood_repository.dart';
import '../../features/community/bloc/community_bloc.dart';
import '../../features/community/repository/community_repository.dart';
import '../../features/journal/bloc/journal_bloc.dart';
import '../../features/journal/repository/journal_repository.dart';
import '../../features/ai_chat/bloc/ai_chat_bloc.dart';
import '../../features/ai_chat/repository/ai_chat_repository.dart';
import '../../features/audio/bloc/audio_bloc.dart';
import '../../features/audio/repository/audio_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Firebase instances
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  // Google Sign In
  sl.registerLazySingleton(() => GoogleSignIn());

  // Audio player
  sl.registerFactory(() => AudioPlayer());

  // Gemini AI
  sl.registerLazySingleton(
    () => GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppConstants.geminiApiKey,
    ),
  );

  // Core services
  await _initCore();

  // Features
  await _initFeatures();
}

Future<void> _initCore() async {
  // Core services and repositories will be registered here
}

Future<void> _initFeatures() async {
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // Auth BLoC
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Mood Repository
  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepositoryImpl(firestore: sl(), firebaseAuth: sl()),
  );

  // Mood BLoC
  sl.registerFactory(() => MoodBloc(moodRepository: sl()));

  // Community Repository
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepository(firestore: sl(), auth: sl()),
  );

  // Community BLoC
  sl.registerFactory(() => CommunityBloc(repository: sl()));

  // Journal Repository
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepository(firestore: sl(), auth: sl(), storage: sl()),
  );

  // Journal BLoC
  sl.registerFactory(() => JournalBloc(repository: sl()));

  // AI Chat Repository
  sl.registerLazySingleton<AiChatRepository>(
    () => AiChatRepository(firestore: sl(), auth: sl()),
  );

  // AI Chat BLoC
  sl.registerFactory(() => AiChatBloc(repository: sl()));

  // Audio Repository
  sl.registerLazySingleton<AudioRepository>(
    () => AudioRepository(firestore: sl(), auth: sl()),
  );

  // Audio BLoC
  sl.registerFactory(() => AudioBloc(repository: sl()));
}
