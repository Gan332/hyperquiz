import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_provider.dart';
import 'models/question.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appProvider = AppProvider();
  await appProvider.loadTheme();

  // Seed some sample questions for first launch
  _seedSampleData(appProvider);

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const QuizApp(),
    ),
  );
}

void _seedSampleData(AppProvider app) {
  if (app.questions.isNotEmpty) return;

  final now = DateTime.now().toIso8601String();
  final samples = [
    Question(
      id: 1,
      subject: 'Math',
      questionType: QuestionType.singleChoice,
      content: 'What is the value of π (pi) approximately?',
      options: ['2.14', '3.14', '4.14', '5.14'],
      answer: ['3.14'],
      explanation: 'π ≈ 3.141592653589793...',
      tags: ['geometry', 'constants'],
      createdAt: now,
      updatedAt: now,
    ),
    Question(
      id: 2,
      subject: 'Math',
      questionType: QuestionType.multipleChoice,
      content: 'Which of the following are prime numbers?',
      options: ['2', '4', '7', '9'],
      answer: ['2', '7'],
      explanation: 'Prime numbers have exactly two factors: 1 and themselves. 2 and 7 are prime.',
      tags: ['number theory'],
      createdAt: now,
      updatedAt: now,
    ),
    Question(
      id: 3,
      subject: 'Physics',
      questionType: QuestionType.singleChoice,
      content: 'What is the SI unit of force?',
      options: ['Newton', 'Joule', 'Watt', 'Pascal'],
      answer: ['Newton'],
      explanation: 'The newton (N) is the SI unit of force.',
      tags: ['mechanics', 'units'],
      createdAt: now,
      updatedAt: now,
    ),
    Question(
      id: 4,
      subject: 'Physics',
      questionType: QuestionType.trueFalse,
      content: 'The speed of light in a vacuum is approximately 3 × 10⁸ m/s.',
      options: ['True', 'False'],
      answer: ['True'],
      explanation: 'The speed of light c = 299,792,458 m/s ≈ 3 × 10⁸ m/s.',
      tags: ['optics', 'constants'],
      createdAt: now,
      updatedAt: now,
    ),
    Question(
      id: 5,
      subject: 'Chemistry',
      questionType: QuestionType.fillBlank,
      content: 'The chemical symbol for water is ____.',
      options: [],
      answer: ['H2O'],
      explanation: 'Water consists of two hydrogen atoms and one oxygen atom.',
      tags: ['basic', 'molecules'],
      createdAt: now,
      updatedAt: now,
    ),
    Question(
      id: 6,
      subject: 'History',
      questionType: QuestionType.singleChoice,
      content: 'In which year did World War II end?',
      options: ['1943', '1944', '1945', '1946'],
      answer: ['1945'],
      explanation: 'World War II ended in 1945 with the surrender of Germany and Japan.',
      tags: ['modern history', 'wars'],
      createdAt: now,
      updatedAt: now,
    ),
  ];

  for (final q in samples) {
    app.addQuestion(q);
  }
}
