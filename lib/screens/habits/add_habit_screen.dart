import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hbitolar/models/habit_model.dart';
import 'package:hbitolar/providers/auth_provider.dart';
import 'package:hbitolar/providers/habits_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'vez');

  String _selectedEmoji = '⭐';
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  HabitCategory _selectedCategory = HabitCategory.other;

  final List<String> _popularEmojis = [
    '⭐', '💪', '📚', '🏃‍♀️', '🧘‍♀️', '💧', '🥗', '🏋️‍♂️', 
    '😊', '🎯', '✅', '🔥', '💡', '🎨', '🌱', '⏰', '📝', '🎵'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final habitsProvider = context.read<HabitsProvider>();

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: usuário não autenticado')),
      );
      return;
    }

    final habit = HabitModel(
      id: '',
      userId: authProvider.currentUser!.uid,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      emoji: _selectedEmoji,
      frequency: _selectedFrequency,
      category: _selectedCategory,
      targetCount: int.parse(_targetController.text),
      unit: _unitController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await habitsProvider.createHabit(habit);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hábito criado com sucesso!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(habitsProvider.error ?? 'Erro ao criar hábito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Novo Hábito',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Consumer<HabitsProvider>(
                    builder: (context, habitsProvider, child) {
                      return TextButton(
                        onPressed: habitsProvider.isLoading ? null : _saveHabit,
                        child: habitsProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Salvar'),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji Selection
                      Text(
                        'Ícone',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _popularEmojis.map((emoji) {
                              final isSelected = emoji == _selectedEmoji;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedEmoji = emoji),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected 
                                        ? Border.all(color: Theme.of(context).colorScheme.primary)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Name
                      Text(
                        'Nome do Hábito',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Beber água, Exercitar-se...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite o nome do hábito';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Description
                      Text(
                        'Descrição (opcional)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Descreva seu hábito...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Category
                      Text(
                        'Categoria',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<HabitCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: HabitCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryName(category)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value!),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Target and Unit
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meta Diária',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _targetController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Digite a meta';
                                    }
                                    final number = int.tryParse(value);
                                    if (number == null || number <= 0) {
                                      return 'Número inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unidade',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _unitController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Digite a unidade';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Frequency
                      Text(
                        'Frequência',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<HabitFrequency>(
                        value: _selectedFrequency,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: HabitFrequency.values.map((frequency) {
                          return DropdownMenuItem(
                            value: frequency,
                            child: Text(_getFrequencyName(frequency)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedFrequency = value!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return 'Saúde';
      case HabitCategory.study:
        return 'Estudos';
      case HabitCategory.work:
        return 'Trabalho';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.lifestyle:
        return 'Estilo de Vida';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.other:
        return 'Outros';
    }
  }

  String _getFrequencyName(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Diário';
      case HabitFrequency.weekly:
        return 'Semanal';
      case HabitFrequency.custom:
        return 'Personalizado';
    }
  }
}