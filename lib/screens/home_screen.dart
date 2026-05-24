import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/animations.dart';
import 'question_bank_screen.dart';
import 'practice_screen.dart';
import 'stats_screen.dart';
import 'import_export_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    _HomeTab(),
    QuestionBankScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        animationDuration: const Duration(milliseconds: 300),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.library_books_outlined), label: 'Questions'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.pushWithAnimation(const PracticeScreen()),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Practice'),
            )
          : null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizMaster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => context.pushWithAnimation(const ImportExportScreen()),
            tooltip: 'Import/Export',
          ),
        ],
      ),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.quiz_outlined,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: app.questions.length),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) {
                                return Text(
                                  '$value questions available',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _QuickStat(
                          icon: Icons.check_circle_outline,
                          label: 'Total\nCorrect',
                          value: app.subjectStats.fold(0, (a, b) => a + b.totalCorrect).toString(),
                          color: Colors.green,
                        ),
                        _QuickStat(
                          icon: Icons.cancel_outlined,
                          label: 'Total\nWrong',
                          value: app.subjectStats.fold(0, (a, b) => a + b.totalWrong).toString(),
                          color: Colors.red,
                        ),
                        _QuickStat(
                          icon: Icons.timer_outlined,
                          label: 'Total\nTime',
                          value: _formatTime(app.subjectStats.fold(0, (a, b) => a + b.totalTimeSecs)),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          StaggeredFadeIn(
            index: 1,
            child: Text(
              'Quick Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeIn(
            index: 2,
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.play_circle_filled,
                    label: 'Practice',
                    color: theme.colorScheme.primary,
                    onTap: () => context.pushWithAnimation(const PracticeScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'Add Question',
                    color: Colors.orange,
                    onTap: () => context.pushWithAnimation(const QuestionEditScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeIn(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    color: Colors.teal,
                    onTap: () {
                      final home = context.findAncestorStateOfType<_HomeScreenState>();
                      home?.setState(() => home._currentIndex = 2);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.palette_outlined,
                    label: 'Theme',
                    color: Colors.purple,
                    onTap: () {
                      final home = context.findAncestorStateOfType<_HomeScreenState>();
                      home?.setState(() => home._currentIndex = 3);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StaggeredFadeIn(
            index: 4,
            child: Text(
              'Recent Activity',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (app.records.isEmpty)
            StaggeredFadeIn(
              index: 5,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No practice records yet.\nStart practicing to see your progress!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            )
          else
            ...app.records.take(5).asMap().entries.map((entry) {
              return StaggeredFadeIn(
                index: 5 + entry.key,
                child: _RecordItem(record: entry.value),
              );
            }),
        ],
      ),
    );
  }

  String _formatTime(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '${h}h${m}m';
    return '${m}m';
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  final dynamic record;
  const _RecordItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (record.score >= 60 ? Colors.green : Colors.orange).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${record.score.toInt()}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: record.score >= 60 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ),
        title: Text(record.subject, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          '${record.correctCount}/${record.totalCount} correct  ·  ${record.durationSecs ~/ 60}m',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          record.score >= 60 ? Icons.emoji_events : Icons.trending_up,
          color: record.score >= 60 ? Colors.amber : Colors.grey,
        ),
      ),
    );
  }
}
