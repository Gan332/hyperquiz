import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/quiz_record.dart';

class AppProvider extends ChangeNotifier {
  int _nextId = 100;

  // Theme settings
  Color _themeColor = const Color(0xFF6750A4);
  bool _darkMode = false;
  bool _enableTimer = true;
  String _defaultSubject = '';

  // Data
  List<Question> _questions = [];
  List<String> _subjects = [];
  List<QuizRecord> _records = [];
  List<SubjectStats> _subjectStats = [];
  List<DailyStats> _dailyStats = [];

  // Quiz state
  bool _isQuizActive = false;
  Question? _currentQuestion;
  int _quizCurrent = 0;
  int _quizTotal = 0;
  int _quizTimeSpent = 0;
  List<String> _selectedAnswers = [];

  // Getters
  Color get themeColor => _themeColor;
  bool get darkMode => _darkMode;
  bool get enableTimer => _enableTimer;
  String get defaultSubject => _defaultSubject;

  List<Question> get questions => _questions;
  List<String> get subjects => _subjects;
  List<QuizRecord> get records => _records;
  List<SubjectStats> get subjectStats => _subjectStats;
  List<DailyStats> get dailyStats => _dailyStats;

  bool get isQuizActive => _isQuizActive;
  Question? get currentQuestion => _currentQuestion;
  int get quizCurrent => _quizCurrent;
  int get quizTotal => _quizTotal;
  int get quizTimeSpent => _quizTimeSpent;
  List<String> get selectedAnswers => _selectedAnswers;

  // Theme
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorStr = prefs.getString('theme_color') ?? '#6750A4';
    _themeColor = _parseColor(colorStr);
    _darkMode = prefs.getBool('dark_mode') ?? false;
    _enableTimer = prefs.getBool('enable_timer') ?? true;
    _defaultSubject = prefs.getString('default_subject') ?? '';
    notifyListeners();
  }

  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_color', _colorToHex(color));
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }

  Future<void> setEnableTimer(bool value) async {
    _enableTimer = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_timer', value);
    notifyListeners();
  }

  Future<void> setDefaultSubject(String value) async {
    _defaultSubject = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_subject', value);
    notifyListeners();
  }

  // Data helpers (will be backed by Rust native calls in production)
  void loadQuestions(List<Question> questions) {
    _questions = questions;
    notifyListeners();
  }

  void addQuestion(Question q) {
    final newQ = q.id == 0 ? q.copyWith(id: _nextId++) : q;
    _questions.insert(0, newQ);
    notifyListeners();
  }

  void updateQuestion(Question q) {
    final idx = _questions.indexWhere((e) => e.id == q.id);
    if (idx != -1) {
      _questions[idx] = q;
      notifyListeners();
    }
  }

  void removeQuestion(int id) {
    _questions.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addQuestions(Iterable<Question> questions) {
    for (final q in questions) {
      _questions.insert(0, q.id == 0 ? q.copyWith(id: _nextId++) : q);
    }
    notifyListeners();
  }

  void loadSubjects(List<String> subjects) {
    _subjects = subjects;
    notifyListeners();
  }

  // Quiz
  void startQuiz(List<Question> questions) {
    _isQuizActive = true;
    _quizCurrent = 0;
    _quizTotal = questions.length;
    _quizTimeSpent = 0;
    _selectedAnswers = [];
    _currentQuestion = questions.isNotEmpty ? questions[0] : null;
    notifyListeners();
  }

  void answerCurrent() {
    _quizCurrent++;
    _selectedAnswers = [];
    notifyListeners();
  }

  void setCurrentQuestion(Question? q) {
    _currentQuestion = q;
    notifyListeners();
  }

  void setSelectedAnswers(List<String> answers) {
    _selectedAnswers = answers;
    notifyListeners();
  }

  void endQuiz() {
    _isQuizActive = false;
    _currentQuestion = null;
    _quizCurrent = 0;
    _quizTotal = 0;
    _selectedAnswers = [];
    notifyListeners();
  }

  void setQuizTimeSpent(int secs) {
    _quizTimeSpent = secs;
    notifyListeners();
  }

  // Records
  void loadRecords(List<QuizRecord> records) {
    _records = records;
    notifyListeners();
  }

  void loadSubjectStats(List<SubjectStats> stats) {
    _subjectStats = stats;
    notifyListeners();
  }

  void loadDailyStats(List<DailyStats> stats) {
    _dailyStats = stats;
    notifyListeners();
  }

  // Helpers
  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
}
