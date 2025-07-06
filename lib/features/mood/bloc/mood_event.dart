import 'package:equatable/equatable.dart';

import '../../../shared/models/models.dart';

abstract class MoodEvent extends Equatable {
  const MoodEvent();

  @override
  List<Object?> get props => [];
}

class MoodStarted extends MoodEvent {
  const MoodStarted();
}

class MoodLogRequested extends MoodEvent {
  final String moodType;
  final String emoji;
  final int intensity;
  final String? note;
  final List<String> triggers;
  final List<String> activities;

  const MoodLogRequested({
    required this.moodType,
    required this.emoji,
    required this.intensity,
    this.note,
    required this.triggers,
    required this.activities,
  });

  @override
  List<Object?> get props => [
    moodType,
    emoji,
    intensity,
    note,
    triggers,
    activities,
  ];
}

class MoodHistoryRequested extends MoodEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const MoodHistoryRequested({this.startDate, this.endDate, this.limit});

  @override
  List<Object?> get props => [startDate, endDate, limit];
}

class MoodTodayRequested extends MoodEvent {
  const MoodTodayRequested();
}

class MoodWeeklyRequested extends MoodEvent {
  const MoodWeeklyRequested();
}

class MoodMonthlyRequested extends MoodEvent {
  const MoodMonthlyRequested();
}

class MoodAnalyticsRequested extends MoodEvent {
  final DateTime startDate;
  final DateTime endDate;

  const MoodAnalyticsRequested({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class MoodDeleteRequested extends MoodEvent {
  final String moodId;

  const MoodDeleteRequested({required this.moodId});

  @override
  List<Object?> get props => [moodId];
}

class MoodUpdateRequested extends MoodEvent {
  final MoodModel mood;

  const MoodUpdateRequested({required this.mood});

  @override
  List<Object?> get props => [mood];
}
