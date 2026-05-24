import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/quiz_record.dart';

class ScoreLineChart extends StatelessWidget {
  final List<DailyStats> dailyStats;

  const ScoreLineChart({super.key, required this.dailyStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (dailyStats.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    final maxY = dailyStats
        .map((s) => [s.correctCount.toDouble(), s.totalQuestions.toDouble()])
        .expand((e) => e)
        .reduce((a, b) => a > b ? a : b);
    final maxVal = maxY > 0 ? maxY * 1.2 : 10.0;

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= dailyStats.length) {
                    return const SizedBox.shrink();
                  }
                  final date = dailyStats[idx].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      date.substring(5, 10),
                      style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dailyStats.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.correctCount.toDouble());
              }).toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
          minY: 0,
          maxY: maxVal,
        ),
        height: 200,
      ),
    );
  }
}

class SubjectPieChart extends StatelessWidget {
  final List<SubjectStats> stats;

  const SubjectPieChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (stats.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
      theme.colorScheme.secondary,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: stats.asMap().entries.map((e) {
                  return PieChartSectionData(
                    value: e.value.totalQuestions.toDouble(),
                    color: colors[e.key % colors.length],
                    radius: 50,
                    title: '${e.value.totalQuestions}',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: stats.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value.subject,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
