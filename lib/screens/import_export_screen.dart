import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/quiz_record.dart';
import '../providers/app_provider.dart';
import '../utils/txt_parser.dart';
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
          _buildExportCard(context, theme),
          const SizedBox(height: 16),
          _buildJsonImportCard(context, theme),
          const SizedBox(height: 16),
          _buildTxtImportCard(context, theme),
          const SizedBox(height: 24),
          _buildFormatGuide(context, theme),
        ],
      ),
    );
  }

  Widget _buildExportCard(BuildContext context, ThemeData theme) {
    return StaggeredFadeIn(
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
    );
  }

  Widget _buildJsonImportCard(BuildContext context, ThemeData theme) {
    return StaggeredFadeIn(
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
                'Import Questions (JSON)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Import questions from a JSON file.',
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
    );
  }

  Widget _buildTxtImportCard(BuildContext context, ThemeData theme) {
    return StaggeredFadeIn(
      index: 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.text_snippet_outlined, size: 48, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              Text(
                'Import Questions (TXT)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Auto-parse TXT files into quiz questions.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _importTxt(context),
                icon: const Icon(Icons.text_snippet),
                label: const Text('Import from TXT'),
                style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatGuide(BuildContext context, ThemeData theme) {
    return StaggeredFadeIn(
      index: 3,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Supported Formats',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(height: 24),
              _formatRow('Q&A Format', 'Q: What is 2+2?\nA: 4\nOptions: 2,3,4,5\nExplanation: Basic math'),
              const SizedBox(height: 12),
              _formatRow('Tab-Separated', 'question\tanswer\topt1,opt2\tExplanation\tSubject'),
              const SizedBox(height: 12),
              _formatRow('Pipe-Delimited', 'question|answer|opt1,opt2|explanation|subject'),
              const SizedBox(height: 12),
              _formatRow('Inline [Answer]', 'What is 2+2? [4]'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formatRow(String label, String example) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            example,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', height: 1.4),
          ),
        ),
      ],
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

      if (!context.mounted) return;
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

  Future<void> _importTxt(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final parsed = TxtParser.parse(content);

      if (parsed.questions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions could be parsed from the file')),
          );
        }
        return;
      }

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => _TxtPreviewDialog(parsed: parsed),
      );

      if (confirmed == true && context.mounted) {
        final app = context.read<AppProvider>();
        app.addQuestions(parsed.questions);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${parsed.questions.length} questions from TXT')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TXT import failed: $e')),
        );
      }
    }
  }
}

class _TxtPreviewDialog extends StatelessWidget {
  final TxtParserResult parsed;

  const _TxtPreviewDialog({required this.parsed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Import TXT Questions'),
          const SizedBox(height: 4),
          Text(
            '${parsed.parsed} found, ${parsed.skipped} skipped',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: parsed.questions.isEmpty
            ? const Center(child: Text('No questions parsed'))
            : ListView.separated(
                shrinkWrap: true,
                itemCount: parsed.questions.length.clamp(0, 20),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final q = parsed.questions[i];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      q.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      '${q.subject} · ${q.questionType.name}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        if (parsed.questions.isNotEmpty)
          FilledButton(
            onPressed: () {
              if (parsed.skipped > 0) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Skipped Lines'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: parsed.errors
                            .map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(e, style: const TextStyle(fontSize: 12)),
                                ))
                            .toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
              Navigator.of(context).pop(true);
            },
            child: Text('Import ${parsed.questions.length}'),
          ),
      ],
    );
  }
}
