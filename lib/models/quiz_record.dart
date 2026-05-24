class AnswerDetail {
  final int questionId;
  final List<String> userAnswer;
  final bool isCorrect;
  final String answeredAt;
  final int timeSpentSecs;

  AnswerDetail({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.answeredAt,
    required this.timeSpentSecs,
  });

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'answered_at': answeredAt,
        'time_spent_secs': timeSpentSecs,
      };

  factory AnswerDetail.fromJson(Map<String, dynamic> json) => AnswerDetail(
        questionId: json['question_id'] as int? ?? 0,
        userAnswer:
            (json['user_answer'] as List<dynamic>?)?.cast<String>() ?? [],
        isCorrect: json['is_correct'] as bool? ?? false,
        answeredAt: json['answered_at'] as String? ?? '',
        timeSpentSecs: json['time_spent_secs'] as int? ?? 0,
      );
}

class QuizRecord {
  final int id;
  final String subject;
  final String startedAt;
  final String? finishedAt;
  final int durationSecs;
  final int totalCount;
  final int correctCount;
  final int wrongCount;
  final double score;
  final List<AnswerDetail> details;

  QuizRecord({
    this.id = 0,
    this.subject = '',
    this.startedAt = '',
    this.finishedAt,
    this.durationSecs = 0,
    this.totalCount = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.score = 0.0,
    List<AnswerDetail>? details,
  }) : details = details ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'started_at': startedAt,
        'finished_at': finishedAt,
        'duration_secs': durationSecs,
        'total_count': totalCount,
        'correct_count': correctCount,
        'wrong_count': wrongCount,
        'score': score,
        'details': details.map((d) => d.toJson()).toList(),
      };

  factory QuizRecord.fromJson(Map<String, dynamic> json) => QuizRecord(
        id: json['id'] as int? ?? 0,
        subject: json['subject'] as String? ?? '',
        startedAt: json['started_at'] as String? ?? '',
        finishedAt: json['finished_at'] as String?,
        durationSecs: json['duration_secs'] as int? ?? 0,
        totalCount: json['total_count'] as int? ?? 0,
        correctCount: json['correct_count'] as int? ?? 0,
        wrongCount: json['wrong_count'] as int? ?? 0,
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
        details: (json['details'] as List<dynamic>?)
                ?.map((d) => AnswerDetail.fromJson(d as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class SubjectStats {
  final String subject;
  final int totalQuestions;
  final int totalPracticeCount;
  final int totalCorrect;
  final int totalWrong;
  final double avgScore;
  final int totalTimeSecs;

  SubjectStats({
    required this.subject,
    required this.totalQuestions,
    required this.totalPracticeCount,
    required this.totalCorrect,
    required this.totalWrong,
    required this.avgScore,
    required this.totalTimeSecs,
  });

  factory SubjectStats.fromJson(Map<String, dynamic> json) => SubjectStats(
        subject: json['subject'] as String? ?? '',
        totalQuestions: json['total_questions'] as int? ?? 0,
        totalPracticeCount: json['total_practice_count'] as int? ?? 0,
        totalCorrect: json['total_correct'] as int? ?? 0,
        totalWrong: json['total_wrong'] as int? ?? 0,
        avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
        totalTimeSecs: json['total_time_secs'] as int? ?? 0,
      );
}

class DailyStats {
  final String date;
  final int practiceCount;
  final int totalQuestions;
  final int correctCount;
  final int totalTimeSecs;

  DailyStats({
    required this.date,
    required this.practiceCount,
    required this.totalQuestions,
    required this.correctCount,
    required this.totalTimeSecs,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
        date: json['date'] as String? ?? '',
        practiceCount: json['practice_count'] as int? ?? 0,
        totalQuestions: json['total_questions'] as int? ?? 0,
        correctCount: json['correct_count'] as int? ?? 0,
        totalTimeSecs: json['total_time_secs'] as int? ?? 0,
      );
}

import 'question.dart';

class ImportExportData {
  final String version;
  final String exportedAt;
  final List<Question> questions;

  ImportExportData({
    this.version = '1.0',
    this.exportedAt = '',
    List<Question>? questions,
  }) : questions = questions ?? [];

  Map<String, dynamic> toJson() => {
        'version': version,
        'exported_at': exportedAt,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  factory ImportExportData.fromJson(Map<String, dynamic> json) =>
      ImportExportData(
        version: json['version'] as String? ?? '1.0',
        exportedAt: json['exported_at'] as String? ?? '',
        questions: (json['questions'] as List<dynamic>?)
                ?.map(
                    (q) => Question.fromJson(q as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
