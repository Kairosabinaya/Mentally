import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String mood;
  final double moodIntensity;
  final List<String> tags;
  final List<String> prompts;
  final Map<String, dynamic> reflections;
  final List<String> imageUrls;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int wordCount;
  final String category;
  final bool isFavorite;
  final Map<String, dynamic> metadata;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    required this.moodIntensity,
    required this.tags,
    required this.prompts,
    required this.reflections,
    required this.imageUrls,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
    required this.wordCount,
    required this.category,
    required this.isFavorite,
    required this.metadata,
  });

  factory JournalEntry.empty() {
    return JournalEntry(
      id: '',
      userId: '',
      title: '',
      content: '',
      mood: 'neutral',
      moodIntensity: 3.0,
      tags: const [],
      prompts: const [],
      reflections: const {},
      imageUrls: const [],
      isPrivate: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      wordCount: 0,
      category: 'general',
      isFavorite: false,
      metadata: const {},
    );
  }

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JournalEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      mood: data['mood'] ?? 'neutral',
      moodIntensity: (data['moodIntensity'] ?? 3.0).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      prompts: List<String>.from(data['prompts'] ?? []),
      reflections: Map<String, dynamic>.from(data['reflections'] ?? {}),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      isPrivate: data['isPrivate'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      wordCount: data['wordCount'] ?? 0,
      category: data['category'] ?? 'general',
      isFavorite: data['isFavorite'] ?? false,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'moodIntensity': moodIntensity,
      'tags': tags,
      'prompts': prompts,
      'reflections': reflections,
      'imageUrls': imageUrls,
      'isPrivate': isPrivate,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'wordCount': wordCount,
      'category': category,
      'isFavorite': isFavorite,
      'metadata': metadata,
    };
  }

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? mood,
    double? moodIntensity,
    List<String>? tags,
    List<String>? prompts,
    Map<String, dynamic>? reflections,
    List<String>? imageUrls,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? wordCount,
    String? category,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      moodIntensity: moodIntensity ?? this.moodIntensity,
      tags: tags ?? this.tags,
      prompts: prompts ?? this.prompts,
      reflections: reflections ?? this.reflections,
      imageUrls: imageUrls ?? this.imageUrls,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wordCount: wordCount ?? this.wordCount,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  bool get isEmpty => content.trim().isEmpty && title.trim().isEmpty;
  bool get hasImages => imageUrls.isNotEmpty;
  bool get hasTags => tags.isNotEmpty;
  bool get hasPrompts => prompts.isNotEmpty;
  bool get hasReflections => reflections.isNotEmpty;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get readingTime {
    final wordsPerMinute = 200;
    final minutes = (wordCount / wordsPerMinute).ceil();
    if (minutes < 1) return '< 1 min read';
    return '$minutes min read';
  }

  String get excerpt {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    content,
    mood,
    moodIntensity,
    tags,
    prompts,
    reflections,
    imageUrls,
    isPrivate,
    createdAt,
    updatedAt,
    wordCount,
    category,
    isFavorite,
    metadata,
  ];
}

class JournalPrompt extends Equatable {
  final String id;
  final String title;
  final String prompt;
  final String category;
  final List<String> tags;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String moodTarget; // Target mood this prompt is designed for
  final int estimatedMinutes;
  final bool isDaily;
  final Map<String, dynamic> metadata;

  const JournalPrompt({
    required this.id,
    required this.title,
    required this.prompt,
    required this.category,
    required this.tags,
    required this.difficulty,
    required this.moodTarget,
    required this.estimatedMinutes,
    required this.isDaily,
    required this.metadata,
  });

  factory JournalPrompt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JournalPrompt(
      id: doc.id,
      title: data['title'] ?? '',
      prompt: data['prompt'] ?? '',
      category: data['category'] ?? 'general',
      tags: List<String>.from(data['tags'] ?? []),
      difficulty: data['difficulty'] ?? 'easy',
      moodTarget: data['moodTarget'] ?? 'neutral',
      estimatedMinutes: data['estimatedMinutes'] ?? 5,
      isDaily: data['isDaily'] ?? false,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'prompt': prompt,
      'category': category,
      'tags': tags,
      'difficulty': difficulty,
      'moodTarget': moodTarget,
      'estimatedMinutes': estimatedMinutes,
      'isDaily': isDaily,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    prompt,
    category,
    tags,
    difficulty,
    moodTarget,
    estimatedMinutes,
    isDaily,
    metadata,
  ];
}

class JournalTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> sections;
  final List<JournalPrompt> prompts;
  final String category;
  final bool isCustom;
  final Map<String, dynamic> settings;

  const JournalTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.sections,
    required this.prompts,
    required this.category,
    required this.isCustom,
    required this.settings,
  });

  factory JournalTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JournalTemplate(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      sections: List<String>.from(data['sections'] ?? []),
      prompts:
          (data['prompts'] as List<dynamic>?)
              ?.map((p) => JournalPrompt.fromFirestore(p))
              .toList() ??
          [],
      category: data['category'] ?? 'general',
      isCustom: data['isCustom'] ?? false,
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'sections': sections,
      'prompts': prompts.map((p) => p.toFirestore()).toList(),
      'category': category,
      'isCustom': isCustom,
      'settings': settings,
    };
  }

  JournalTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? sections,
    List<JournalPrompt>? prompts,
    String? category,
    bool? isCustom,
    Map<String, dynamic>? settings,
  }) {
    return JournalTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      prompts: prompts ?? this.prompts,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    sections,
    prompts,
    category,
    isCustom,
    settings,
  ];
}

class JournalStats extends Equatable {
  final int totalEntries;
  final int totalWords;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> moodDistribution;
  final Map<String, int> categoryDistribution;
  final double averageWordsPerEntry;
  final int favoriteEntries;
  final DateTime lastEntryDate;
  final Map<String, int> weeklyEntries;

  const JournalStats({
    required this.totalEntries,
    required this.totalWords,
    required this.currentStreak,
    required this.longestStreak,
    required this.moodDistribution,
    required this.categoryDistribution,
    required this.averageWordsPerEntry,
    required this.favoriteEntries,
    required this.lastEntryDate,
    required this.weeklyEntries,
  });

  factory JournalStats.empty() {
    return JournalStats(
      totalEntries: 0,
      totalWords: 0,
      currentStreak: 0,
      longestStreak: 0,
      moodDistribution: const {},
      categoryDistribution: const {},
      averageWordsPerEntry: 0.0,
      favoriteEntries: 0,
      lastEntryDate: DateTime.now(),
      weeklyEntries: const {},
    );
  }

  static JournalStats get defaultStats => JournalStats(
    totalEntries: 0,
    totalWords: 0,
    currentStreak: 0,
    longestStreak: 0,
    moodDistribution: const {},
    categoryDistribution: const {},
    averageWordsPerEntry: 0.0,
    favoriteEntries: 0,
    lastEntryDate: DateTime.now(),
    weeklyEntries: const {},
  );

  @override
  List<Object?> get props => [
    totalEntries,
    totalWords,
    currentStreak,
    longestStreak,
    moodDistribution,
    categoryDistribution,
    averageWordsPerEntry,
    favoriteEntries,
    lastEntryDate,
    weeklyEntries,
  ];
}
