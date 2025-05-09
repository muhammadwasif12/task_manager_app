import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pie_chart/pie_chart.dart' as pc;
import 'package:task_management_app/controllers/stats_controller.dart';
import 'package:task_management_app/models/stats_data.dart';

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return statsAsync.when(
      data: (stats) {
        final today = DateTime.now().toIso8601String().split('T')[0];
        final remainingTasks = stats.totalTasks - stats.completedTasks;
        final tasksToday = stats.dailyStats[today] ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Statistics'),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(statsProvider.notifier).refresh(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCards(stats, remainingTasks, tasksToday),
                const SizedBox(height: 24),
                _buildPieChart(stats, remainingTasks),
                const SizedBox(height: 24),
                _buildBarChart(stats),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSummaryCards(StatsData stats, int remaining, int today) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2, // Adjusted to prevent overflow
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        StatsCard(
          title: 'Total Tasks', 
          value: stats.totalTasks, 
          icon: Icons.list_alt, 
          color: Colors.blueAccent
        ),
        StatsCard(
          title: 'Completed', 
          value: stats.completedTasks, 
          icon: Icons.check_circle, 
          color: Colors.green
        ),
        StatsCard(
          title: 'Remaining', 
          value: remaining, 
          icon: Icons.pending_actions, 
          color: Colors.orange
        ),
        StatsCard(
          title: 'Today', 
          value: today, 
          icon: Icons.today, 
          color: Colors.purple
        ),
      ],
    );
  }

  Widget _buildPieChart(StatsData stats, int remainingTasks) {
    final total = stats.totalTasks.toDouble();
    final completed = stats.completedTasks.toDouble();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Completion', 
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: pc.PieChart(
                dataMap: {
                  "Completed": completed,
                  "Remaining": remainingTasks.toDouble()
                },
                chartType: pc.ChartType.ring,
                colorList: [Colors.green, Colors.orange],
                chartRadius: 100,
                centerText: total == 0 ? "0%" : "${((completed / total) * 100).toStringAsFixed(1)}%",
                centerTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal
                ),
                legendOptions: const pc.LegendOptions(
                  showLegends: true,
                  legendPosition: pc.LegendPosition.bottom,
                  legendTextStyle: TextStyle(fontSize: 12),
                ),
                chartValuesOptions: const pc.ChartValuesOptions(
                  showChartValues: true,
                  showChartValuesOutside: true,
                  showChartValuesInPercentage: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(StatsData stats) {
    if (stats.dailyStats.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.auto_graph, size: 48, color: Colors.teal.shade300),
              const SizedBox(height: 16),
              Text(
                'No daily progress data available',
                style: TextStyle(color: Colors.teal.shade800),
              ),
            ],
          ),
        ),
      );
    }

    final sortedDates = stats.dailyStats.keys.toList()..sort();
    final last7Days = sortedDates.length > 7 ? sortedDates.sublist(sortedDates.length - 7) : sortedDates;
    final maxYValue = (stats.dailyStats.values.reduce((a, b) => a > b ? a : b).toDouble() + 2);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  maxY: maxYValue,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.teal.shade50,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = last7Days[groupIndex];
                        return BarTooltipItem(
                          '${stats.dailyStats[date]} tasks\n$date',
                          const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final dateParts = last7Days[value.toInt()].split('-');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${dateParts[2]}/${dateParts[1]}',
                              style: const TextStyle(fontSize: 10, color: Colors.teal),
                            ),
                          );
                        },
                        reservedSize: 36,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.teal),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: last7Days.asMap().entries.map((entry) {
                    final index = entry.key;
                    final date = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: stats.dailyStats[date]!.toDouble(),
                          color: Colors.teal,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}