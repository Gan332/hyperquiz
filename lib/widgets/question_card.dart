import 'package:flutter/material.dart';
import '../models/question.dart';
import 'animations.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  IconData _typeIcon() {
    switch (question.questionType) {
      case QuestionType.singleChoice:
        return Icons.radio_button_checked;
      case QuestionType.multipleChoice:
        return Icons.check_box;
      case QuestionType.trueFalse:
        return Icons.toggle_on;
      case QuestionType.fillBlank:
        return Icons.edit_note;
    }
  }

  String _typeLabel() {
    switch (question.questionType) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StaggeredFadeIn(
      index: index,
      child: ScaleOnTap(
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_typeIcon(), size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        _typeLabel(),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (question.subject.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            question.subject,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question.content,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (question.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: question.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (onEdit != null || onDelete != null) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: onEdit,
                            visualDensity: VisualDensity.compact,
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: Icon(Icons.delete_outlined, size: 20, color: Colors.red[300]),
                            onPressed: onDelete,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
