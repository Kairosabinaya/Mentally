import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/models.dart';
import '../../../shared/models/journal_model.dart';

abstract class MoodRepository {
  Future<MoodModel> logMood({
    required String moodType,
    required String emoji,
    required int intensity,
    String? note,
    required List<String> triggers,
    required List<String> activities,
  });

  Future<List<MoodModel>> getMoodHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<List<MoodModel>> getTodayMoods();
  Future<List<MoodModel>> getWeeklyMoods();
  Future<List<MoodModel>> getMonthlyMoods();

  Future<Map<String, dynamic>> getMoodAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void> updateMood(MoodModel mood);
  Future<void> deleteMood(String moodId);

  Stream<List<MoodModel>> moodStream();
}

class MoodRepositoryImpl implements MoodRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  MoodRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  String get _userId {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  CollectionReference get _moodsCollection =>
      _firestore.collection(AppConstants.moodsCollection);

  @override
  Future<MoodModel> logMood({
    required String moodType,
    required String emoji,
    required int intensity,
    String? note,
    required List<String> triggers,
    required List<String> activities,
  }) async {
    try {
      final now = DateTime.now();
      final moodModel = MoodModel(
        id: '',
        userId: _userId,
        moodType: moodType,
        emoji: emoji,
        note: note,
        intensity: intensity,
        createdAt: now,
        triggers: triggers,
        activities: activities,
        pointsEarned: AppConstants.moodEntryPoints,
        metadata: {},
      );

      final docRef = await _moodsCollection.add(moodModel.toFirestore());

      // Update user points
      await _updateUserPoints(AppConstants.moodEntryPoints);

      return moodModel.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to log mood: $e');
    }
  }

  @override
  Future<List<MoodModel>> getMoodHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _moodsCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => MoodModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get mood history: $e');
    }
  }

  @override
  Future<List<MoodModel>> getTodayMoods() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return getMoodHistory(startDate: startOfDay, endDate: endOfDay);
  }

  @override
  Future<List<MoodModel>> getWeeklyMoods() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return getMoodHistory(startDate: startOfWeekDay, endDate: now);
  }

  @override
  Future<List<MoodModel>> getMonthlyMoods() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return getMoodHistory(startDate: startOfMonth, endDate: now);
  }

  @override
  Future<Map<String, dynamic>> getMoodAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final moods = await getMoodHistory(
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate mood counts
      final moodCounts = <String, int>{};
      final intensitySum = <String, double>{};
      final intensityCount = <String, int>{};
      final allTriggers = <String>[];
      final allActivities = <String>[];

      for (final mood in moods) {
        // Count moods
        moodCounts[mood.moodType] = (moodCounts[mood.moodType] ?? 0) + 1;

        // Calculate average intensity
        intensitySum[mood.moodType] =
            (intensitySum[mood.moodType] ?? 0) + mood.intensity;
        intensityCount[mood.moodType] =
            (intensityCount[mood.moodType] ?? 0) + 1;

        // Collect triggers and activities
        allTriggers.addAll(mood.triggers);
        allActivities.addAll(mood.activities);
      }

      // Calculate average intensity per mood type
      final averageIntensity = <String, double>{};
      for (final moodType in intensitySum.keys) {
        averageIntensity[moodType] =
            intensitySum[moodType]! / intensityCount[moodType]!;
      }

      // Find common triggers and activities
      final triggerCounts = <String, int>{};
      final activityCounts = <String, int>{};

      for (final trigger in allTriggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }

      for (final activity in allActivities) {
        activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
      }

      // Sort and get top triggers/activities
      final commonTriggers = triggerCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final commonActivities = activityCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Calculate overall average
      final totalIntensity = moods.fold(0, (sum, mood) => sum + mood.intensity);
      final overallAverage = moods.isNotEmpty
          ? totalIntensity / moods.length
          : 0.0;

      // Calculate weekly trends (simplified)
      final weeklyTrends = <String, int>{};
      for (final mood in moods) {
        final weekKey =
            '${mood.createdAt.year}-W${_getWeekOfYear(mood.createdAt)}';
        weeklyTrends[weekKey] = (weeklyTrends[weekKey] ?? 0) + 1;
      }

      return {
        'moodCounts': moodCounts,
        'averageIntensity': averageIntensity,
        'commonTriggers': commonTriggers.take(10).map((e) => e.key).toList(),
        'commonActivities': commonActivities
            .take(10)
            .map((e) => e.key)
            .toList(),
        'overallAverage': overallAverage,
        'weeklyTrends': weeklyTrends,
      };
    } catch (e) {
      throw Exception('Failed to get mood analytics: $e');
    }
  }

  @override
  Future<void> updateMood(MoodModel mood) async {
    try {
      await _moodsCollection.doc(mood.id).update(mood.toFirestore());
    } catch (e) {
      throw Exception('Failed to update mood: $e');
    }
  }

  @override
  Future<void> deleteMood(String moodId) async {
    try {
      await _moodsCollection.doc(moodId).delete();
    } catch (e) {
      throw Exception('Failed to delete mood: $e');
    }
  }

  @override
  Stream<List<MoodModel>> moodStream() {
    return _moodsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => MoodModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> _updateUserPoints(int points) async {
    try {
      final userDoc = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId);

      await userDoc.update({
        'points': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't throw - points update is not critical
      print('Failed to update user points: $e');
    }
  }

  int _getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.weekday;
    final daysInFirstWeek = 8 - firstMonday;
    final diff = date.difference(startOfYear).inDays;

    if (diff < daysInFirstWeek) {
      return 1;
    } else {
      return ((diff - daysInFirstWeek) / 7).floor() + 2;
    }
  }
}
