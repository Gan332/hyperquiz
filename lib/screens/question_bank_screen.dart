import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/app_provider.dart';
import '../widgets/animations.dart';
import '../widgets/question_card.dart';
import 'question_edit_screen.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String _searchQuery = '';
  String? _subjectFilter;
  QuestionType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final questions = _filterQuestions(app.questions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuestionEditScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.search, size: 20, color: Colors.grey[400]),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    label: _subjectFilter ?? 'All Subjects',
                    items: ['All Subjects', ...app.subjects],
                    selected: _subjectFilter,
                    onSelected: (v) =>
                        setState(() => _subjectFilter = v == 'All Subjects' ? null : v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: _typeLabel(_typeFilter),
                    items: const [
                      'All Types',
                      'Single Choice',
                      'Multiple Choice',
                      'True/False',
                      'Fill Blank',
                    ],
                    selected: _typeLabel(_typeFilter),
                    onSelected: (v) => setState(() {
                      _typeFilter = v == 'All Types' ? null : _parseTypeFilter(v);
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  '${questions.length} questions',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (_searchQuery.isNotEmpty || _subjectFilter != null || _typeFilter != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _searchQuery = '';
                      _subjectFilter = null;
                      _typeFilter = null;
                    }),
                    child: Text(
                      'Clear filters',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // List
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: questions.isEmpty
                  ? Center(
                      key: const ValueKey('empty'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[200]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty || _subjectFilter != null || _typeFilter != null
                                ? 'No questions match your filters'
                                : 'No questions yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _searchQuery.isNotEmpty || _subjectFilter != null || _typeFilter != null
                                ? 'Try adjusting your search or filters'
                                : 'Tap + to add your first question',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: const ValueKey('list'),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return QuestionCard(
                          index: index,
                          question: q,
                          onTap: () => context.pushWithAnimation(
                            QuestionEditScreen(question: q),
                          ),
                          onEdit: () => context.pushWithAnimation(
                            QuestionEditScreen(question: q),
                          ),
                          onDelete: () => _confirmDelete(q),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Question> _filterQuestions(List<Question> questions) {
    return questions.where((q) {
      if (_searchQuery.isNotEmpty &&
          !q.content.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_subjectFilter != null && q.subject != _subjectFilter) return false;
      if (_typeFilter != null && q.questionType != _typeFilter) return false;
      return true;
    }).toList();
  }

  String _typeLabel(QuestionType? type) {
    switch (type) {
      case QuestionType.singleChoice:
        return 'Single Choice';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fillBlank:
        return 'Fill Blank';
      default:
        return 'All Types';
    }
  }

  QuestionType? _parseTypeFilter(String label) {
    switch (label) {
      case 'Single Choice':
        return QuestionType.singleChoice;
      case 'Multiple Choice':
        return QuestionType.multipleChoice;
      case 'True/False':
        return QuestionType.trueFalse;
      case 'Fill Blank':
        return QuestionType.fillBlank;
      default:
        return null;
    }
  }

  void _confirmDelete(Question q) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().removeQuestion(q.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _FilterChip({
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected ?? items.first,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: (v) {
            if (v != null) onSelected(v);
          },
        ),
      ),
    );
  }
}
