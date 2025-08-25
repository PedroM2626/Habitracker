class HabitCompletionModel {
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  final int completedCount;
  final int targetCount;
  final int xpEarned;
  final DateTime completedAt;

  HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.completedCount,
    required this.targetCount,
    required this.xpEarned,
    required this.completedAt,
  });

  factory HabitCompletionModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitCompletionModel(
      id: id,
      habitId: map['habitId'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date']),
      completedCount: map['completedCount'] ?? 0,
      targetCount: map['targetCount'] ?? 1,
      xpEarned: map['xpEarned'] ?? 0,
      completedAt: DateTime.parse(map['completedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'userId': userId,
      'date': date.toIso8601String().split('T')[0],
      'completedCount': completedCount,
      'targetCount': targetCount,
      'xpEarned': xpEarned,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  bool get isCompleted => completedCount >= targetCount;

  double get completionPercentage => 
      targetCount > 0 ? (completedCount / targetCount).clamp(0.0, 1.0) : 0.0;

  HabitCompletionModel copyWith({
    int? completedCount,
    int? xpEarned,
    DateTime? completedAt,
  }) {
    return HabitCompletionModel(
      id: id,
      habitId: habitId,
      userId: userId,
      date: date,
      completedCount: completedCount ?? this.completedCount,
      targetCount: targetCount,
      xpEarned: xpEarned ?? this.xpEarned,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}