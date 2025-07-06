import 'package:equatable/equatable.dart';

import '../../../shared/models/models.dart';

abstract class MoodState extends Equatable {
  const MoodState();

  @override
  List<Object?> get props => [];
}

class MoodInitial extends MoodState {
  const MoodInitial();
}

class MoodLoading extends MoodState {
  const MoodLoading();
}

class MoodLoaded extends MoodState {
  final List<MoodModel> moods;

  const MoodLoaded({required this.moods});

  @override
  List<Object?> get props => [moods];
}

class MoodLogSuccess extends MoodState {
  final MoodModel mood;
  final int pointsEarned;

  const MoodLogSuccess({required this.mood, required this.pointsEarned});

  @override
  List<Object?> get props => [mood, pointsEarned];
}

class MoodTodayLoaded extends MoodState {
  final List<MoodModel> todayMoods;

  const MoodTodayLoaded({required this.todayMoods});

  @override
  List<Object?> get props => [todayMoods];
}

class MoodHistoryLoaded extends MoodState {
  final List<MoodModel> history;
  final bool hasMore;

  const MoodHistoryLoaded({required this.history, required this.hasMore});

  @override
  List<Object?> get props => [history, hasMore];
}

class MoodAnalyticsLoaded extends MoodState {
  final Map<String, int> moodCounts;
  final Map<String, double> averageIntensity;
  final List<String> commonTriggers;
  final List<String> commonActivities;
  final double overallAverage;
  final Map<String, int> weeklyTrends;

  const MoodAnalyticsLoaded({
    required this.moodCounts,
    required this.averageIntensity,
    required this.commonTriggers,
    required this.commonActivities,
    required this.overallAverage,
    required this.weeklyTrends,
  });

  @override
  List<Object?> get props => [
    moodCounts,
    averageIntensity,
    commonTriggers,
    commonActivities,
    overallAverage,
    weeklyTrends,
  ];
}

class MoodUpdateSuccess extends MoodState {
  final MoodModel mood;

  const MoodUpdateSuccess({required this.mood});

  @override
  List<Object?> get props => [mood];
}

class MoodDeleteSuccess extends MoodState {
  final String moodId;

  const MoodDeleteSuccess({required this.moodId});

  @override
  List<Object?> get props => [moodId];
}

class MoodError extends MoodState {
  final String message;

  const MoodError({required this.message});

  @override
  List<Object?> get props => [message];
}
