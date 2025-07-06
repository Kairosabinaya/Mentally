import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/journal_model.dart';
import '../repository/journal_repository.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository _repository;
  StreamSubscription<List<JournalEntry>>? _entriesSubscription;

  JournalBloc({required JournalRepository repository})
    : _repository = repository,
      super(JournalState()) {
    on<JournalStarted>(_onJournalStarted);
    on<JournalEntriesRequested>(_onJournalEntriesRequested);
    on<JournalEntryCreated>(_onJournalEntryCreated);
    on<JournalEntryUpdated>(_onJournalEntryUpdated);
    on<JournalEntryDeleted>(_onJournalEntryDeleted);
    on<JournalEntryFavoriteToggled>(_onJournalEntryFavoriteToggled);
    on<JournalEntriesSearched>(_onJournalEntriesSearched);
    on<JournalFilterApplied>(_onJournalFilterApplied);
    on<JournalFilterCleared>(_onJournalFilterCleared);
    on<JournalPromptsRequested>(_onJournalPromptsRequested);
    on<JournalDailyPromptRequested>(_onJournalDailyPromptRequested);
    on<JournalPromptSelected>(_onJournalPromptSelected);
    on<JournalPromptCompleted>(_onJournalPromptCompleted);
    on<JournalTemplatesRequested>(_onJournalTemplatesRequested);
    on<JournalTemplateSelected>(_onJournalTemplateSelected);
    on<JournalTemplateCreated>(_onJournalTemplateCreated);
    on<JournalTemplateUpdated>(_onJournalTemplateUpdated);
    on<JournalTemplateDeleted>(_onJournalTemplateDeleted);
    on<JournalStatsRequested>(_onJournalStatsRequested);
    on<JournalStreakUpdated>(_onJournalStreakUpdated);
    on<JournalEntriesExported>(_onJournalEntriesExported);
    on<JournalBackupRequested>(_onJournalBackupRequested);
    on<JournalBackupRestored>(_onJournalBackupRestored);
    on<JournalRealTimeUpdatesEnabled>(_onJournalRealTimeUpdatesEnabled);
    on<JournalRealTimeUpdatesDisabled>(_onJournalRealTimeUpdatesDisabled);
    on<JournalEntryReceived>(_onJournalEntryReceived);
    on<JournalMoodEntryCreated>(_onJournalMoodEntryCreated);
    on<JournalReminderSet>(_onJournalReminderSet);
    on<JournalReminderCancelled>(_onJournalReminderCancelled);
    on<JournalVoiceRecordingStarted>(_onJournalVoiceRecordingStarted);
    on<JournalVoiceRecordingStopped>(_onJournalVoiceRecordingStopped);
    on<JournalVoiceTranscriptionReceived>(_onJournalVoiceTranscriptionReceived);
    on<JournalDraftSaved>(_onJournalDraftSaved);
    on<JournalDraftLoaded>(_onJournalDraftLoaded);
    on<JournalDraftDeleted>(_onJournalDraftDeleted);
    on<JournalTagsRequested>(_onJournalTagsRequested);
    on<JournalTagCreated>(_onJournalTagCreated);
    on<JournalTagDeleted>(_onJournalTagDeleted);
    on<JournalEntryShared>(_onJournalEntryShared);
    on<JournalImageAdded>(_onJournalImageAdded);
    on<JournalImageRemoved>(_onJournalImageRemoved);
    on<JournalReflectionAdded>(_onJournalReflectionAdded);
    on<JournalReflectionUpdated>(_onJournalReflectionUpdated);
    on<JournalReflectionRemoved>(_onJournalReflectionRemoved);
  }

  @override
  Future<void> close() {
    _entriesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onJournalStarted(
    JournalStarted event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.loading));

    try {
      // Load initial data in parallel
      final futures = await Future.wait([
        _repository.getEntries(limit: 20),
        _repository.getPrompts(),
        _repository.getTemplates(),
        _repository.getAllTags(),
        _repository.getAllCategories(),
        _repository.getDrafts(),
      ]);

      final entries = futures[0] as List<JournalEntry>;
      final prompts = futures[1] as List<JournalPrompt>;
      final templates = futures[2] as List<JournalTemplate>;
      final tags = futures[3] as List<String>;
      final categories = futures[4] as List<String>;
      final drafts = futures[5] as List<JournalEntry>;

      final stats = await _repository.getStats();

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          entries: entries,
          filteredEntries: entries,
          prompts: prompts,
          templates: templates,
          stats: stats,
          availableTags: tags,
          availableCategories: categories,
          drafts: drafts,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalEntriesRequested(
    JournalEntriesRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.loading));

    try {
      final entries = await _repository.getEntries(
        category: event.category,
        mood: event.mood,
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
        favoritesOnly: event.favoritesOnly,
      );

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          entries: entries,
          filteredEntries: entries,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalEntryCreated(
    JournalEntryCreated event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.creating));

    try {
      final newEntry = await _repository.createEntry(event.entry);

      final updatedEntries = [newEntry, ...state.entries];
      final updatedStats = await _repository.getStats();

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          entries: updatedEntries,
          filteredEntries: updatedEntries,
          stats: updatedStats,
          currentEntry: newEntry,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalEntryUpdated(
    JournalEntryUpdated event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.updating));

    try {
      final updatedEntry = await _repository.updateEntry(event.entry);

      final updatedEntries =
          state.entries.map((entry) {
            return entry.id == updatedEntry.id ? updatedEntry : entry;
          }).toList();

      final updatedStats = await _repository.getStats();

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          entries: updatedEntries,
          filteredEntries: updatedEntries,
          stats: updatedStats,
          currentEntry: updatedEntry,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalEntryDeleted(
    JournalEntryDeleted event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.deleting));

    try {
      await _repository.deleteEntry(event.entryId);

      final updatedEntries =
          state.entries.where((entry) => entry.id != event.entryId).toList();

      final updatedStats = await _repository.getStats();

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          entries: updatedEntries,
          filteredEntries: updatedEntries,
          stats: updatedStats,
          currentEntry:
              state.currentEntry?.id == event.entryId
                  ? null
                  : state.currentEntry,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalEntryFavoriteToggled(
    JournalEntryFavoriteToggled event,
    Emitter<JournalState> emit,
  ) async {
    // Optimistic update
    final updatedEntries =
        state.entries.map((entry) {
          if (entry.id == event.entryId) {
            return entry.copyWith(isFavorite: event.isFavorite);
          }
          return entry;
        }).toList();

    emit(
      state.copyWith(entries: updatedEntries, filteredEntries: updatedEntries),
    );

    try {
      await _repository.toggleFavorite(event.entryId, event.isFavorite);

      final updatedStats = await _repository.getStats();

      emit(state.copyWith(stats: updatedStats, lastSyncTime: DateTime.now()));
    } catch (e) {
      // Revert optimistic update
      emit(
        state.copyWith(
          entries: state.entries,
          filteredEntries: state.entries,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onJournalEntriesSearched(
    JournalEntriesSearched event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.searching));

    try {
      final searchResults = await _repository.searchEntries(
        query: event.query,
        tags: event.tags,
        category: event.category,
        mood: event.mood,
      );

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          filteredEntries: searchResults,
          searchQuery: event.query,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalFilterApplied(
    JournalFilterApplied event,
    Emitter<JournalState> emit,
  ) async {
    final filters = <String, dynamic>{};

    if (event.category != null) filters['category'] = event.category;
    if (event.mood != null) filters['mood'] = event.mood;
    if (event.startDate != null) filters['startDate'] = event.startDate;
    if (event.endDate != null) filters['endDate'] = event.endDate;
    if (event.tags != null) filters['tags'] = event.tags;
    if (event.favoritesOnly != null)
      filters['favoritesOnly'] = event.favoritesOnly;

    emit(state.copyWith(status: JournalStatus.searching, filters: filters));

    try {
      final filteredEntries = await _repository.getEntries(
        category: event.category,
        mood: event.mood,
        startDate: event.startDate,
        endDate: event.endDate,
        favoritesOnly: event.favoritesOnly,
      );

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          filteredEntries: filteredEntries,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalFilterCleared(
    JournalFilterCleared event,
    Emitter<JournalState> emit,
  ) async {
    emit(
      state.copyWith(
        filteredEntries: state.entries,
        searchQuery: null,
        filters: const {},
      ),
    );
  }

  Future<void> _onJournalPromptsRequested(
    JournalPromptsRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final prompts = await _repository.getPrompts(
        category: event.category,
        difficulty: event.difficulty,
        moodTarget: event.moodTarget,
        dailyOnly: event.dailyOnly,
      );

      emit(state.copyWith(prompts: prompts, lastSyncTime: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalDailyPromptRequested(
    JournalDailyPromptRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final dailyPrompt = await _repository.getDailyPrompt();

      emit(
        state.copyWith(
          selectedPrompt: dailyPrompt,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalPromptSelected(
    JournalPromptSelected event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(selectedPrompt: event.prompt));
  }

  Future<void> _onJournalPromptCompleted(
    JournalPromptCompleted event,
    Emitter<JournalState> emit,
  ) async {
    // Create entry with prompt reference
    final entryWithPrompt = event.entry.copyWith(
      prompts: [event.promptId],
      metadata: {
        ...event.entry.metadata,
        'completedPrompt': event.promptId,
        'promptCompletedAt': DateTime.now().toIso8601String(),
      },
    );

    add(JournalEntryCreated(entry: entryWithPrompt));

    // Clear selected prompt
    emit(state.copyWith(selectedPrompt: null));
  }

  Future<void> _onJournalTemplatesRequested(
    JournalTemplatesRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final templates = await _repository.getTemplates(
        category: event.category,
        customOnly: event.customOnly,
      );

      emit(state.copyWith(templates: templates, lastSyncTime: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalTemplateSelected(
    JournalTemplateSelected event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(selectedTemplate: event.template));
  }

  Future<void> _onJournalTemplateCreated(
    JournalTemplateCreated event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final newTemplate = await _repository.createTemplate(event.template);

      final updatedTemplates = [newTemplate, ...state.templates];

      emit(
        state.copyWith(
          templates: updatedTemplates,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalTemplateUpdated(
    JournalTemplateUpdated event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final updatedTemplate = await _repository.updateTemplate(event.template);

      final updatedTemplates =
          state.templates.map((template) {
            return template.id == updatedTemplate.id
                ? updatedTemplate
                : template;
          }).toList();

      emit(
        state.copyWith(
          templates: updatedTemplates,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalTemplateDeleted(
    JournalTemplateDeleted event,
    Emitter<JournalState> emit,
  ) async {
    try {
      await _repository.deleteTemplate(event.templateId);

      final updatedTemplates =
          state.templates
              .where((template) => template.id != event.templateId)
              .toList();

      emit(
        state.copyWith(
          templates: updatedTemplates,
          selectedTemplate:
              state.selectedTemplate?.id == event.templateId
                  ? null
                  : state.selectedTemplate,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalStatsRequested(
    JournalStatsRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final stats = await _repository.getStats(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(state.copyWith(stats: stats, lastSyncTime: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalStreakUpdated(
    JournalStreakUpdated event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final stats = await _repository.getStats();

      emit(state.copyWith(stats: stats, lastSyncTime: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalEntriesExported(
    JournalEntriesExported event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.exporting));

    try {
      final exportData = await _repository.exportEntries(
        entryIds: event.entryIds,
        format: event.format,
        includeImages: event.includeImages,
      );

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          metadata: {
            ...state.metadata,
            'lastExport': exportData,
            'lastExportTime': DateTime.now().toIso8601String(),
          },
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalBackupRequested(
    JournalBackupRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.exporting));

    try {
      final allEntries = await _repository.getEntries();
      final entryIds = allEntries.map((e) => e.id).toList();

      final backupData = await _repository.exportEntries(
        entryIds: entryIds,
        format: 'json',
        includeImages: false,
      );

      emit(
        state.copyWith(
          status: JournalStatus.loaded,
          metadata: {
            ...state.metadata,
            'lastBackup': backupData,
            'lastBackupTime': DateTime.now().toIso8601String(),
          },
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalBackupRestored(
    JournalBackupRestored event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.loading));

    try {
      // In a real implementation, this would restore from backup
      // For now, just refresh the data
      add(const JournalStarted());
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> _onJournalRealTimeUpdatesEnabled(
    JournalRealTimeUpdatesEnabled event,
    Emitter<JournalState> emit,
  ) async {
    _entriesSubscription?.cancel();

    _entriesSubscription = _repository
        .getEntriesStream(limit: 20)
        .listen(
          (entries) {
            add(JournalEntryReceived(entry: entries.first));
          },
          onError: (error) {
            emit(state.copyWith(error: error.toString()));
          },
        );

    emit(state.copyWith(isRealTimeEnabled: true));
  }

  Future<void> _onJournalRealTimeUpdatesDisabled(
    JournalRealTimeUpdatesDisabled event,
    Emitter<JournalState> emit,
  ) async {
    _entriesSubscription?.cancel();
    _entriesSubscription = null;

    emit(state.copyWith(isRealTimeEnabled: false));
  }

  Future<void> _onJournalEntryReceived(
    JournalEntryReceived event,
    Emitter<JournalState> emit,
  ) async {
    final existingIndex = state.entries.indexWhere(
      (e) => e.id == event.entry.id,
    );

    if (existingIndex != -1) {
      // Update existing entry
      final updatedEntries = List<JournalEntry>.from(state.entries);
      updatedEntries[existingIndex] = event.entry;

      emit(
        state.copyWith(
          entries: updatedEntries,
          filteredEntries: updatedEntries,
          lastSyncTime: DateTime.now(),
        ),
      );
    } else {
      // Add new entry
      final updatedEntries = [event.entry, ...state.entries];

      emit(
        state.copyWith(
          entries: updatedEntries,
          filteredEntries: updatedEntries,
          lastSyncTime: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _onJournalMoodEntryCreated(
    JournalMoodEntryCreated event,
    Emitter<JournalState> emit,
  ) async {
    // Create a journal entry from mood data
    final moodEntry = JournalEntry.empty().copyWith(
      title: 'Mood Entry - ${DateTime.now().toString().split(' ')[0]}',
      content:
          'Mood: ${event.mood}\nIntensity: ${event.intensity}/5\n\nTriggers: ${event.triggers.join(', ')}\nActivities: ${event.activities.join(', ')}',
      mood: event.mood,
      moodIntensity: event.intensity,
      tags: [...event.triggers, ...event.activities],
      category: 'mood',
      metadata: {
        'triggers': event.triggers,
        'activities': event.activities,
        'source': 'mood_tracker',
      },
    );

    add(JournalEntryCreated(entry: moodEntry));
  }

  Future<void> _onJournalReminderSet(
    JournalReminderSet event,
    Emitter<JournalState> emit,
  ) async {
    // In a real implementation, this would set up local notifications
    emit(
      state.copyWith(
        metadata: {
          ...state.metadata,
          'reminderSet': true,
          'reminderTime': event.reminderTime.toIso8601String(),
          'reminderMessage': event.message,
          'isDaily': event.isDaily,
        },
      ),
    );
  }

  Future<void> _onJournalReminderCancelled(
    JournalReminderCancelled event,
    Emitter<JournalState> emit,
  ) async {
    // In a real implementation, this would cancel local notifications
    emit(state.copyWith(metadata: {...state.metadata, 'reminderSet': false}));
  }

  Future<void> _onJournalVoiceRecordingStarted(
    JournalVoiceRecordingStarted event,
    Emitter<JournalState> emit,
  ) async {
    emit(
      state.copyWith(
        metadata: {
          ...state.metadata,
          'voiceRecording': true,
          'recordingStartTime': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  Future<void> _onJournalVoiceRecordingStopped(
    JournalVoiceRecordingStopped event,
    Emitter<JournalState> emit,
  ) async {
    emit(
      state.copyWith(
        metadata: {
          ...state.metadata,
          'voiceRecording': false,
          'recordingEndTime': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  Future<void> _onJournalVoiceTranscriptionReceived(
    JournalVoiceTranscriptionReceived event,
    Emitter<JournalState> emit,
  ) async {
    // Create a draft entry from voice transcription
    final voiceEntry = JournalEntry.empty().copyWith(
      title: 'Voice Entry - ${DateTime.now().toString().split(' ')[0]}',
      content: event.transcription,
      category: 'voice',
      metadata: {
        'source': 'voice_transcription',
        'transcribedAt': DateTime.now().toIso8601String(),
      },
    );

    add(JournalDraftSaved(draft: voiceEntry));
  }

  Future<void> _onJournalDraftSaved(
    JournalDraftSaved event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final savedDraft = await _repository.saveDraft(event.draft);

      final updatedDrafts =
          state.drafts.any((d) => d.id == savedDraft.id)
              ? state.drafts
                  .map((d) => d.id == savedDraft.id ? savedDraft : d)
                  .toList()
              : [savedDraft, ...state.drafts];

      emit(
        state.copyWith(
          drafts: updatedDrafts,
          currentEntry: savedDraft,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalDraftLoaded(
    JournalDraftLoaded event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final draft = state.drafts.firstWhere((d) => d.id == event.draftId);

      emit(state.copyWith(currentEntry: draft));
    } catch (e) {
      emit(state.copyWith(error: 'Draft not found'));
    }
  }

  Future<void> _onJournalDraftDeleted(
    JournalDraftDeleted event,
    Emitter<JournalState> emit,
  ) async {
    try {
      await _repository.deleteDraft(event.draftId);

      final updatedDrafts =
          state.drafts.where((draft) => draft.id != event.draftId).toList();

      emit(
        state.copyWith(
          drafts: updatedDrafts,
          currentEntry:
              state.currentEntry?.id == event.draftId
                  ? null
                  : state.currentEntry,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalTagsRequested(
    JournalTagsRequested event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final tags = await _repository.getAllTags();

      emit(state.copyWith(availableTags: tags, lastSyncTime: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalTagCreated(
    JournalTagCreated event,
    Emitter<JournalState> emit,
  ) async {
    if (!state.availableTags.contains(event.tag)) {
      final updatedTags = [...state.availableTags, event.tag]..sort();

      emit(state.copyWith(availableTags: updatedTags));
    }
  }

  Future<void> _onJournalTagDeleted(
    JournalTagDeleted event,
    Emitter<JournalState> emit,
  ) async {
    final updatedTags =
        state.availableTags.where((tag) => tag != event.tag).toList();

    emit(state.copyWith(availableTags: updatedTags));
  }

  Future<void> _onJournalEntryShared(
    JournalEntryShared event,
    Emitter<JournalState> emit,
  ) async {
    // In a real implementation, this would handle sharing logic
    emit(
      state.copyWith(
        metadata: {
          ...state.metadata,
          'lastSharedEntry': event.entryId,
          'shareType': event.shareType,
          'sharedAt': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  Future<void> _onJournalImageAdded(
    JournalImageAdded event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final imageFile = File(event.imagePath);
      final imageUrl = await _repository.uploadImage(imageFile, event.entryId);

      // Update the entry with the new image URL
      final entry = state.entries.firstWhere((e) => e.id == event.entryId);
      final updatedEntry = entry.copyWith(
        imageUrls: [...entry.imageUrls, imageUrl],
        updatedAt: DateTime.now(),
      );

      add(JournalEntryUpdated(entry: updatedEntry));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalImageRemoved(
    JournalImageRemoved event,
    Emitter<JournalState> emit,
  ) async {
    try {
      // Update the entry to remove the image URL
      final entry = state.entries.firstWhere((e) => e.id == event.entryId);
      final updatedEntry = entry.copyWith(
        imageUrls:
            entry.imageUrls.where((url) => url != event.imageUrl).toList(),
        updatedAt: DateTime.now(),
      );

      add(JournalEntryUpdated(entry: updatedEntry));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalReflectionAdded(
    JournalReflectionAdded event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final entry = state.entries.firstWhere((e) => e.id == event.entryId);
      final updatedReflections = {
        ...entry.reflections,
        event.reflectionType: event.content,
      };

      final updatedEntry = entry.copyWith(
        reflections: updatedReflections,
        updatedAt: DateTime.now(),
      );

      add(JournalEntryUpdated(entry: updatedEntry));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalReflectionUpdated(
    JournalReflectionUpdated event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final entry = state.entries.firstWhere((e) => e.id == event.entryId);
      final updatedReflections = {
        ...entry.reflections,
        event.reflectionType: event.content,
      };

      final updatedEntry = entry.copyWith(
        reflections: updatedReflections,
        updatedAt: DateTime.now(),
      );

      add(JournalEntryUpdated(entry: updatedEntry));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onJournalReflectionRemoved(
    JournalReflectionRemoved event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final entry = state.entries.firstWhere((e) => e.id == event.entryId);
      final updatedReflections = Map<String, dynamic>.from(entry.reflections);
      updatedReflections.remove(event.reflectionType);

      final updatedEntry = entry.copyWith(
        reflections: updatedReflections,
        updatedAt: DateTime.now(),
      );

      add(JournalEntryUpdated(entry: updatedEntry));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
