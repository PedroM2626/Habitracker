enum HabitFrequency { daily, weekly, custom }

enum HabitCategory { health, study, work, fitness, lifestyle, mindfulness, other }

class HabitModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String emoji;
  final HabitFrequency frequency;
  final HabitCategory category;
  final int targetCount;
  final String unit;
  final int xpPerCompletion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> reminderTimes;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.emoji,
    required this.frequency,
    required this.category,
    required this.targetCount,
    required this.unit,
    this.xpPerCompletion = 10,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.reminderTimes = const [],
  });

  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '⭐',
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.toString().split('.').last == map['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      category: HabitCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => HabitCategory.other,
      ),
      targetCount: map['targetCount'] ?? 1,
      unit: map['unit'] ?? 'times',
      xpPerCompletion: map['xpPerCompletion'] ?? 10,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'emoji': emoji,
      'frequency': frequency.toString().split('.').last,
      'category': category.toString().split('.').last,
      'targetCount': targetCount,
      'unit': unit,
      'xpPerCompletion': xpPerCompletion,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reminderTimes': reminderTimes,
    };
  }

  HabitModel copyWith({
    String? name,
    String? description,
    String? emoji,
    HabitFrequency? frequency,
    HabitCategory? category,
    int? targetCount,
    String? unit,
    int? xpPerCompletion,
    bool? isActive,
    DateTime? updatedAt,
    List<String>? reminderTimes,
  }) {
    return HabitModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      targetCount: targetCount ?? this.targetCount,
      unit: unit ?? this.unit,
      xpPerCompletion: xpPerCompletion ?? this.xpPerCompletion,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }
}