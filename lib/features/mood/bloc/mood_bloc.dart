import 'dart:async';

import 'package:bloc/bloc.dart';

import '../repository/mood_repository.dart';
import 'mood_event.dart';
import 'mood_state.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodRepository _moodRepository;

  MoodBloc({required MoodRepository moodRepository})
    : _moodRepository = moodRepository,
      super(const MoodInitial()) {
    // Register event handlers
    on<MoodStarted>(_onMoodStarted);
    on<MoodLogRequested>(_onMoodLogRequested);
    on<MoodHistoryRequested>(_onMoodHistoryRequested);
    on<MoodTodayRequested>(_onMoodTodayRequested);
    on<MoodWeeklyRequested>(_onMoodWeeklyRequested);
    on<MoodMonthlyRequested>(_onMoodMonthlyRequested);
    on<MoodAnalyticsRequested>(_onMoodAnalyticsRequested);
    on<MoodUpdateRequested>(_onMoodUpdateRequested);
    on<MoodDeleteRequested>(_onMoodDeleteRequested);
  }

  Future<void> _onMoodStarted(
    MoodStarted event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());
    try {
      final todayMoods = await _moodRepository.getTodayMoods();
      emit(MoodTodayLoaded(todayMoods: todayMoods));
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodLogRequested(
    MoodLogRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());
    try {
      final mood = await _moodRepository.logMood(
        moodType: event.moodType,
        emoji: event.emoji,
        intensity: event.intensity,
        note: event.note,
        triggers: event.triggers,
        activities: event.activities,
      );

      emit(MoodLogSuccess(mood: mood, pointsEarned: mood.pointsEarned));
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodHistoryRequested(
    MoodHistoryRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());
    try {
      final history = await _moodRepository.getMoodHistory(
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
      );

      emit(
        MoodHistoryLoaded(
          history: history,
          hasMore:
              history.length ==
              (event.limit ?? 50), // Assume has more if we got full limit
        ),
      );
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodTodayRequested(
    MoodTodayRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());
    try {
      final todayMoods = await _moodRepository.getTodayMoods();
      emit(MoodTodayLoaded(todayMoods: todayMoods));
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodWeeklyRequested(
    MoodWeeklyRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());
    try {
      final weeklyMoods = await _moodRepository.getWeeklyMoods();
      emit(MoodLoaded(moods: weeklyMoods));
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodMonthlyRequested(
    MoodMonthlyRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());
    try {
      final monthlyMoods = await _moodRepository.getMonthlyMoods();
      emit(MoodLoaded(moods: monthlyMoods));
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodAnalyticsRequested(
    MoodAnalyticsRequested event,
    Emitter<MoodState> emit,
  ) async {
    emit(const MoodLoading());
    try {
      final analytics = await _moodRepository.getMoodAnalytics(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(
        MoodAnalyticsLoaded(
          moodCounts: Map<String, int>.from(analytics['moodCounts']),
          averageIntensity: Map<String, double>.from(
            analytics['averageIntensity'],
          ),
          commonTriggers: List<String>.from(analytics['commonTriggers']),
          commonActivities: List<String>.from(analytics['commonActivities']),
          overallAverage: analytics['overallAverage'].toDouble(),
          weeklyTrends: Map<String, int>.from(analytics['weeklyTrends']),
        ),
      );
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodUpdateRequested(
    MoodUpdateRequested event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await _moodRepository.updateMood(event.mood);
      emit(MoodUpdateSuccess(mood: event.mood));
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }

  Future<void> _onMoodDeleteRequested(
    MoodDeleteRequested event,
    Emitter<MoodState> emit,
  ) async {
    try {
      await _moodRepository.deleteMood(event.moodId);
      emit(MoodDeleteSuccess(moodId: event.moodId));
    } catch (e) {
      emit(MoodError(message: e.toString()));
    }
  }
}
