import 'package:equatable/equatable.dart';

import '../../../shared/models/journal_model.dart';

enum JournalStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  searching,
  exporting,
  error,
}

class JournalState extends Equatable {
  final JournalStatus status;
  final List<JournalEntry> entries;
  final List<JournalEntry> filteredEntries;
  final List<JournalPrompt> prompts;
  final List<JournalTemplate> templates;
  final JournalStats stats;
  final JournalEntry? currentEntry;
  final JournalPrompt? selectedPrompt;
  final JournalTemplate? selectedTemplate;
  final String? searchQuery;
  final Map<String, dynamic> filters;
  final List<String> availableTags;
  final List<String> availableCategories;
  final List<JournalEntry> drafts;
  final String? error;
  final bool hasReachedMax;
  final int currentPage;
  final bool isRealTimeEnabled;
  final DateTime? lastSyncTime;
  final Map<String, dynamic> metadata;

  JournalState({
    this.status = JournalStatus.initial,
    this.entries = const [],
    this.filteredEntries = const [],
    this.prompts = const [],
    this.templates = const [],
    JournalStats? stats,
    this.currentEntry,
    this.selectedPrompt,
    this.selectedTemplate,
    this.searchQuery,
    this.filters = const {},
    this.availableTags = const [],
    this.availableCategories = const [],
    this.drafts = const [],
    this.error,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.isRealTimeEnabled = false,
    this.lastSyncTime,
    this.metadata = const {},
  }) : stats = stats ?? JournalStats.empty();

  JournalState copyWith({
    JournalStatus? status,
    List<JournalEntry>? entries,
    List<JournalEntry>? filteredEntries,
    List<JournalPrompt>? prompts,
    List<JournalTemplate>? templates,
    JournalStats? stats,
    JournalEntry? currentEntry,
    JournalPrompt? selectedPrompt,
    JournalTemplate? selectedTemplate,
    String? searchQuery,
    Map<String, dynamic>? filters,
    List<String>? availableTags,
    List<String>? availableCategories,
    List<JournalEntry>? drafts,
    String? error,
    bool? hasReachedMax,
    int? currentPage,
    bool? isRealTimeEnabled,
    DateTime? lastSyncTime,
    Map<String, dynamic>? metadata,
  }) {
    return JournalState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      prompts: prompts ?? this.prompts,
      templates: templates ?? this.templates,
      stats: stats ?? this.stats,
      currentEntry: currentEntry ?? this.currentEntry,
      selectedPrompt: selectedPrompt ?? this.selectedPrompt,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      availableTags: availableTags ?? this.availableTags,
      availableCategories: availableCategories ?? this.availableCategories,
      drafts: drafts ?? this.drafts,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isRealTimeEnabled: isRealTimeEnabled ?? this.isRealTimeEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      metadata: metadata ?? this.metadata,
    );
  }

  // Clear current entry
  JournalState clearCurrentEntry() {
    return copyWith(
      currentEntry: null,
      selectedPrompt: null,
      selectedTemplate: null,
    );
  }

  // Clear error
  JournalState clearError() {
    return copyWith(error: null);
  }

  // Clear search and filters
  JournalState clearFilters() {
    return copyWith(
      searchQuery: null,
      filters: const {},
      filteredEntries: entries,
    );
  }

  // Reset pagination
  JournalState resetPagination() {
    return copyWith(currentPage: 0, hasReachedMax: false);
  }

  // Helper getters
  bool get isInitial => status == JournalStatus.initial;
  bool get isLoading => status == JournalStatus.loading;
  bool get isLoaded => status == JournalStatus.loaded;
  bool get isCreating => status == JournalStatus.creating;
  bool get isUpdating => status == JournalStatus.updating;
  bool get isDeleting => status == JournalStatus.deleting;
  bool get isSearching => status == JournalStatus.searching;
  bool get isExporting => status == JournalStatus.exporting;
  bool get hasError => status == JournalStatus.error;

  bool get hasEntries => entries.isNotEmpty;
  bool get hasFilteredEntries => filteredEntries.isNotEmpty;
  bool get hasPrompts => prompts.isNotEmpty;
  bool get hasTemplates => templates.isNotEmpty;
  bool get hasDrafts => drafts.isNotEmpty;
  bool get hasFilters => filters.isNotEmpty || searchQuery != null;
  bool get hasCurrentEntry => currentEntry != null;
  bool get hasSelectedPrompt => selectedPrompt != null;
  bool get hasSelectedTemplate => selectedTemplate != null;

  int get totalEntries => entries.length;
  int get totalFilteredEntries => filteredEntries.length;
  int get totalPrompts => prompts.length;
  int get totalTemplates => templates.length;
  int get totalDrafts => drafts.length;

  List<JournalEntry> get recentEntries {
    final sorted = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  List<JournalEntry> get favoriteEntries {
    return entries.where((entry) => entry.isFavorite).toList();
  }

  List<JournalEntry> get todayEntries {
    final today = DateTime.now();
    return entries.where((entry) {
      return entry.createdAt.year == today.year &&
          entry.createdAt.month == today.month &&
          entry.createdAt.day == today.day;
    }).toList();
  }

  List<JournalEntry> get thisWeekEntries {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return entries.where((entry) {
      return entry.createdAt.isAfter(startOfWeek);
    }).toList();
  }

  List<JournalEntry> get thisMonthEntries {
    final now = DateTime.now();
    return entries.where((entry) {
      return entry.createdAt.year == now.year &&
          entry.createdAt.month == now.month;
    }).toList();
  }

  Map<String, int> get moodDistribution {
    final distribution = <String, int>{};
    for (final entry in entries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> get categoryDistribution {
    final distribution = <String, int>{};
    for (final entry in entries) {
      distribution[entry.category] = (distribution[entry.category] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> get tagDistribution {
    final distribution = <String, int>{};
    for (final entry in entries) {
      for (final tag in entry.tags) {
        distribution[tag] = (distribution[tag] ?? 0) + 1;
      }
    }
    return distribution;
  }

  double get averageWordsPerEntry {
    if (entries.isEmpty) return 0.0;
    final totalWords = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.wordCount,
    );
    return totalWords / entries.length;
  }

  int get totalWords {
    return entries.fold<int>(0, (sum, entry) => sum + entry.wordCount);
  }

  int get currentStreak {
    if (entries.isEmpty) return 0;

    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );

      if (lastDate == null) {
        lastDate = entryDate;
        streak = 1;
      } else {
        final difference = lastDate.difference(entryDate).inDays;
        if (difference == 1) {
          streak++;
          lastDate = entryDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  List<JournalPrompt> get dailyPrompts {
    return prompts.where((prompt) => prompt.isDaily).toList();
  }

  List<JournalPrompt> get promptsByCategory {
    final categoryMap = <String, List<JournalPrompt>>{};
    for (final prompt in prompts) {
      if (!categoryMap.containsKey(prompt.category)) {
        categoryMap[prompt.category] = [];
      }
      categoryMap[prompt.category]!.add(prompt);
    }
    return categoryMap.values.expand((list) => list).toList();
  }

  List<JournalTemplate> get customTemplates {
    return templates.where((template) => template.isCustom).toList();
  }

  List<JournalTemplate> get defaultTemplates {
    return templates.where((template) => !template.isCustom).toList();
  }

  bool get canLoadMore => !hasReachedMax && !isLoading;

  String get statusMessage {
    switch (status) {
      case JournalStatus.initial:
        return 'Welcome to your journal';
      case JournalStatus.loading:
        return 'Loading entries...';
      case JournalStatus.loaded:
        return hasEntries ? 'Entries loaded' : 'No entries yet';
      case JournalStatus.creating:
        return 'Creating entry...';
      case JournalStatus.updating:
        return 'Updating entry...';
      case JournalStatus.deleting:
        return 'Deleting entry...';
      case JournalStatus.searching:
        return 'Searching entries...';
      case JournalStatus.exporting:
        return 'Exporting entries...';
      case JournalStatus.error:
        return error ?? 'An error occurred';
    }
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    filteredEntries,
    prompts,
    templates,
    stats,
    currentEntry,
    selectedPrompt,
    selectedTemplate,
    searchQuery,
    filters,
    availableTags,
    availableCategories,
    drafts,
    error,
    hasReachedMax,
    currentPage,
    isRealTimeEnabled,
    lastSyncTime,
    metadata,
  ];
}
