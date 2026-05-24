import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import '../models/question.dart';
import '../models/quiz_record.dart';

typedef InitDatabaseC = Int32 Function(Pointer<Utf8>);
typedef InitDatabaseD = int Function(Pointer<Utf8>);

typedef AddQuestionC = Int64 Function(Pointer<Utf8>);
typedef AddQuestionD = int Function(Pointer<Utf8>);

typedef UpdateQuestionC = Int32 Function(Pointer<Utf8>);
typedef UpdateQuestionD = int Function(Pointer<Utf8>);

typedef DeleteQuestionC = Int32 Function(Int64);
typedef DeleteQuestionD = int Function(int);

typedef GetQuestionC = Pointer<Utf8> Function(Int64);
typedef GetQuestionD = Pointer<Utf8> Function(int);

typedef GetAllQuestionsC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef GetAllQuestionsD = Pointer<Utf8> Function(Pointer<Utf8>);

typedef GetSubjectsC = Pointer<Utf8> Function();
typedef GetSubjectsD = Pointer<Utf8> Function();

typedef StartQuizC = Int32 Function(Pointer<Utf8>);
typedef StartQuizD = int Function(Pointer<Utf8>);

typedef GetCurrentQuestionC = Pointer<Utf8> Function();
typedef GetCurrentQuestionD = Pointer<Utf8> Function();

typedef AnswerQuestionC = Int32 Function(Pointer<Utf8>, Int64);
typedef AnswerQuestionD = int Function(Pointer<Utf8>, int);

typedef GetQuizProgressC = Pointer<Utf8> Function();
typedef GetQuizProgressD = Pointer<Utf8> Function();

typedef FinishQuizC = Pointer<Utf8> Function();
typedef FinishQuizD = Pointer<Utf8> Function();

typedef IsQuizActiveC = Int32 Function();
typedef IsQuizActiveD = int Function();

typedef GetRecordsC = Pointer<Utf8> Function(Int32);
typedef GetRecordsD = Pointer<Utf8> Function(int);

typedef GetSubjectStatsC = Pointer<Utf8> Function();
typedef GetSubjectStatsD = Pointer<Utf8> Function();

typedef GetDailyStatsC = Pointer<Utf8> Function(Int32);
typedef GetDailyStatsD = Pointer<Utf8> Function(int);

typedef GetSettingC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef GetSettingD = Pointer<Utf8> Function(Pointer<Utf8>);

typedef SetSettingC = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef SetSettingD = int Function(Pointer<Utf8>, Pointer<Utf8>);

typedef ImportQuestionsC = Int32 Function(Pointer<Utf8>);
typedef ImportQuestionsD = int Function(Pointer<Utf8>);

typedef ExportQuestionsC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef ExportQuestionsD = Pointer<Utf8> Function(Pointer<Utf8>);

typedef FreeStringC = Void Function(Pointer<Utf8>);
typedef FreeStringD = void Function(Pointer<Utf8>);

class NativeBridge {
  static NativeBridge? _instance;
  late final DynamicLibrary _lib;
  late final InitDatabaseD _initDb;
  late final AddQuestionD _addQuestion;
  late final UpdateQuestionD _updateQuestion;
  late final DeleteQuestionD _deleteQuestion;
  late final GetQuestionD _getQuestion;
  late final GetAllQuestionsD _getAllQuestions;
  late final GetSubjectsD _getSubjects;
  late final StartQuizD _startQuiz;
  late final GetCurrentQuestionD _getCurrentQuestion;
  late final AnswerQuestionD _answerQuestion;
  late final GetQuizProgressD _getQuizProgress;
  late final FinishQuizD _finishQuiz;
  late final IsQuizActiveD _isQuizActive;
  late final GetRecordsD _getRecords;
  late final GetSubjectStatsD _getSubjectStats;
  late final GetDailyStatsD _getDailyStats;
  late final GetSettingD _getSetting;
  late final SetSettingD _setSetting;
  late final ImportQuestionsD _importQuestions;
  late final ExportQuestionsD _exportQuestions;
  late final FreeStringD _freeString;

  NativeBridge._() {
    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('libquiz_core.so');
    } else if (Platform.isIOS) {
      _lib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      _lib = DynamicLibrary.open('quiz_core.dll');
    } else if (Platform.isMacOS) {
      _lib = DynamicLibrary.open('libquiz_core.dylib');
    } else if (Platform.isLinux) {
      _lib = DynamicLibrary.open('libquiz_core.so');
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    _initDb = _lib.lookupFunction<InitDatabaseC, InitDatabaseD>('init_database');
    _addQuestion = _lib.lookupFunction<AddQuestionC, AddQuestionD>('add_question');
    _updateQuestion = _lib.lookupFunction<UpdateQuestionC, UpdateQuestionD>('update_question');
    _deleteQuestion = _lib.lookupFunction<DeleteQuestionC, DeleteQuestionD>('delete_question');
    _getQuestion = _lib.lookupFunction<GetQuestionC, GetQuestionD>('get_question');
    _getAllQuestions = _lib.lookupFunction<GetAllQuestionsC, GetAllQuestionsD>('get_all_questions');
    _getSubjects = _lib.lookupFunction<GetSubjectsC, GetSubjectsD>('get_subjects');
    _startQuiz = _lib.lookupFunction<StartQuizC, StartQuizD>('start_quiz');
    _getCurrentQuestion = _lib.lookupFunction<GetCurrentQuestionC, GetCurrentQuestionD>('get_current_question');
    _answerQuestion = _lib.lookupFunction<AnswerQuestionC, AnswerQuestionD>('answer_question');
    _getQuizProgress = _lib.lookupFunction<GetQuizProgressC, GetQuizProgressD>('get_quiz_progress');
    _finishQuiz = _lib.lookupFunction<FinishQuizC, FinishQuizD>('finish_quiz');
    _isQuizActive = _lib.lookupFunction<IsQuizActiveC, IsQuizActiveD>('is_quiz_active');
    _getRecords = _lib.lookupFunction<GetRecordsC, GetRecordsD>('get_records');
    _getSubjectStats = _lib.lookupFunction<GetSubjectStatsC, GetSubjectStatsD>('get_subject_stats');
    _getDailyStats = _lib.lookupFunction<GetDailyStatsC, GetDailyStatsD>('get_daily_stats');
    _getSetting = _lib.lookupFunction<GetSettingC, GetSettingD>('get_setting');
    _setSetting = _lib.lookupFunction<SetSettingC, SetSettingD>('set_setting');
    _importQuestions = _lib.lookupFunction<ImportQuestionsC, ImportQuestionsD>('import_questions');
    _exportQuestions = _lib.lookupFunction<ExportQuestionsC, ExportQuestionsD>('export_questions');
    _freeString = _lib.lookupFunction<FreeStringC, FreeStringD>('free_string');
  }

  static Future<NativeBridge> get instance async {
    if (_instance == null) {
      _instance = NativeBridge._();
      final dir = await getApplicationDocumentsDirectory();
      _instance!._withUtf8('${dir.path}/quiz_app.db', (ptr) {
        _instance!._initDb(ptr);
        return 0;
      });
    }
    return _instance!;
  }

  String? _readAndFree(Pointer<Utf8>? ptr) {
    if (ptr == nullptr) return null;
    final result = ptr!.toDartString();
    _freeString(ptr);
    return result;
  }

  T _withUtf8<T>(String s, T Function(Pointer<Utf8>) fn) {
    final ptr = s.toNativeUtf8();
    try {
      return fn(ptr);
    } finally {
      malloc.free(ptr);
    }
  }

  // --- Question CRUD ---
  int addQuestion(Question q) {
    return _withUtf8(jsonEncode(q.toJson()), _addQuestion);
  }

  bool updateQuestion(Question q) {
    return _withUtf8(jsonEncode(q.toJson()), (p) => _updateQuestion(p) == 0);
  }

  bool deleteQuestion(int id) {
    return _deleteQuestion(id) == 0;
  }

  Question? getQuestion(int id) {
    final ptr = _getQuestion(id);
    final json = _readAndFree(ptr);
    if (json == null) return null;
    return Question.fromJson(jsonDecode(json));
  }

  List<Question> getAllQuestions({String? subject}) {
    return _withUtf8(subject ?? '', (ptr) {
      final result = _getAllQuestions(ptr);
      final json = _readAndFree(result);
      if (json == null) return <Question>[];
      final list = jsonDecode(json) as List;
      return list.map((e) => Question.fromJson(e)).toList();
    });
  }

  List<String> getSubjects() {
    final ptr = _getSubjects();
    final json = _readAndFree(ptr);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<String>();
  }

  // --- Quiz ---
  bool startQuiz(String subject) {
    return _withUtf8(subject, (ptr) => _startQuiz(ptr) == 0);
  }

  Question? getCurrentQuestion() {
    final ptr = _getCurrentQuestion();
    final json = _readAndFree(ptr);
    if (json == null) return null;
    return Question.fromJson(jsonDecode(json));
  }

  bool answerQuestion(List<String> answers, int timeSpentSecs) {
    return _withUtf8(jsonEncode(answers), (ptr) => _answerQuestion(ptr, timeSpentSecs) == 0);
  }

  Map<String, int> getQuizProgress() {
    final ptr = _getQuizProgress();
    final json = _readAndFree(ptr);
    if (json == null) return {'current': 0, 'total': 0};
    final m = jsonDecode(json) as Map;
    return {'current': m['current'] as int, 'total': m['total'] as int};
  }

  QuizRecord? finishQuiz() {
    final ptr = _finishQuiz();
    final json = _readAndFree(ptr);
    if (json == null) return null;
    return QuizRecord.fromJson(jsonDecode(json));
  }

  bool isQuizActive() {
    return _isQuizActive() == 1;
  }

  // --- Records ---
  List<QuizRecord> getRecords(int limit) {
    final ptr = _getRecords(limit);
    final json = _readAndFree(ptr);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => QuizRecord.fromJson(e)).toList();
  }

  List<SubjectStats> getSubjectStats() {
    final ptr = _getSubjectStats();
    final json = _readAndFree(ptr);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => SubjectStats.fromJson(e)).toList();
  }

  List<DailyStats> getDailyStats(int days) {
    final ptr = _getDailyStats(days);
    final json = _readAndFree(ptr);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => DailyStats.fromJson(e)).toList();
  }

  // --- Settings ---
  String? getSetting(String key) {
    return _withUtf8(key, (ptr) {
      final result = _getSetting(ptr);
      return _readAndFree(result);
    });
  }

  bool setSetting(String key, String value) {
    return _withUtf8(key, (keyPtr) {
      return _withUtf8(value, (valPtr) => _setSetting(keyPtr, valPtr) == 0);
    });
  }

  // --- Import/Export ---
  int importQuestions(String json) {
    return _withUtf8(json, _importQuestions);
  }

  String? exportQuestions(String subject) {
    return _withUtf8(subject, (ptr) {
      final result = _exportQuestions(ptr);
      return _readAndFree(result);
    });
  }
}
