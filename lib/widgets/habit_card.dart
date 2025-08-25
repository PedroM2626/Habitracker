import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hbitolar/models/habit_model.dart';
import 'package:hbitolar/providers/auth_provider.dart';
import 'package:hbitolar/providers/habits_provider.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitsProvider, AuthProvider>(
      builder: (context, habitsProvider, authProvider, child) {
        final completion = habitsProvider.getTodayCompletion(habit.id);
        final progress = habitsProvider.getHabitProgress(habit.id);
        final streak = habitsProvider.getHabitStreak(habit.id);
        final isCompleted = habitsProvider.isHabitCompletedToday(habit.id);
        final completedCount = completion?.completedCount ?? 0;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            onTap: () => _showHabitDetails(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Emoji and Title
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(habit.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            habit.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (habit.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                habit.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Streak
                      if (streak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$streak',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$completedCount/${habit.targetCount} ${habit.unit}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCompleted 
                                    ? Theme.of(context).colorScheme.primary 
                                    : _getCategoryColor(habit.category),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (completedCount > 0)
                            IconButton(
                              onPressed: () => _updateHabitCount(context, habitsProvider, authProvider, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 24,
                            ),
                          IconButton(
                            onPressed: isCompleted 
                                ? null 
                                : () => _updateHabitCount(context, habitsProvider, authProvider, 1),
                            icon: Icon(
                              isCompleted ? Icons.check_circle : Icons.add_circle_outline,
                              color: isCompleted 
                                  ? Theme.of(context).colorScheme.primary 
                                  : null,
                            ),
                            iconSize: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateHabitCount(BuildContext context, HabitsProvider habitsProvider, 
      AuthProvider authProvider, int delta) async {
    if (authProvider.currentUser == null) return;

    final success = await habitsProvider.markHabitComplete(
      habit.id,
      authProvider.currentUser!.uid,
      delta,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(habitsProvider.error ?? 'Erro ao atualizar hábito')),
      );
    }
  }

  void _showHabitDetails(BuildContext context) {
    // TODO: Implement habit details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detalhes do hábito em breve!')),
    );
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Colors.green;
      case HabitCategory.study:
        return Colors.blue;
      case HabitCategory.work:
        return Colors.orange;
      case HabitCategory.fitness:
        return Colors.red;
      case HabitCategory.lifestyle:
        return Colors.purple;
      case HabitCategory.mindfulness:
        return Colors.teal;
      case HabitCategory.other:
        return Colors.grey;
    }
  }
}