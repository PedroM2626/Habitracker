/// Firestore Data Schema for Habitracker
/// 
/// This file documents the structure of collections and documents in Firestore
/// for the Habitracker application.
library;

class FirestoreSchema {
  // Collection names
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String habitCompletionsCollection = 'habit_completions';
  static const String achievementsCollection = 'achievements';
  static const String userStatsCollection = 'user_stats';
  static const String leaderboardsCollection = 'leaderboards';
  static const String appMetadataCollection = 'app_metadata';
}

/// Users Collection Schema
/// Collection: users
/// Document ID: {userId} (Firebase Auth UID)
class UserSchema {
  /// User's email address
  static const String email = 'email';
  
  /// User's display name
  static const String name = 'name';
  
  /// Optional user biography/description
  static const String bio = 'bio';
  
  /// URL to user's profile photo in Firebase Storage
  static const String photoUrl = 'photoUrl';
  
  /// Total XP points earned by the user
  static const String totalXp = 'totalXp';
  
  /// Current level based on XP
  static const String level = 'level';
  
  /// Account creation timestamp
  static const String createdAt = 'createdAt';
  
  /// Last profile update timestamp
  static const String updatedAt = 'updatedAt';
  
  /// User preferences/settings
  static const String preferences = 'preferences';
  
  /// User's current streak count
  static const String currentStreak = 'currentStreak';
  
  /// User's longest streak count
  static const String longestStreak = 'longestStreak';
}

/// Habits Collection Schema
/// Collection: habits
/// Document ID: auto-generated
class HabitSchema {
  /// Owner user ID (Firebase Auth UID)
  static const String userId = 'userId';
  
  /// Habit name/title
  static const String name = 'name';
  
  /// Habit description
  static const String description = 'description';
  
  /// Emoji icon for the habit
  static const String emoji = 'emoji';
  
  /// Habit frequency: 'daily', 'weekly', 'custom'
  static const String frequency = 'frequency';
  
  /// Habit category: 'health', 'study', 'work', 'fitness', 'lifestyle', 'mindfulness', 'other'
  static const String category = 'category';
  
  /// Target count per day/period
  static const String targetCount = 'targetCount';
  
  /// Unit of measurement (e.g., 'times', 'minutes', 'pages')
  static const String unit = 'unit';
  
  /// XP points earned per completion
  static const String xpPerCompletion = 'xpPerCompletion';
  
  /// Whether the habit is currently active
  static const String isActive = 'isActive';
  
  /// Habit creation timestamp
  static const String createdAt = 'createdAt';
  
  /// Last habit update timestamp
  static const String updatedAt = 'updatedAt';
  
  /// Reminder times (array of time strings)
  static const String reminderTimes = 'reminderTimes';
  
  /// Color theme for the habit
  static const String colorTheme = 'colorTheme';
  
  /// Custom goal/target for the habit
  static const String customGoal = 'customGoal';
}

/// Habit Completions Collection Schema
/// Collection: habit_completions
/// Document ID: {habitId}_{date} (e.g., "abc123_2024-01-15")
class HabitCompletionSchema {
  /// Reference to the habit document ID
  static const String habitId = 'habitId';
  
  /// Owner user ID (Firebase Auth UID)
  static const String userId = 'userId';
  
  /// Date of completion (YYYY-MM-DD format)
  static const String date = 'date';
  
  /// Number of times completed on this date
  static const String completedCount = 'completedCount';
  
  /// Target count for this date
  static const String targetCount = 'targetCount';
  
  /// XP points earned for this completion
  static const String xpEarned = 'xpEarned';
  
  /// Timestamp when the completion was marked
  static const String completedAt = 'completedAt';
  
  /// Optional notes about the completion
  static const String notes = 'notes';
  
  /// Mood or rating (1-5 scale) for the completion
  static const String mood = 'mood';
}

/// Achievements Collection Schema
/// Collection: achievements
/// Document ID: auto-generated
class AchievementSchema {
  /// Owner user ID (Firebase Auth UID)
  static const String userId = 'userId';
  
  /// Achievement type (e.g., 'streak', 'total_completions', 'level_up')
  static const String type = 'type';
  
  /// Achievement title
  static const String title = 'title';
  
  /// Achievement description
  static const String description = 'description';
  
  /// Achievement icon/badge
  static const String icon = 'icon';
  
  /// Achievement category
  static const String category = 'category';
  
  /// Requirement value (e.g., streak days, XP points)
  static const String requirementValue = 'requirementValue';
  
  /// Current progress towards achievement
  static const String currentValue = 'currentValue';
  
  /// Whether the achievement is unlocked
  static const String isUnlocked = 'isUnlocked';
  
  /// Timestamp when unlocked
  static const String unlockedAt = 'unlockedAt';
  
  /// XP bonus for unlocking this achievement
  static const String xpBonus = 'xpBonus';
}

/// User Statistics Collection Schema
/// Collection: user_stats
/// Document ID: {userId}_{period} (e.g., "user123_2024-01")
class UserStatsSchema {
  /// Owner user ID (Firebase Auth UID)
  static const String userId = 'userId';
  
  /// Stats period ('daily', 'weekly', 'monthly', 'yearly')
  static const String period = 'period';
  
  /// Date/period identifier
  static const String periodDate = 'periodDate';
  
  /// Total habits completed in period
  static const String habitsCompleted = 'habitsCompleted';
  
  /// Total XP earned in period
  static const String xpEarned = 'xpEarned';
  
  /// Completion rate percentage
  static const String completionRate = 'completionRate';
  
  /// Streak count at end of period
  static const String streakCount = 'streakCount';
  
  /// Most completed habit category
  static const String topCategory = 'topCategory';
  
  /// Stats calculation timestamp
  static const String calculatedAt = 'calculatedAt';
}

/// Leaderboards Collection Schema
/// Collection: leaderboards
/// Document ID: {type}_{period} (e.g., "xp_weekly", "streaks_monthly")
class LeaderboardSchema {
  /// Leaderboard type ('xp', 'streaks', 'completions')
  static const String type = 'type';
  
  /// Leaderboard period ('weekly', 'monthly', 'all_time')
  static const String period = 'period';
  
  /// Period start date
  static const String startDate = 'startDate';
  
  /// Period end date
  static const String endDate = 'endDate';
  
  /// Array of top users with their scores
  static const String topUsers = 'topUsers';
  
  /// Last update timestamp
  static const String updatedAt = 'updatedAt';
  
  /// Whether leaderboard is active
  static const String isActive = 'isActive';
}

/// App Metadata Collection Schema
/// Collection: app_metadata
/// Document ID: specific metadata type
class AppMetadataSchema {
  /// App version information
  static const String appVersion = 'appVersion';
  
  /// Feature flags for A/B testing
  static const String featureFlags = 'featureFlags';
  
  /// Motivational quotes
  static const String motivationalQuotes = 'motivationalQuotes';
  
  /// Achievement definitions
  static const String achievementDefinitions = 'achievementDefinitions';
  
  /// Default habit templates
  static const String habitTemplates = 'habitTemplates';
  
  /// Last update timestamp
  static const String updatedAt = 'updatedAt';
}

/// Query Examples and Patterns
/// 
/// Common queries used in the application:
/// 
/// 1. Get user's active habits:
/// firestore.collection('habits')
///   .where('userId', isEqualTo: currentUserId)
///   .where('isActive', isEqualTo: true)
///   .orderBy('createdAt')
/// 
/// 2. Get habit completions for date range:
/// firestore.collection('habit_completions')
///   .where('userId', isEqualTo: currentUserId)
///   .where('date', isGreaterThanOrEqualTo: startDate)
///   .where('date', isLessThanOrEqualTo: endDate)
/// 
/// 3. Get user's achievements:
/// firestore.collection('achievements')
///   .where('userId', isEqualTo: currentUserId)
///   .orderBy('unlockedAt', descending: true)
/// 
/// 4. Get habits by category:
/// firestore.collection('habits')
///   .where('userId', isEqualTo: currentUserId)
///   .where('category', isEqualTo: selectedCategory)
///   .orderBy('createdAt')
