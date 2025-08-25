import 'package:hbitolar/models/habit_model.dart';

class SampleData {
  static List<HabitModel> getSampleHabits(String userId) {
    return [
      HabitModel(
        id: 'sample_1',
        userId: userId,
        name: 'Beber água',
        description: 'Beber pelo menos 2L de água por dia',
        emoji: '💧',
        frequency: HabitFrequency.daily,
        category: HabitCategory.health,
        targetCount: 8,
        unit: 'copos',
        xpPerCompletion: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      HabitModel(
        id: 'sample_2',
        userId: userId,
        name: 'Exercitar-se',
        description: 'Fazer pelo menos 30 minutos de atividade física',
        emoji: '🏃‍♀️',
        frequency: HabitFrequency.daily,
        category: HabitCategory.fitness,
        targetCount: 1,
        unit: 'sessão',
        xpPerCompletion: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HabitModel(
        id: 'sample_3',
        userId: userId,
        name: 'Ler',
        description: 'Ler pelo menos 30 páginas por dia',
        emoji: '📚',
        frequency: HabitFrequency.daily,
        category: HabitCategory.study,
        targetCount: 30,
        unit: 'páginas',
        xpPerCompletion: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      HabitModel(
        id: 'sample_4',
        userId: userId,
        name: 'Meditar',
        description: 'Praticar mindfulness e meditação',
        emoji: '🧘‍♀️',
        frequency: HabitFrequency.daily,
        category: HabitCategory.mindfulness,
        targetCount: 1,
        unit: 'sessão',
        xpPerCompletion: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HabitModel(
        id: 'sample_5',
        userId: userId,
        name: 'Estudar Flutter',
        description: 'Dedicar tempo ao aprendizado de Flutter',
        emoji: '💻',
        frequency: HabitFrequency.daily,
        category: HabitCategory.study,
        targetCount: 2,
        unit: 'horas',
        xpPerCompletion: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static const List<String> motivationalQuotes = [
    "Um hábito não pode ser jogado pela janela; deve ser coaxado pelas escadas, um degrau de cada vez. - Mark Twain",
    "Somos o que repetidamente fazemos. A excelência, então, não é um ato, mas um hábito. - Aristóteles",
    "O segredo para mudar sua vida é focar toda a sua energia não em lutar contra o velho, mas em construir o novo. - Sócrates",
    "Pequenos passos diários levam a grandes mudanças anuais.",
    "A motivação é o que te faz começar. O hábito é o que te mantém indo.",
    "Você não precisa ser perfeito, apenas consistente.",
    "Todo progresso acontece fora da zona de conforto.",
    "O melhor momento para começar foi ontem. O segundo melhor momento é agora.",
  ];

  static String getRandomMotivationalQuote() {
    final random = DateTime.now().millisecondsSinceEpoch % motivationalQuotes.length;
    return motivationalQuotes[random];
  }
}