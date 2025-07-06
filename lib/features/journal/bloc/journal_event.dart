import 'package:equatable/equatable.dart';

import '../../../shared/models/journal_model.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

// Entry Management Events
class JournalStarted extends JournalEvent {
  const JournalStarted();
}

class JournalEntriesRequested extends JournalEvent {
  final String? category;
  final String? mood;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final bool? favoritesOnly;

  const JournalEntriesRequested({
    this.category,
    this.mood,
    this.startDate,
    this.endDate,
    this.limit,
    this.favoritesOnly,
  });

  @override
  List<Object?> get props => [
    category,
    mood,
    startDate,
    endDate,
    limit,
    favoritesOnly,
  ];
}

class JournalEntryCreated extends JournalEvent {
  final JournalEntry entry;

  const JournalEntryCreated({required this.entry});

  @override
  List<Object?> get props => [entry];
}

class JournalEntryUpdated extends JournalEvent {
  final JournalEntry entry;

  const JournalEntryUpdated({required this.entry});

  @override
  List<Object?> get props => [entry];
}

class JournalEntryDeleted extends JournalEvent {
  final String entryId;

  const JournalEntryDeleted({required this.entryId});

  @override
  List<Object?> get props => [entryId];
}

class JournalEntryFavoriteToggled extends JournalEvent {
  final String entryId;
  final bool isFavorite;

  const JournalEntryFavoriteToggled({
    required this.entryId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [entryId, isFavorite];
}

// Search and Filter Events
class JournalEntriesSearched extends JournalEvent {
  final String query;
  final List<String>? tags;
  final String? category;
  final String? mood;

  const JournalEntriesSearched({
    required this.query,
    this.tags,
    this.category,
    this.mood,
  });

  @override
  List<Object?> get props => [query, tags, category, mood];
}

class JournalFilterApplied extends JournalEvent {
  final String? category;
  final String? mood;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? tags;
  final bool? favoritesOnly;

  const JournalFilterApplied({
    this.category,
    this.mood,
    this.startDate,
    this.endDate,
    this.tags,
    this.favoritesOnly,
  });

  @override
  List<Object?> get props => [
    category,
    mood,
    startDate,
    endDate,
    tags,
    favoritesOnly,
  ];
}

class JournalFilterCleared extends JournalEvent {
  const JournalFilterCleared();
}

// Prompt Events
class JournalPromptsRequested extends JournalEvent {
  final String? category;
  final String? difficulty;
  final String? moodTarget;
  final bool? dailyOnly;

  const JournalPromptsRequested({
    this.category,
    this.difficulty,
    this.moodTarget,
    this.dailyOnly,
  });

  @override
  List<Object?> get props => [category, difficulty, moodTarget, dailyOnly];
}

class JournalDailyPromptRequested extends JournalEvent {
  const JournalDailyPromptRequested();
}

class JournalPromptSelected extends JournalEvent {
  final JournalPrompt prompt;

  const JournalPromptSelected({required this.prompt});

  @override
  List<Object?> get props => [prompt];
}

class JournalPromptCompleted extends JournalEvent {
  final String promptId;
  final JournalEntry entry;

  const JournalPromptCompleted({required this.promptId, required this.entry});

  @override
  List<Object?> get props => [promptId, entry];
}

// Template Events
class JournalTemplatesRequested extends JournalEvent {
  final String? category;
  final bool? customOnly;

  const JournalTemplatesRequested({this.category, this.customOnly});

  @override
  List<Object?> get props => [category, customOnly];
}

class JournalTemplateSelected extends JournalEvent {
  final JournalTemplate template;

  const JournalTemplateSelected({required this.template});

  @override
  List<Object?> get props => [template];
}

class JournalTemplateCreated extends JournalEvent {
  final JournalTemplate template;

  const JournalTemplateCreated({required this.template});

  @override
  List<Object?> get props => [template];
}

class JournalTemplateUpdated extends JournalEvent {
  final JournalTemplate template;

  const JournalTemplateUpdated({required this.template});

  @override
  List<Object?> get props => [template];
}

class JournalTemplateDeleted extends JournalEvent {
  final String templateId;

  const JournalTemplateDeleted({required this.templateId});

  @override
  List<Object?> get props => [templateId];
}

// Statistics Events
class JournalStatsRequested extends JournalEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const JournalStatsRequested({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class JournalStreakUpdated extends JournalEvent {
  const JournalStreakUpdated();
}

// Export Events
class JournalEntriesExported extends JournalEvent {
  final List<String> entryIds;
  final String format; // 'pdf', 'txt', 'json'
  final bool includeImages;

  const JournalEntriesExported({
    required this.entryIds,
    required this.format,
    required this.includeImages,
  });

  @override
  List<Object?> get props => [entryIds, format, includeImages];
}

// Backup Events
class JournalBackupRequested extends JournalEvent {
  const JournalBackupRequested();
}

class JournalBackupRestored extends JournalEvent {
  final String backupPath;

  const JournalBackupRestored({required this.backupPath});

  @override
  List<Object?> get props => [backupPath];
}

// Real-time Events
class JournalRealTimeUpdatesEnabled extends JournalEvent {
  const JournalRealTimeUpdatesEnabled();
}

class JournalRealTimeUpdatesDisabled extends JournalEvent {
  const JournalRealTimeUpdatesDisabled();
}

class JournalEntryReceived extends JournalEvent {
  final JournalEntry entry;

  const JournalEntryReceived({required this.entry});

  @override
  List<Object?> get props => [entry];
}

// Mood Integration Events
class JournalMoodEntryCreated extends JournalEvent {
  final String mood;
  final double intensity;
  final List<String> triggers;
  final List<String> activities;

  const JournalMoodEntryCreated({
    required this.mood,
    required this.intensity,
    required this.triggers,
    required this.activities,
  });

  @override
  List<Object?> get props => [mood, intensity, triggers, activities];
}

// Reminder Events
class JournalReminderSet extends JournalEvent {
  final DateTime reminderTime;
  final String message;
  final bool isDaily;

  const JournalReminderSet({
    required this.reminderTime,
    required this.message,
    required this.isDaily,
  });

  @override
  List<Object?> get props => [reminderTime, message, isDaily];
}

class JournalReminderCancelled extends JournalEvent {
  final String reminderId;

  const JournalReminderCancelled({required this.reminderId});

  @override
  List<Object?> get props => [reminderId];
}

// Voice Entry Events
class JournalVoiceRecordingStarted extends JournalEvent {
  const JournalVoiceRecordingStarted();
}

class JournalVoiceRecordingStopped extends JournalEvent {
  const JournalVoiceRecordingStopped();
}

class JournalVoiceTranscriptionReceived extends JournalEvent {
  final String transcription;

  const JournalVoiceTranscriptionReceived({required this.transcription});

  @override
  List<Object?> get props => [transcription];
}

// Draft Events
class JournalDraftSaved extends JournalEvent {
  final JournalEntry draft;

  const JournalDraftSaved({required this.draft});

  @override
  List<Object?> get props => [draft];
}

class JournalDraftLoaded extends JournalEvent {
  final String draftId;

  const JournalDraftLoaded({required this.draftId});

  @override
  List<Object?> get props => [draftId];
}

class JournalDraftDeleted extends JournalEvent {
  final String draftId;

  const JournalDraftDeleted({required this.draftId});

  @override
  List<Object?> get props => [draftId];
}

// Tag Events
class JournalTagsRequested extends JournalEvent {
  const JournalTagsRequested();
}

class JournalTagCreated extends JournalEvent {
  final String tag;

  const JournalTagCreated({required this.tag});

  @override
  List<Object?> get props => [tag];
}

class JournalTagDeleted extends JournalEvent {
  final String tag;

  const JournalTagDeleted({required this.tag});

  @override
  List<Object?> get props => [tag];
}

// Sharing Events
class JournalEntryShared extends JournalEvent {
  final String entryId;
  final String shareType; // 'link', 'text', 'image'
  final Map<String, dynamic> shareSettings;

  const JournalEntryShared({
    required this.entryId,
    required this.shareType,
    required this.shareSettings,
  });

  @override
  List<Object?> get props => [entryId, shareType, shareSettings];
}

// Image Events
class JournalImageAdded extends JournalEvent {
  final String entryId;
  final String imagePath;

  const JournalImageAdded({required this.entryId, required this.imagePath});

  @override
  List<Object?> get props => [entryId, imagePath];
}

class JournalImageRemoved extends JournalEvent {
  final String entryId;
  final String imageUrl;

  const JournalImageRemoved({required this.entryId, required this.imageUrl});

  @override
  List<Object?> get props => [entryId, imageUrl];
}

// Reflection Events
class JournalReflectionAdded extends JournalEvent {
  final String entryId;
  final String reflectionType;
  final String content;

  const JournalReflectionAdded({
    required this.entryId,
    required this.reflectionType,
    required this.content,
  });

  @override
  List<Object?> get props => [entryId, reflectionType, content];
}

class JournalReflectionUpdated extends JournalEvent {
  final String entryId;
  final String reflectionType;
  final String content;

  const JournalReflectionUpdated({
    required this.entryId,
    required this.reflectionType,
    required this.content,
  });

  @override
  List<Object?> get props => [entryId, reflectionType, content];
}

class JournalReflectionRemoved extends JournalEvent {
  final String entryId;
  final String reflectionType;

  const JournalReflectionRemoved({
    required this.entryId,
    required this.reflectionType,
  });

  @override
  List<Object?> get props => [entryId, reflectionType];
}
