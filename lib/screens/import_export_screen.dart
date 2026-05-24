import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/quiz_record.dart';
import '../providers/app_provider.dart';
import '../widgets/animations.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Import / Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StaggeredFadeIn(
            index: 0,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.file_download_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Export Questions',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Export all your questions as a JSON file for backup or sharing.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _exportQuestions(context),
                      icon: const Icon(Icons.file_download),
                      label: const Text('Export to JSON'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          StaggeredFadeIn(
            index: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.file_upload_outlined, size: 48, color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Import Questions',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Import questions from a JSON file. Existing questions with the same ID will be skipped.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _importQuestions(context),
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Import from JSON'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          StaggeredFadeIn(
            index: 2,
            child: Text(
              'JSON Format',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          StaggeredFadeIn(
            index: 3,
            child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The JSON file should have the following structure:',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '{\n  "version": "1.0",\n  "exported_at": "2024-01-01T00:00:00Z",\n  "questions": [\n    {\n      "subject": "Math",\n      "question_type": "SingleChoice",\n      "content": "What is 2+2?",\n      "options": ["1","2","3","4"],\n      "answer": ["4"],\n      "explanation": "2+2=4",\n      "tags": ["algebra"]\n    }\n  ]\n}',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportQuestions(BuildContext context) async {
    final app = context.read<AppProvider>();
    final questions = app.questions;

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions to export')),
      );
      return;
    }

    final data = ImportExportData(
      exportedAt: DateTime.now().toIso8601String(),
      questions: questions,
    );

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save questions as JSON',
        fileName: 'questions_export.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(data.toJson()),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported ${questions.length} questions to $result')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importQuestions(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final data = ImportExportData.fromJson(json);

      if (data.questions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions found in file')),
          );
        }
        return;
      }

      final app = context.read<AppProvider>();
      final newQuestions = data.questions.map((q) => Question(
        subject: q.subject,
        questionType: q.questionType,
        content: q.content,
        options: q.options,
        answer: q.answer,
        explanation: q.explanation,
        tags: q.tags,
      )).toList();
      app.addQuestions(newQuestions);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${newQuestions.length} questions successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}
