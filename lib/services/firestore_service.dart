import 'package:hbitolar/models/habit_completion_model.dart';
import 'package:hbitolar/models/habit_model.dart';
import 'package:hbitolar/models/user_model.dart';
import 'package:hbitolar/repositories/user_repository.dart';
import 'package:hbitolar/repositories/habits_repository.dart';

class FirestoreService {

  final UserRepository _userRepository = UserRepository();
  final HabitsRepository _habitsRepository = HabitsRepository();

  // User operations - delegated to UserRepository
  Future<void> createUser(UserModel user) async {
    return _userRepository.createUser(user);
  }

  Future<UserModel?> getUser(String uid) async {
    return _userRepository.getUser(uid);
  }

  Future<void> updateUser(UserModel user) async {
    return _userRepository.updateUser(user);
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _userRepository.streamUser(uid);
  }

  // Habit operations - delegated to HabitsRepository
  Future<String> createHabit(HabitModel habit) async {
    return _habitsRepository.createHabit(habit);
  }

  Future<void> updateHabit(HabitModel habit) async {
    return _habitsRepository.updateHabit(habit);
  }

  Future<void> deleteHabit(String habitId) async {
    return _habitsRepository.deleteHabit(habitId);
  }

  Stream<List<HabitModel>> getUserHabits(String userId) {
    return _habitsRepository.streamUserHabits(userId);
  }

  Future<HabitModel?> getHabit(String habitId) async {
    return _habitsRepository.getHabit(habitId);
  }

  // Habit completion operations - enhanced with repository pattern
  Future<void> markHabitComplete(HabitCompletionModel completion) async {
    // Save the completion using repository
    await _habitsRepository.saveHabitCompletion(completion);
    
    // Update user XP using repository
    await _userRepository.updateUserXp(completion.userId, completion.xpEarned);
  }

  Future<void> updateHabitCompletion(HabitCompletionModel completion) async {
    await _habitsRepository.saveHabitCompletion(completion);
  }

  Future<HabitCompletionModel?> getHabitCompletion(String habitId, DateTime date) async {
    return _habitsRepository.getHabitCompletion(habitId, date);
  }

  Stream<List<HabitCompletionModel>> getUserHabitCompletions(String userId, DateTime startDate, DateTime endDate) async* {
    final completions = await _habitsRepository.getHabitCompletionsInRange(userId, startDate, endDate);
    yield completions;
  }

  Future<List<HabitCompletionModel>> getHabitCompletionsForRange(String habitId, DateTime startDate, DateTime endDate) async {
    return _habitsRepository.getHabitCompletionsInRangeByHabitId(habitId, startDate, endDate);
  }

  Future<int> getCurrentStreak(String habitId) async {
    return _habitsRepository.calculateHabitStreak(habitId);
  }

  // Additional convenience methods
  Future<List<HabitModel>> getHabitsByCategory(String userId, HabitCategory category) async {
    return _habitsRepository.getHabitsByCategory(userId, category);
  }
}