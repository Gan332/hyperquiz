enum QuestionType { singleChoice, multipleChoice, trueFalse, fillBlank }

class Question {
  final int id;
  final String subject;
  final QuestionType questionType;
  final String content;
  final List<String> options;
  final List<String> answer;
  final String explanation;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  Question({
    this.id = 0,
    this.subject = '',
    this.questionType = QuestionType.singleChoice,
    this.content = '',
    List<String>? options,
    List<String>? answer,
    this.explanation = '',
    List<String>? tags,
    String? createdAt,
    String? updatedAt,
  })  : options = options ?? [],
        answer = answer ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  Question copyWith({
    int? id,
    String? subject,
    QuestionType? questionType,
    String? content,
    List<String>? options,
    List<String>? answer,
    String? explanation,
    List<String>? tags,
    String? createdAt,
    String? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      questionType: questionType ?? this.questionType,
      content: content ?? this.content,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'question_type': _typeToJson(questionType),
        'content': content,
        'options': options,
        'answer': answer,
        'explanation': explanation,
        'tags': tags,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  static String _typeToJson(QuestionType t) {
    switch (t) {
      case QuestionType.singleChoice:
        return 'SingleChoice';
      case QuestionType.multipleChoice:
        return 'MultipleChoice';
      case QuestionType.trueFalse:
        return 'TrueFalse';
      case QuestionType.fillBlank:
        return 'FillBlank';
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as int? ?? 0,
        subject: json['subject'] as String? ?? '',
        questionType: _parseType(json['question_type'] as String? ?? ''),
        content: json['content'] as String? ?? '',
        options: (json['options'] as List<dynamic>?)?.cast<String>() ?? [],
        answer: (json['answer'] as List<dynamic>?)?.cast<String>() ?? [],
        explanation: json['explanation'] as String? ?? '',
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  static QuestionType _parseType(String t) {
    switch (t) {
      case 'SingleChoice':
        return QuestionType.singleChoice;
      case 'MultipleChoice':
        return QuestionType.multipleChoice;
      case 'TrueFalse':
        return QuestionType.trueFalse;
      case 'FillBlank':
        return QuestionType.fillBlank;
      default:
        return QuestionType.singleChoice;
    }
  }
}
