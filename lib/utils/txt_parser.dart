import '../models/question.dart';

class TxtParserResult {
  final List<Question> questions;
  final int parsed;
  final int skipped;
  final List<String> errors;

  TxtParserResult({
    required this.questions,
    required this.parsed,
    required this.skipped,
    required this.errors,
  });
}

class TxtParser {
  static TxtParserResult parse(String text) {
    final questions = <Question>[];
    final errors = <String>[];
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      Question? q;

      q = _parseQaFormat(line, lines, i);
      if (q != null) {
        questions.add(q);
        i += _qaLineCount(line, lines, i);
        continue;
      }

      q = _parseTabDelimited(line);
      if (q != null) {
        questions.add(q);
        i++;
        continue;
      }

      q = _parseInlineBracket(line);
      if (q != null) {
        questions.add(q);
        i++;
        continue;
      }

      q = _parsePipeDelimited(line);
      if (q != null) {
        questions.add(q);
        i++;
        continue;
      }

      if (q == null) {
        errors.add('Skipped line ${i + 1}: "$line"');
      }
      i++;
    }

    return TxtParserResult(
      questions: questions,
      parsed: questions.length,
      skipped: errors.length,
      errors: errors,
    );
  }

  static int _qaLineCount(String line, List<String> lines, int i) {
    if (RegExp(r'^[QAqa][:\s]').hasMatch(line)) return 1;
    int count = 1;
    if (i + 1 < lines.length && !RegExp(r'^[QA].*?[:\s]').hasMatch(lines[i + 1])) {
      count++;
    }
    if (count == 2 && i + 2 < lines.length && RegExp(r'^[Oo]ption').hasMatch(lines[i + 2])) {
      count++;
    }
    return count;
  }

  static Question? _parseQaFormat(String line, List<String> lines, int i) {
    final qMatch = RegExp(r'^[Qq][:\s]+(.+)$').firstMatch(line);
    if (qMatch == null) return null;

    final content = qMatch.group(1)!.trim();
    if (content.isEmpty) return null;

    String answer = '';
    String explanation = '';
    String subject = '';
    List<String> options = [];

    int j = i + 1;
    while (j < lines.length) {
      final next = lines[j];

      final aMatch = RegExp(r'^[Aa][:\s]+(.+)$').firstMatch(next);
      if (aMatch != null) {
        answer = aMatch.group(1)!.trim();
        j++;
        continue;
      }

      final eMatch = RegExp(r'^[Ee][:\s]+(.+)$').firstMatch(next);
      if (eMatch != null) {
        explanation = eMatch.group(1)!.trim();
        j++;
        continue;
      }

      final sMatch = RegExp(r'^[Ss]ubject[:\s]+(.+)$').firstMatch(next);
      if (sMatch != null) {
        subject = sMatch.group(1)!.trim();
        j++;
        continue;
      }

      final oMatch = RegExp(r'^[Oo]ptions?[:\s]+(.+)$').firstMatch(next);
      if (oMatch != null) {
        options = oMatch.group(1)!.split(',').map((o) => o.trim()).where((o) => o.isNotEmpty).toList();
        j++;
        continue;
      }

      final tMatch = RegExp(r'^[Tt]ags?[:\s]+(.+)$').firstMatch(next);
      if (tMatch != null) {
        j++;
        continue;
      }

      if (RegExp(r'^[QAETOSqaetos]').hasMatch(next)) break;
      j++;
    }

    if (answer.isEmpty) return null;

    QuestionType type;
    if (options.length >= 2) {
      type = answer.length > 1 ? QuestionType.multipleChoice : QuestionType.singleChoice;
    } else if (answer.toLowerCase() == 'true' || answer.toLowerCase() == 'false') {
      type = QuestionType.trueFalse;
      options = ['True', 'False'];
    } else {
      type = QuestionType.fillBlank;
    }

    if (type == QuestionType.singleChoice || type == QuestionType.multipleChoice) {
      if (options.isEmpty && answer.contains(',')) {
        options = answer.split(',').map((o) => o.trim()).where((o) => o.isNotEmpty).toList();
        answer = options.isNotEmpty ? options.first : answer;
      }
    }

    return Question(
      subject: subject.isNotEmpty ? subject : 'General',
      questionType: type,
      content: content,
      options: options,
      answer: type == QuestionType.multipleChoice
          ? answer.split(',').map((a) => a.trim()).toList()
          : [answer.trim()],
      explanation: explanation,
    );
  }

  static Question? _parseTabDelimited(String line) {
    final parts = line.split('\t');
    if (parts.length < 2) return null;

    final content = parts[0].trim();
    final answer = parts[1].trim();
    if (content.isEmpty || answer.isEmpty) return null;

    final options = parts.length > 2
        ? parts[2].split(',').map((o) => o.trim()).where((o) => o.isNotEmpty).toList()
        : <String>[];

    final explanation = parts.length > 3 ? parts[3].trim() : '';
    final subject = parts.length > 4 ? parts[4].trim() : 'General';

    QuestionType type;
    if (options.length >= 2) {
      type = answer.length > 1 && answer.contains(',')
          ? QuestionType.multipleChoice
          : QuestionType.singleChoice;
    } else if (answer.toLowerCase() == 'true' || answer.toLowerCase() == 'false') {
      type = QuestionType.trueFalse;
    } else {
      type = QuestionType.fillBlank;
    }

    return Question(
      subject: subject,
      questionType: type,
      content: content,
      options: options,
      answer: type == QuestionType.multipleChoice
          ? answer.split(',').map((a) => a.trim()).toList()
          : [answer],
      explanation: explanation,
    );
  }

  static Question? _parseInlineBracket(String line) {
    final match = RegExp(r'^(.+?)[\[\(](.+?)[\]\)]\s*$').firstMatch(line);
    if (match == null) return null;

    final content = match.group(1)!.trim();
    final answer = match.group(2)!.trim();
    if (content.isEmpty || answer.isEmpty) return null;

    return Question(
      subject: 'General',
      questionType: QuestionType.fillBlank,
      content: content,
      options: [],
      answer: [answer],
    );
  }

  static Question? _parsePipeDelimited(String line) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 2) return null;

    final content = parts[0];
    final answer = parts[1];
    if (content.isEmpty || answer.isEmpty) return null;

    final options = parts.length > 2
        ? parts[2].split(',').map((o) => o.trim()).where((o) => o.isNotEmpty).toList()
        : <String>[];

    final explanation = parts.length > 3 ? parts[3] : '';
    final subject = parts.length > 4 ? parts[4] : 'General';

    QuestionType type;
    if (options.length >= 2) {
      type = answer.contains(',') ? QuestionType.multipleChoice : QuestionType.singleChoice;
    } else if (answer.toLowerCase() == 'true' || answer.toLowerCase() == 'false') {
      type = QuestionType.trueFalse;
    } else {
      type = QuestionType.fillBlank;
    }

    return Question(
      subject: subject,
      questionType: type,
      content: content,
      options: options,
      answer: type == QuestionType.multipleChoice
          ? answer.split(',').map((a) => a.trim()).toList()
          : [answer],
      explanation: explanation,
    );
  }
}
