import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/animations.dart';
import '../widgets/stat_card.dart';
import '../widgets/stat_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.watch<AppProvider>();
    final stats = app.subjectStats;
    final daily = app.dailyStats;
    final records = app.records;

    final totalCorrect = stats.fold<int>(0, (a, b) => a + b.totalCorrect);
    final totalWrong = stats.fold<int>(0, (a, b) => a + b.totalWrong);
    final totalTime = stats.fold<int>(0, (a, b) => a + b.totalTimeSecs);
    final totalPracticed = stats.fold<int>(0, (a, b) => a + b.totalPracticeCount);
    final totalQ = stats.fold<int>(0, (a, b) => a + b.totalQuestions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StaggeredFadeIn(
            index: 0,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Questions',
                    value: '$totalQ',
                    icon: Icons.quiz_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Practiced',
                    value: '$totalPracticed',
                    icon: Icons.play_circle_outline,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeIn(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Correct',
                    value: '$totalCorrect',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Wrong',
                    value: '$totalWrong',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeIn(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Accuracy',
                    value: totalCorrect + totalWrong > 0
                        ? '${((totalCorrect / (totalCorrect + totalWrong)) * 100).toInt()}%'
                        : '0%',
                    icon: Icons.percent,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Total Time',
                    value: _formatTime(totalTime),
                    icon: Icons.timer_outlined,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          StaggeredFadeIn(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Progress',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    const Spacer(),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 7, label: Text('7d')),
                        ButtonSegment(value: 30, label: Text('30d')),
                        ButtonSegment(value: 90, label: Text('90d')),
                      ],
                      selected: {_selectedDays},
                      onSelectionChanged: (v) => setState(() => _selectedDays = v.first),
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          'Correct Answers per Day',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                      ScoreLineChart(dailyStats: daily),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          StaggeredFadeIn(
            index: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_outline_rounded, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        'By Subject',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question Distribution',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        SubjectPieChart(stats: stats),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (stats.isNotEmpty)
            StaggeredFadeIn(
              index: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Icon(Icons.table_chart_outlined, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          'Subject Details',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            children: ['Subject', 'Q', 'Score', 'Time']
                                .map((h) => Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(h,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: Colors.grey[600])),
                                    ))
                                .toList(),
                          ),
                          ...stats.map((s) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(s.subject, style: const TextStyle(fontSize: 13)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text('${s.totalQuestions}', style: const TextStyle(fontSize: 13)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text('${s.avgScore.toInt()}%',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: s.avgScore >= 60 ? Colors.green : Colors.orange)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(_formatTime(s.totalTimeSecs),
                                      style: const TextStyle(fontSize: 13)),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (records.isNotEmpty) ...[
            const SizedBox(height: 24),
            StaggeredFadeIn(
              index: 6,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Records',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...records.take(10).toList().asMap().entries.map((entry) {
              return StaggeredFadeIn(
                index: 7 + entry.key,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (entry.value.score >= 60 ? Colors.green : Colors.orange).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.value.score.toInt()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: entry.value.score >= 60 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    title: Text(entry.value.subject, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      '${entry.value.correctCount}/${entry.value.totalCount}  ·  ${_formatTime(entry.value.durationSecs)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      entry.value.startedAt.length >= 10 ? entry.value.startedAt.substring(0, 10) : '',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatTime(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
