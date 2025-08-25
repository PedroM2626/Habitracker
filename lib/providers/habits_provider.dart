import 'package:flutter/material.dart';
import 'package:hbitolar/models/habit_completion_model.dart';
import 'package:hbitolar/models/habit_model.dart';
import 'package:hbitolar/services/firestore_service.dart';

class HabitsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<HabitModel> _habits = [];
  Map<String, HabitCompletionModel> _todayCompletions = {};
  Map<String, int> _streaks = {};
  bool _isLoading = false;
  String? _error;

  List<HabitModel> get habits => _habits;
  Map<String, HabitCompletionModel> get todayCompletions => _todayCompletions;
  Map<String, int> get streaks => _streaks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserHabits(String userId) async {
    _setLoading(true);
    
    try {
      _firestoreService.getUserHabits(userId).listen((habits) {
        _habits = habits;
        _loadTodayCompletions(userId);
        _loadStreaks();
        notifyListeners();
      });
    } catch (e) {
      _setError('Erro ao carregar hábitos: $e');
    }
  }

  Future<void> _loadTodayCompletions(String userId) async {
    final today = DateTime.now();
    
    for (final habit in _habits) {
      final completion = await _firestoreService.getHabitCompletion(habit.id, today);
      if (completion != null) {
        _todayCompletions[habit.id] = completion;
      } else {
        _todayCompletions.remove(habit.id);
      }
    }
  }

  Future<void> _loadStreaks() async {
    for (final habit in _habits) {
      final streak = await _firestoreService.getCurrentStreak(habit.id);
      _streaks[habit.id] = streak;
    }
  }

  Future<bool> createHabit(HabitModel habit) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _firestoreService.createHabit(habit);
      return true;
    } catch (e) {
      _setError('Erro ao criar hábito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateHabit(HabitModel habit) async {
    try {
      await _firestoreService.updateHabit(habit);
      return true;
    } catch (e) {
      _setError('Erro ao atualizar hábito: $e');
      return false;
    }
  }

  Future<bool> deleteHabit(String habitId) async {
    try {
      await _firestoreService.deleteHabit(habitId);
      return true;
    } catch (e) {
      _setError('Erro ao deletar hábito: $e');
      return false;
    }
  }

  Future<bool> markHabitComplete(String habitId, String userId, int count) async {
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final today = DateTime.now();
      
      final existingCompletion = _todayCompletions[habitId];
      final currentCount = existingCompletion?.completedCount ?? 0;
      final newCount = (currentCount + count).clamp(0, habit.targetCount);
      
      final completion = HabitCompletionModel(
        id: '${habitId}_${today.toIso8601String().split('T')[0]}',
        habitId: habitId,
        userId: userId,
        date: today,
        completedCount: newCount,
        targetCount: habit.targetCount,
        xpEarned: (newCount > currentCount) ? habit.xpPerCompletion : 0,
        completedAt: DateTime.now(),
      );

      if (existingCompletion != null) {
        await _firestoreService.updateHabitCompletion(completion);
      } else {
        await _firestoreService.markHabitComplete(completion);
      }

      _todayCompletions[habitId] = completion;
      
      // Update streak
      _streaks[habitId] = await _firestoreService.getCurrentStreak(habitId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro ao marcar hábito como completo: $e');
      return false;
    }
  }

  HabitCompletionModel? getTodayCompletion(String habitId) {
    return _todayCompletions[habitId];
  }

  bool isHabitCompletedToday(String habitId) {
    final completion = _todayCompletions[habitId];
    return completion?.isCompleted ?? false;
  }

  double getHabitProgress(String habitId) {
    final completion = _todayCompletions[habitId];
    return completion?.completionPercentage ?? 0.0;
  }

  int getHabitStreak(String habitId) {
    return _streaks[habitId] ?? 0;
  }

  List<HabitModel> getHabitsByCategory(HabitCategory category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}