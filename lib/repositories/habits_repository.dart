import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hbitolar/models/habit_model.dart';
import 'package:hbitolar/models/habit_completion_model.dart';
import 'package:hbitolar/repositories/base_repository.dart';
import 'package:hbitolar/firestore/firestore_data_schema.dart';

class HabitsRepository extends BaseRepository {
  static const String _habitsCollection = FirestoreSchema.habitsCollection;
  static const String _completionsCollection = FirestoreSchema.habitCompletionsCollection;
  
  /// Create a new habit
  Future<String> createHabit(HabitModel habit) async {
    requireAuthentication();
    
    try {
      final docRef = await firestore.collection(_habitsCollection).add({
        HabitSchema.userId: habit.userId,
        HabitSchema.name: habit.name,
        HabitSchema.description: habit.description,
        HabitSchema.emoji: habit.emoji,
        HabitSchema.frequency: habit.frequency.toString().split('.').last,
        HabitSchema.category: habit.category.toString().split('.').last,
        HabitSchema.targetCount: habit.targetCount,
        HabitSchema.unit: habit.unit,
        HabitSchema.xpPerCompletion: habit.xpPerCompletion,
        HabitSchema.isActive: habit.isActive,
        HabitSchema.createdAt: dateTimeToTimestamp(habit.createdAt),
        HabitSchema.updatedAt: dateTimeToTimestamp(habit.updatedAt),
        HabitSchema.reminderTimes: habit.reminderTimes,
      });
      return docRef.id;
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Get user's habits with real-time updates
  Stream<List<HabitModel>> streamUserHabits(String userId) {
    return firestore
        .collection(_habitsCollection)
        .where(HabitSchema.userId, isEqualTo: userId)
        .where(HabitSchema.isActive, isEqualTo: true)
        .orderBy(HabitSchema.createdAt)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return HabitModel(
                id: doc.id,
                userId: data[HabitSchema.userId] ?? '',
                name: data[HabitSchema.name] ?? '',
                description: data[HabitSchema.description] ?? '',
                emoji: data[HabitSchema.emoji] ?? '⭐',
                frequency: HabitFrequency.values.firstWhere(
                  (e) => e.toString().split('.').last == data[HabitSchema.frequency],
                  orElse: () => HabitFrequency.daily,
                ),
                category: HabitCategory.values.firstWhere(
                  (e) => e.toString().split('.').last == data[HabitSchema.category],
                  orElse: () => HabitCategory.other,
                ),
                targetCount: data[HabitSchema.targetCount] ?? 1,
                unit: data[HabitSchema.unit] ?? 'times',
                xpPerCompletion: data[HabitSchema.xpPerCompletion] ?? 10,
                isActive: data[HabitSchema.isActive] ?? true,
                createdAt: timestampToDateTime(data[HabitSchema.createdAt]) ?? DateTime.now(),
                updatedAt: timestampToDateTime(data[HabitSchema.updatedAt]) ?? DateTime.now(),
                reminderTimes: List<String>.from(data[HabitSchema.reminderTimes] ?? []),
              );
            }).toList());
  }
  
  /// Get a specific habit
  Future<HabitModel?> getHabit(String habitId) async {
    try {
      final doc = await firestore.collection(_habitsCollection).doc(habitId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return HabitModel(
        id: doc.id,
        userId: data[HabitSchema.userId] ?? '',
        name: data[HabitSchema.name] ?? '',
        description: data[HabitSchema.description] ?? '',
        emoji: data[HabitSchema.emoji] ?? '⭐',
        frequency: HabitFrequency.values.firstWhere(
          (e) => e.toString().split('.').last == data[HabitSchema.frequency],
          orElse: () => HabitFrequency.daily,
        ),
        category: HabitCategory.values.firstWhere(
          (e) => e.toString().split('.').last == data[HabitSchema.category],
          orElse: () => HabitCategory.other,
        ),
        targetCount: data[HabitSchema.targetCount] ?? 1,
        unit: data[HabitSchema.unit] ?? 'times',
        xpPerCompletion: data[HabitSchema.xpPerCompletion] ?? 10,
        isActive: data[HabitSchema.isActive] ?? true,
        createdAt: timestampToDateTime(data[HabitSchema.createdAt]) ?? DateTime.now(),
        updatedAt: timestampToDateTime(data[HabitSchema.updatedAt]) ?? DateTime.now(),
        reminderTimes: List<String>.from(data[HabitSchema.reminderTimes] ?? []),
      );
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Update a habit
  Future<void> updateHabit(HabitModel habit) async {
    requireAuthentication();
    
    try {
      await firestore.collection(_habitsCollection).doc(habit.id).update({
        HabitSchema.name: habit.name,
        HabitSchema.description: habit.description,
        HabitSchema.emoji: habit.emoji,
        HabitSchema.frequency: habit.frequency.toString().split('.').last,
        HabitSchema.category: habit.category.toString().split('.').last,
        HabitSchema.targetCount: habit.targetCount,
        HabitSchema.unit: habit.unit,
        HabitSchema.xpPerCompletion: habit.xpPerCompletion,
        HabitSchema.isActive: habit.isActive,
        HabitSchema.updatedAt: dateTimeToTimestamp(habit.updatedAt),
        HabitSchema.reminderTimes: habit.reminderTimes,
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Delete a habit (soft delete - mark as inactive)
  Future<void> deleteHabit(String habitId) async {
    requireAuthentication();
    
    try {
      await firestore.collection(_habitsCollection).doc(habitId).update({
        HabitSchema.isActive: false,
        HabitSchema.updatedAt: dateTimeToTimestamp(DateTime.now()),
      });
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Create or update habit completion
  Future<void> saveHabitCompletion(HabitCompletionModel completion) async {
    requireAuthentication();
    
    try {
      final dateKey = completion.date.toIso8601String().split('T')[0];
      final docId = '${completion.habitId}_$dateKey';
      
      await firestore.collection(_completionsCollection).doc(docId).set({
        HabitCompletionSchema.habitId: completion.habitId,
        HabitCompletionSchema.userId: completion.userId,
        HabitCompletionSchema.date: dateKey,
        HabitCompletionSchema.completedCount: completion.completedCount,
        HabitCompletionSchema.targetCount: completion.targetCount,
        HabitCompletionSchema.xpEarned: completion.xpEarned,
        HabitCompletionSchema.completedAt: dateTimeToTimestamp(completion.completedAt),
      }, SetOptions(merge: true));
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Get habit completion for a specific date
  Future<HabitCompletionModel?> getHabitCompletion(String habitId, DateTime date) async {
    try {
      final dateKey = date.toIso8601String().split('T')[0];
      final docId = '${habitId}_$dateKey';
      
      final doc = await firestore.collection(_completionsCollection).doc(docId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return HabitCompletionModel(
        id: doc.id,
        habitId: data[HabitCompletionSchema.habitId] ?? '',
        userId: data[HabitCompletionSchema.userId] ?? '',
        date: DateTime.parse(data[HabitCompletionSchema.date]),
        completedCount: data[HabitCompletionSchema.completedCount] ?? 0,
        targetCount: data[HabitCompletionSchema.targetCount] ?? 1,
        xpEarned: data[HabitCompletionSchema.xpEarned] ?? 0,
        completedAt: timestampToDateTime(data[HabitCompletionSchema.completedAt]) ?? DateTime.now(),
      );
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Get habit completions for a date range by userId
  Future<List<HabitCompletionModel>> getHabitCompletionsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateKey = startDate.toIso8601String().split('T')[0];
      final endDateKey = endDate.toIso8601String().split('T')[0];
      
      final snapshot = await firestore
          .collection(_completionsCollection)
          .where(HabitCompletionSchema.userId, isEqualTo: userId)
          .where(HabitCompletionSchema.date, isGreaterThanOrEqualTo: startDateKey)
          .where(HabitCompletionSchema.date, isLessThanOrEqualTo: endDateKey)
          .limit(100)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HabitCompletionModel(
          id: doc.id,
          habitId: data[HabitCompletionSchema.habitId] ?? '',
          userId: data[HabitCompletionSchema.userId] ?? '',
          date: DateTime.parse(data[HabitCompletionSchema.date]),
          completedCount: data[HabitCompletionSchema.completedCount] ?? 0,
          targetCount: data[HabitCompletionSchema.targetCount] ?? 1,
          xpEarned: data[HabitCompletionSchema.xpEarned] ?? 0,
          completedAt: timestampToDateTime(data[HabitCompletionSchema.completedAt]) ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Get habit completions for a date range by habitId
  Future<List<HabitCompletionModel>> getHabitCompletionsInRangeByHabitId(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateKey = startDate.toIso8601String().split('T')[0];
      final endDateKey = endDate.toIso8601String().split('T')[0];
      
      final snapshot = await firestore
          .collection(_completionsCollection)
          .where(HabitCompletionSchema.habitId, isEqualTo: habitId)
          .where(HabitCompletionSchema.date, isGreaterThanOrEqualTo: startDateKey)
          .where(HabitCompletionSchema.date, isLessThanOrEqualTo: endDateKey)
          .limit(100)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HabitCompletionModel(
          id: doc.id,
          habitId: data[HabitCompletionSchema.habitId] ?? '',
          userId: data[HabitCompletionSchema.userId] ?? '',
          date: DateTime.parse(data[HabitCompletionSchema.date]),
          completedCount: data[HabitCompletionSchema.completedCount] ?? 0,
          targetCount: data[HabitCompletionSchema.targetCount] ?? 1,
          xpEarned: data[HabitCompletionSchema.xpEarned] ?? 0,
          completedAt: timestampToDateTime(data[HabitCompletionSchema.completedAt]) ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Calculate current streak for a habit
  Future<int> calculateHabitStreak(String habitId) async {
    try {
      final today = DateTime.now();
      int streak = 0;
      
      for (int i = 0; i < 365; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final completion = await getHabitCompletion(habitId, checkDate);
        
        if (completion != null && completion.isCompleted) {
          streak++;
        } else if (i > 0) {
          // Don't break on first day (today) if not completed yet
          break;
        }
      }
      
      return streak;
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
  
  /// Get habits by category
  Future<List<HabitModel>> getHabitsByCategory(String userId, HabitCategory category) async {
    try {
      final snapshot = await firestore
          .collection(_habitsCollection)
          .where(HabitSchema.userId, isEqualTo: userId)
          .where(HabitSchema.isActive, isEqualTo: true)
          .where(HabitSchema.category, isEqualTo: category.toString().split('.').last)
          .orderBy(HabitSchema.createdAt)
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HabitModel(
          id: doc.id,
          userId: data[HabitSchema.userId] ?? '',
          name: data[HabitSchema.name] ?? '',
          description: data[HabitSchema.description] ?? '',
          emoji: data[HabitSchema.emoji] ?? '⭐',
          frequency: HabitFrequency.values.firstWhere(
            (e) => e.toString().split('.').last == data[HabitSchema.frequency],
            orElse: () => HabitFrequency.daily,
          ),
          category: HabitCategory.values.firstWhere(
            (e) => e.toString().split('.').last == data[HabitSchema.category],
            orElse: () => HabitCategory.other,
          ),
          targetCount: data[HabitSchema.targetCount] ?? 1,
          unit: data[HabitSchema.unit] ?? 'times',
          xpPerCompletion: data[HabitSchema.xpPerCompletion] ?? 10,
          isActive: data[HabitSchema.isActive] ?? true,
          createdAt: timestampToDateTime(data[HabitSchema.createdAt]) ?? DateTime.now(),
          updatedAt: timestampToDateTime(data[HabitSchema.updatedAt]) ?? DateTime.now(),
          reminderTimes: List<String>.from(data[HabitSchema.reminderTimes] ?? []),
        );
      }).toList();
    } catch (e) {
      throw handleFirestoreError(e);
    }
  }
}