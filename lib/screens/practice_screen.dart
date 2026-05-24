import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/quiz_record.dart' as model;
import '../providers/app_provider.dart';
import '../widgets/animations.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<Question> _sessionQuestions = [];
  int _currentIndex = 0;
  List<String> _selectedAnswers = [];
  Map<int, List<String>> _userAnswers = {};
  Map<int, int> _timePerQuestion = {};
  DateTime? _questionStartTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _showResult = false;
  int _correctCount = 0;
  bool _answered = false;

  // For fill-blank
  final TextEditingController _fillCtrl = TextEditingController();
  // For multi-select
  Set<int> _multiSelected = {};

  @override
  void dispose() {
    _timer?.cancel();
    _fillCtrl.dispose();
    super.dispose();
  }

  void _startSession() {
    final app = context.read<AppProvider>();
    if (app.questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions available. Add some first!')),
      );
      return;
    }

    final shuffled = List<Question>.from(app.questions)..shuffle();
    setState(() {
      _sessionQuestions = shuffled;
      _currentIndex = 0;
      _selectedAnswers = [];
      _userAnswers = {};
      _timePerQuestion = {};
      _showResult = false;
      _correctCount = 0;
      _answered = false;
      _elapsedSeconds = 0;
      _multiSelected = {};
      _questionStartTime = DateTime.now();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!context.read<AppProvider>().enableTimer) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  Question? get _currentQ =>
      _currentIndex < _sessionQuestions.length ? _sessionQuestions[_currentIndex] : null;

  bool get _isLast => _currentIndex >= _sessionQuestions.length - 1;

  void _submitAnswer() {
    if (_answered) return;
    final q = _currentQ;
    if (q == null) return;

    final timeSpent = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inSeconds
        : 0;

    List<String> answer;
    switch (q.questionType) {
      case QuestionType.singleChoice:
        answer = _selectedAnswers;
      case QuestionType.multipleChoice:
        answer = _multiSelected.map((i) => q.options[i]).toList();
      case QuestionType.trueFalse:
        answer = _selectedAnswers;
      case QuestionType.fillBlank:
        answer = [_fillCtrl.text.trim()];
    }

    setState(() {
      _answered = true;
      _userAnswers[_currentIndex] = answer;
      _timePerQuestion[_currentIndex] = timeSpent;

      // Check correctness (sorted comparison for multi-choice)
      final correct = List<String>.from(q.answer)..sort();
      final user = List<String>.from(answer)..sort();
      if (user.join() == correct.join()) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_isLast) {
      _finishSession();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswers = [];
      _multiSelected = {};
      _fillCtrl.clear();
      _answered = false;
      _questionStartTime = DateTime.now();
    });
  }

  void _finishSession() {
    _timer?.cancel();
    setState(() => _showResult = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_sessionQuestions.isEmpty && !_showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text(
                'Ready to practice?',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${context.watch<AppProvider>().questions.length} questions available',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _startSession,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Practice'),
              ),
            ],
          ),
        ),
      );
    }

    if (_showResult) {
      return _buildResultScreen(theme);
    }

    final q = _currentQ;
    if (q == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: const Center(child: Text('No questions')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_sessionQuestions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Animated progress bar
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: (_currentIndex + 1) / _sessionQuestions.length,
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
              );
            },
          ),
          // Timer
          if (context.watch<AppProvider>().enableTimer)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              child: Text(
                _formatTime(_elapsedSeconds),
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Content with slide animation
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: SingleChildScrollView(
                key: ValueKey('q_${q.id}_$_currentIndex'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject & type badge
                    Row(
                      children: [
                        if (q.subject.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(q.subject, style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _typeLabel(q.questionType),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Question
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          q.content,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Answers
                    ..._buildAnswerOptions(q, theme),
                    if (_answered && q.explanation.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.explanation,
                                  style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Bottom bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_answered)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _nextQuestion,
                        icon: Icon(_isLast ? Icons.check : Icons.arrow_forward),
                        label: Text(_isLast ? 'Finish' : 'Next'),
                      ),
                    )
                  else
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submitAnswer,
                        icon: const Icon(Icons.check),
                        label: const Text('Submit'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerOptions(Question q, ThemeData theme) {
    switch (q.questionType) {
      case QuestionType.singleChoice:
        return q.options.asMap().entries.map((e) {
          final isSelected = _selectedAnswers.contains(e.value);
          Color? bgColor;
          if (_answered) {
            if (q.answer.contains(e.value)) {
              bgColor = Colors.green[50];
            } else if (isSelected) {
              bgColor = Colors.red[50];
            }
          }
          return Card(
            color: bgColor,
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              title: Text(e.value),
              value: e.value,
              groupValue: _selectedAnswers.isNotEmpty ? _selectedAnswers[0] : null,
              onChanged: _answered ? null : (v) => setState(() => _selectedAnswers = v != null ? [v] : []),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList();

      case QuestionType.multipleChoice:
        return q.options.asMap().entries.map((e) {
          final isSelected = _multiSelected.contains(e.key);
          Color? bgColor;
          if (_answered) {
            if (q.answer.contains(e.value)) {
              bgColor = Colors.green[50];
            } else if (isSelected) {
              bgColor = Colors.red[50];
            }
          }
          return Card(
            color: bgColor,
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              title: Text(e.value),
              value: isSelected,
              onChanged: _answered ? null : (v) {
                setState(() {
                  if (v == true) {
                    _multiSelected.add(e.key);
                  } else {
                    _multiSelected.remove(e.key);
                  }
                });
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList();

      case QuestionType.trueFalse:
        return ['True', 'False'].map((v) {
          final isSelected = _selectedAnswers.contains(v);
          Color? bgColor;
          if (_answered) {
            if (q.answer.contains(v)) {
              bgColor = Colors.green[50];
            } else if (isSelected) {
              bgColor = Colors.red[50];
            }
          }
          return Card(
            color: bgColor,
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              title: Text(v),
              value: v,
              groupValue: _selectedAnswers.isNotEmpty ? _selectedAnswers[0] : null,
              onChanged: _answered ? null : (v) => setState(() => _selectedAnswers = v != null ? [v] : []),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList();

      case QuestionType.fillBlank:
        return [
          TextField(
            controller: _fillCtrl,
            decoration: const InputDecoration(
              hintText: 'Type your answer here...',
            ),
            enabled: !_answered,
            maxLines: 3,
            minLines: 1,
          ),
        ];
    }
  }

  Widget _buildResultScreen(ThemeData theme) {
    final total = _sessionQuestions.length;
    final score = total > 0 ? (_correctCount / total * 100) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScoreRing(score: score),
              const SizedBox(height: 24),
              Text(
                score >= 80
                    ? 'Excellent!'
                    : score >= 60
                        ? 'Good Job!'
                        : 'Keep Practicing!',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ResultStat(label: 'Correct', value: '$_correctCount', color: Colors.green),
                  const SizedBox(width: 32),
                  _ResultStat(
                    label: 'Wrong',
                    value: '${total - _correctCount}',
                    color: Colors.red,
                  ),
                  const SizedBox(width: 32),
                  _ResultStat(
                    label: 'Time',
                    value: _formatTime(_elapsedSeconds),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ScaleOnTap(
                onTap: () {
                  setState(() {
                    _sessionQuestions = [];
                    _showResult = false;
                  });
                },
                child: FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.replay),
                  label: const Text('Practice Again'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _typeLabel(QuestionType t) {
    switch (t) {
      case QuestionType.singleChoice:
        return 'Single Choice';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fillBlank:
        return 'Fill Blank';
    }
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}
