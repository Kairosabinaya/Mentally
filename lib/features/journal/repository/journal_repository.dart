import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/journal_model.dart';
import '../../../shared/models/mood_model.dart';

class JournalRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  JournalRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _moodsCollection =>
      _firestore.collection(AppConstants.moodsCollection);

  CollectionReference get _entriesCollection =>
      _userId != null
          ? _firestore
              .collection(AppConstants.usersCollection)
              .doc(_userId!)
              .collection(AppConstants.journalEntriesCollection)
          : _firestore.collection(AppConstants.journalEntriesCollection);

  CollectionReference get _promptsCollection =>
      _firestore.collection(AppConstants.journalPromptsCollection);

  CollectionReference get _templatesCollection =>
      _firestore.collection(AppConstants.journalTemplatesCollection);

  CollectionReference get _draftsCollection =>
      _firestore.collection(AppConstants.journalDraftsCollection);

  // Entry Management - Now fetches from mood collection
  Future<List<JournalEntry>> getEntries({
    String? category,
    String? mood,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    bool? favoritesOnly,
    DocumentSnapshot? lastDocument,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      Query query;

      // Use simple query to avoid index issues
      query = _moodsCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      var moodEntries =
          snapshot.docs.map((doc) => MoodModel.fromFirestore(doc)).toList();

      // Apply all filters in memory to avoid Firestore index requirements
      if (mood != null) {
        moodEntries =
            moodEntries
                .where((moodEntry) => moodEntry.moodType == mood)
                .toList();
      }

      if (startDate != null) {
        moodEntries =
            moodEntries
                .where(
                  (moodEntry) => moodEntry.createdAt.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ),
                )
                .toList();
      }

      if (endDate != null) {
        moodEntries =
            moodEntries
                .where(
                  (moodEntry) => moodEntry.createdAt.isBefore(
                    endDate.add(const Duration(days: 1)),
                  ),
                )
                .toList();
      }

      // Convert mood entries to journal entries
      return moodEntries
          .map((mood) => _convertMoodToJournalEntry(mood))
          .toList();
    } catch (e) {
      print('Error getting entries: $e');
      throw Exception('Failed to get entries: $e');
    }
  }

  // Convert MoodModel to JournalEntry for display
  JournalEntry _convertMoodToJournalEntry(MoodModel mood) {
    final content = _buildJournalContentFromMood(mood);
    final wordCount = _countWords(content);

    return JournalEntry(
      id: mood.id,
      userId: mood.userId,
      title: 'Mood Entry - ${_getMoodDisplayName(mood.moodType)}',
      content: content,
      mood: mood.moodType,
      moodIntensity: mood.intensity.toDouble(),
      tags: ['mood-tracking', ...mood.triggers],
      prompts: [],
      reflections: {
        'triggers': mood.triggers,
        'activities': mood.activities,
        'intensity': mood.intensity,
        'emoji': mood.emoji,
        'note': mood.note ?? '',
      },
      imageUrls: [],
      isPrivate: true,
      createdAt: mood.createdAt,
      updatedAt: mood.createdAt,
      wordCount: wordCount,
      category: 'mood',
      isFavorite: false,
      metadata: {'source': 'mood_tracker', 'moodId': mood.id},
    );
  }

  String _getMoodDisplayName(String moodType) {
    switch (moodType) {
      case 'very_happy':
        return 'Great';
      case 'happy':
        return 'Good';
      case 'neutral':
        return 'Okay';
      case 'sad':
        return 'Low';
      case 'very_sad':
        return 'Poor';
      default:
        return moodType
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) =>
                  word.isEmpty
                      ? word
                      : word[0].toUpperCase() + word.substring(1),
            )
            .join(' ');
    }
  }

  String _buildJournalContentFromMood(MoodModel mood) {
    final buffer = StringBuffer();

    // Main mood line
    buffer.writeln(
      'Today I\'m feeling ${_getMoodDisplayName(mood.moodType)} ${mood.emoji}',
    );

    // Show note if available (this should be the main content)
    if (mood.note != null && mood.note!.isNotEmpty) {
      buffer.writeln(mood.note);
    }

    // Add activities if available
    if (mood.activities.isNotEmpty) {
      buffer.writeln('\nActivities:');
      for (final activity in mood.activities) {
        buffer.writeln('• $activity');
      }
    }

    // Add triggers if available
    if (mood.triggers.isNotEmpty) {
      buffer.writeln('\nTriggers:');
      for (final trigger in mood.triggers) {
        buffer.writeln('• $trigger');
      }
    }

    return buffer.toString();
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  Future<JournalEntry> getEntry(String entryId) async {
    final doc = await _entriesCollection.doc(entryId).get();
    if (!doc.exists) {
      throw Exception('Entry not found');
    }
    return JournalEntry.fromFirestore(doc);
  }

  Future<JournalEntry> createEntry(JournalEntry entry) async {
    if (_userId == null) throw Exception('User not authenticated');

    final entryData = entry.copyWith(
      userId: _userId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      wordCount: _countWords(entry.content),
    );

    final docRef = await _entriesCollection.add(entryData.toFirestore());
    final doc = await docRef.get();

    // Update user points
    await _updateUserPoints(AppConstants.journalEntryPoints);

    return JournalEntry.fromFirestore(doc);
  }

  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    if (_userId == null) throw Exception('User not authenticated');

    final entryData = entry.copyWith(
      updatedAt: DateTime.now(),
      wordCount: _countWords(entry.content),
    );

    await _entriesCollection.doc(entry.id).update(entryData.toFirestore());
    final doc = await _entriesCollection.doc(entry.id).get();

    return JournalEntry.fromFirestore(doc);
  }

  Future<void> deleteEntry(String entryId) async {
    if (_userId == null) throw Exception('User not authenticated');

    // Delete associated images
    final entry = await getEntry(entryId);
    for (final imageUrl in entry.imageUrls) {
      await _deleteImage(imageUrl);
    }

    await _entriesCollection.doc(entryId).delete();
  }

  Future<void> toggleFavorite(String entryId, bool isFavorite) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _entriesCollection.doc(entryId).update({
      'isFavorite': isFavorite,
      'updatedAt': Timestamp.now(),
    });
  }

  // Search and Filter
  Future<List<JournalEntry>> searchEntries({
    required String query,
    List<String>? tags,
    String? category,
    String? mood,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    Query firestoreQuery = _firestore
        .collection(AppConstants.usersCollection)
        .doc(_userId!)
        .collection(AppConstants.journalEntriesCollection)
        .orderBy('createdAt', descending: true);

    // Apply only one filter at a time
    if (category != null) {
      firestoreQuery = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId!)
          .collection(AppConstants.journalEntriesCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true);
    } else if (mood != null) {
      firestoreQuery = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId!)
          .collection(AppConstants.journalEntriesCollection)
          .where('mood', isEqualTo: mood)
          .orderBy('createdAt', descending: true);
    } else if (tags != null && tags.isNotEmpty) {
      firestoreQuery = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId!)
          .collection(AppConstants.journalEntriesCollection)
          .where('tags', arrayContainsAny: tags)
          .orderBy('createdAt', descending: true);
    }

    final snapshot = await firestoreQuery.get();
    final entries =
        snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList();

    // Filter by text search (client-side)
    if (query.isNotEmpty) {
      final searchQuery = query.toLowerCase();
      return entries.where((entry) {
        return entry.title.toLowerCase().contains(searchQuery) ||
            entry.content.toLowerCase().contains(searchQuery) ||
            entry.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
    }

    return entries;
  }

  // Prompts
  Future<List<JournalPrompt>> getPrompts({
    String? category,
    String? difficulty,
    String? moodTarget,
    bool? dailyOnly,
  }) async {
    Query query = _promptsCollection;

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    if (moodTarget != null) {
      query = query.where('moodTarget', isEqualTo: moodTarget);
    }

    if (dailyOnly == true) {
      query = query.where('isDaily', isEqualTo: true);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => JournalPrompt.fromFirestore(doc))
        .toList();
  }

  Future<JournalPrompt?> getDailyPrompt() async {
    final prompts = await getPrompts(dailyOnly: true);
    if (prompts.isEmpty) return null;

    // Return a random daily prompt
    final today = DateTime.now();
    final seed = today.year * 1000 + today.month * 100 + today.day;
    final random = DateTime.now().millisecondsSinceEpoch % prompts.length;

    return prompts[random];
  }

  // Templates
  Future<List<JournalTemplate>> getTemplates({
    String? category,
    bool? customOnly,
  }) async {
    Query query = _templatesCollection;

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (customOnly == true) {
      query = query.where('isCustom', isEqualTo: true);
      if (_userId != null) {
        query = query.where('userId', isEqualTo: _userId);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => JournalTemplate.fromFirestore(doc))
        .toList();
  }

  Future<JournalTemplate> createTemplate(JournalTemplate template) async {
    if (_userId == null) throw Exception('User not authenticated');

    final templateData = template.copyWith(
      settings: {
        ...template.settings,
        'userId': _userId,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );

    final docRef = await _templatesCollection.add(templateData.toFirestore());
    final doc = await docRef.get();

    return JournalTemplate.fromFirestore(doc);
  }

  Future<JournalTemplate> updateTemplate(JournalTemplate template) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _templatesCollection.doc(template.id).update(template.toFirestore());
    final doc = await _templatesCollection.doc(template.id).get();

    return JournalTemplate.fromFirestore(doc);
  }

  Future<void> deleteTemplate(String templateId) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _templatesCollection.doc(templateId).delete();
  }

  // Statistics
  Future<JournalStats> getStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final entries = await getEntries(startDate: startDate, endDate: endDate);

    if (entries.isEmpty) {
      return JournalStats.empty();
    }

    final moodDistribution = <String, int>{};
    final categoryDistribution = <String, int>{};
    final weeklyEntries = <String, int>{};
    int totalWords = 0;
    int favoriteEntries = 0;

    for (final entry in entries) {
      // Mood distribution
      moodDistribution[entry.mood] = (moodDistribution[entry.mood] ?? 0) + 1;

      // Category distribution
      categoryDistribution[entry.category] =
          (categoryDistribution[entry.category] ?? 0) + 1;

      // Weekly entries
      final weekKey =
          '${entry.createdAt.year}-W${_getWeekNumber(entry.createdAt)}';
      weeklyEntries[weekKey] = (weeklyEntries[weekKey] ?? 0) + 1;

      // Total words
      totalWords += entry.wordCount;

      // Favorite entries
      if (entry.isFavorite) favoriteEntries++;
    }

    final currentStreak = _calculateStreak(entries);
    final longestStreak = _calculateLongestStreak(entries);

    return JournalStats(
      totalEntries: entries.length,
      totalWords: totalWords,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      moodDistribution: moodDistribution,
      categoryDistribution: categoryDistribution,
      averageWordsPerEntry: totalWords / entries.length,
      favoriteEntries: favoriteEntries,
      lastEntryDate: entries.first.createdAt,
      weeklyEntries: weeklyEntries,
    );
  }

  // Drafts
  Future<List<JournalEntry>> getDrafts() async {
    if (_userId == null) throw Exception('User not authenticated');

    final snapshot =
        await _draftsCollection
            .where('userId', isEqualTo: _userId)
            .orderBy('updatedAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList();
  }

  Future<JournalEntry> saveDraft(JournalEntry draft) async {
    if (_userId == null) throw Exception('User not authenticated');

    final draftData = draft.copyWith(
      userId: _userId!,
      updatedAt: DateTime.now(),
    );

    DocumentReference docRef;
    if (draft.id.isEmpty) {
      docRef = await _draftsCollection.add(draftData.toFirestore());
    } else {
      docRef = _draftsCollection.doc(draft.id);
      await docRef.update(draftData.toFirestore());
    }

    final doc = await docRef.get();
    return JournalEntry.fromFirestore(doc);
  }

  Future<void> deleteDraft(String draftId) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _draftsCollection.doc(draftId).delete();
  }

  // Images
  Future<String> uploadImage(File imageFile, String entryId) async {
    if (_userId == null) throw Exception('User not authenticated');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(
      'journal_images/$_userId/$entryId/$fileName',
    );

    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});

    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting images
    }
  }

  // Tags
  Future<List<String>> getAllTags() async {
    if (_userId == null) throw Exception('User not authenticated');

    final snapshot =
        await _entriesCollection.where('userId', isEqualTo: _userId).get();

    final tags = <String>{};
    for (final doc in snapshot.docs) {
      final entry = JournalEntry.fromFirestore(doc);
      tags.addAll(entry.tags);
    }

    return tags.toList()..sort();
  }

  Future<List<String>> getAllCategories() async {
    if (_userId == null) throw Exception('User not authenticated');

    final snapshot =
        await _entriesCollection.where('userId', isEqualTo: _userId).get();

    final categories = <String>{};
    for (final doc in snapshot.docs) {
      final entry = JournalEntry.fromFirestore(doc);
      categories.add(entry.category);
    }

    return categories.toList()..sort();
  }

  // Real-time streams
  Stream<List<JournalEntry>> getEntriesStream({
    String? category,
    String? mood,
    int? limit,
  }) {
    if (_userId == null) throw Exception('User not authenticated');

    Query query = _entriesCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (mood != null) {
      query = query.where('mood', isEqualTo: mood);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList(),
    );
  }

  Stream<JournalEntry> getEntryStream(String entryId) {
    return _entriesCollection.doc(entryId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Entry not found');
      return JournalEntry.fromFirestore(doc);
    });
  }

  // Helper methods
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  int _calculateStreak(List<JournalEntry> entries) {
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

  int _calculateLongestStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );

      if (lastDate == null) {
        lastDate = entryDate;
        currentStreak = 1;
      } else {
        final difference = entryDate.difference(lastDate).inDays;
        if (difference == 1) {
          currentStreak++;
          lastDate = entryDate;
        } else {
          longestStreak =
              currentStreak > longestStreak ? currentStreak : longestStreak;
          currentStreak = 1;
          lastDate = entryDate;
        }
      }
    }

    return currentStreak > longestStreak ? currentStreak : longestStreak;
  }

  Future<void> _updateUserPoints(int points) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .update({
            'points': FieldValue.increment(points),
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      // Ignore errors when updating points
    }
  }

  // Export functionality
  Future<String> exportEntries({
    required List<String> entryIds,
    required String format,
    bool includeImages = false,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final entries = <JournalEntry>[];
    for (final entryId in entryIds) {
      final entry = await getEntry(entryId);
      entries.add(entry);
    }

    switch (format.toLowerCase()) {
      case 'json':
        return _exportAsJson(entries);
      case 'txt':
        return _exportAsText(entries);
      case 'csv':
        return _exportAsCsv(entries);
      default:
        throw Exception('Unsupported export format: $format');
    }
  }

  String _exportAsJson(List<JournalEntry> entries) {
    final data = entries.map((entry) => entry.toFirestore()).toList();
    return data.toString(); // In a real app, use proper JSON encoding
  }

  String _exportAsText(List<JournalEntry> entries) {
    final buffer = StringBuffer();
    for (final entry in entries) {
      buffer.writeln('Title: ${entry.title}');
      buffer.writeln('Date: ${entry.createdAt}');
      buffer.writeln('Mood: ${entry.mood}');
      buffer.writeln('Category: ${entry.category}');
      buffer.writeln('Content:');
      buffer.writeln(entry.content);
      buffer.writeln('---');
      buffer.writeln();
    }
    return buffer.toString();
  }

  String _exportAsCsv(List<JournalEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('Title,Date,Mood,Category,Content,Tags');

    for (final entry in entries) {
      buffer.writeln(
        '"${entry.title}","${entry.createdAt}","${entry.mood}","${entry.category}","${entry.content}","${entry.tags.join(';')}"',
      );
    }

    return buffer.toString();
  }
}
