import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/app_provider.dart';

class QuestionEditScreen extends StatefulWidget {
  final Question? question;

  const QuestionEditScreen({super.key, this.question});

  @override
  State<QuestionEditScreen> createState() => _QuestionEditScreenState();
}

class _QuestionEditScreenState extends State<QuestionEditScreen> {
  late final TextEditingController _contentCtrl;
  late final TextEditingController _explanationCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _tagsCtrl;
  late QuestionType _questionType;
  late List<TextEditingController> _optionCtrls;
  late List<bool> _answerChecks;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    _isEditing = q != null;
    _contentCtrl = TextEditingController(text: q?.content ?? '');
    _explanationCtrl = TextEditingController(text: q?.explanation ?? '');
    _subjectCtrl = TextEditingController(text: q?.subject ?? '');
    _tagsCtrl = TextEditingController(text: q?.tags.join(', ') ?? '');
    _questionType = q?.questionType ?? QuestionType.singleChoice;

    if (q != null && q.options.isNotEmpty) {
      _optionCtrls = q.options.map((o) => TextEditingController(text: o)).toList();
    } else {
      _optionCtrls = [
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ];
    }

    if (q != null && q.answer.isNotEmpty && q.questionType != QuestionType.fillBlank) {
      _answerChecks = q.options.map((o) => q.answer.contains(o)).toList();
      if (_answerChecks.length < _optionCtrls.length) {
        _answerChecks = List.filled(_optionCtrls.length, false);
      }
    } else {
      _answerChecks = List.filled(_optionCtrls.length, false);
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _explanationCtrl.dispose();
    _subjectCtrl.dispose();
    _tagsCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMultiple = _questionType == QuestionType.multipleChoice;
    final isFillBlank = _questionType == QuestionType.fillBlank;
    final isTrueFalse = _questionType == QuestionType.trueFalse;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Question' : 'New Question'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Subject & Type
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'e.g. Math, Physics',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<QuestionType>(
                  value: _questionType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: QuestionType.singleChoice, child: Text('Single Choice')),
                    DropdownMenuItem(value: QuestionType.multipleChoice, child: Text('Multiple Choice')),
                    DropdownMenuItem(value: QuestionType.trueFalse, child: Text('True/False')),
                    DropdownMenuItem(value: QuestionType.fillBlank, child: Text('Fill Blank')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _questionType = v;
                        for (final c in _optionCtrls) {
                          c.dispose();
                        }
                        if (v == QuestionType.trueFalse) {
                          _optionCtrls = [
                            TextEditingController(text: 'True'),
                            TextEditingController(text: 'False'),
                          ];
                          _answerChecks = [false, true];
                        } else {
                          _optionCtrls = List.generate(4, (_) => TextEditingController());
                          _answerChecks = List.filled(4, false);
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          TextField(
            controller: _contentCtrl,
            decoration: const InputDecoration(
              labelText: 'Question Content',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            minLines: 2,
          ),
          const SizedBox(height: 16),
          // Options
          if (!isFillBlank) ...[
            Text(
              'Options',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_optionCtrls.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: isMultiple
                          ? Checkbox(
                              value: _answerChecks[i],
                              onChanged: (v) => setState(() => _answerChecks[i] = v ?? false),
                            )
                          : Radio<bool>(
                              value: true,
                              groupValue: _answerChecks[i] ? true : null,
                              onChanged: (_) {
                                setState(() {
                                  _answerChecks = List.filled(_answerChecks.length, false);
                                  _answerChecks[i] = true;
                                });
                              },
                            ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _optionCtrls[i],
                        decoration: InputDecoration(
                          hintText: 'Option ${String.fromCharCode(65 + i)}',
                        ),
                        readOnly: isTrueFalse,
                      ),
                    ),
                    if (!isTrueFalse)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _optionCtrls.length > 2
                            ? () {
                                setState(() {
                                  _optionCtrls.removeAt(i);
                                  _answerChecks.removeAt(i);
                                });
                              }
                            : null,
                      ),
                  ],
                ),
              );
            }),
            if (!isTrueFalse)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _optionCtrls.add(TextEditingController());
                    _answerChecks.add(false);
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add option'),
              ),
          ],
          // Fill blank answer
          if (isFillBlank) ...[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Answer',
                hintText: 'Enter the correct answer',
              ),
              controller: _optionCtrls.isNotEmpty ? _optionCtrls[0] : null,
            ),
          ],
          const SizedBox(height: 16),
          // Tags
          TextField(
            controller: _tagsCtrl,
            decoration: const InputDecoration(
              labelText: 'Tags',
              hintText: 'Comma separated, e.g. algebra, chapter1',
            ),
          ),
          const SizedBox(height: 16),
          // Explanation
          TextField(
            controller: _explanationCtrl,
            decoration: const InputDecoration(
              labelText: 'Explanation (optional)',
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            minLines: 2,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _save() {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question content is required')),
      );
      return;
    }

    List<String> options;
    List<String> answer;

    switch (_questionType) {
      case QuestionType.fillBlank:
        options = [];
        answer = [_optionCtrls[0].text.trim()];
        if (answer[0].isEmpty) {
          _showError('Please enter an answer');
          return;
        }
        break;
      case QuestionType.trueFalse:
        options = ['True', 'False'];
        answer = [_answerChecks[0] ? 'True' : 'False'];
        break;
      case QuestionType.singleChoice:
        options = _optionCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
        if (options.length < 2) {
          _showError('Please provide at least 2 options');
          return;
        }
        final checked = _answerChecks.indexWhere((b) => b);
        if (checked == -1) {
          _showError('Please select the correct answer');
          return;
        }
        answer = [options[checked]];
        break;
      case QuestionType.multipleChoice:
        options = _optionCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
        if (options.length < 2) {
          _showError('Please provide at least 2 options');
          return;
        }
        answer = options.where((_, i) => _answerChecks[i]).toList();
        if (answer.isEmpty) {
          _showError('Please select at least one correct answer');
          return;
        }
    }

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final now = DateTime.now().toIso8601String();
    final app = context.read<AppProvider>();
    final q = Question(
      id: widget.question?.id ?? 0,
      subject: _subjectCtrl.text.trim(),
      questionType: _questionType,
      content: content,
      options: options,
      answer: answer,
      explanation: _explanationCtrl.text.trim(),
      tags: tags,
      createdAt: widget.question?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      app.updateQuestion(q);
    } else {
      app.addQuestion(q);
    }

    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
