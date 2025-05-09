// stats_controller.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stats_data.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';

final statsProvider = StateNotifierProvider<StatsNotifier, AsyncValue<StatsData>>((ref) {
  return StatsNotifier(ref);
});

class StatsNotifier extends StateNotifier<AsyncValue<StatsData>> {
  final Ref ref;

  StatsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadStats();
    // Watch task provider for changes
    ref.listen<List<Task>>(taskProvider, (_, tasks) {
      _updateTaskCounts(tasks);
    });
  }

  Future<void> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('dailyStats');
      
      // Get current tasks to calculate counts
      final tasks = ref.read(taskProvider);
      final completedCount = tasks.where((t) => t.completed).length;
      
      final stats = StatsData(
        totalTasks: tasks.length,
        completedTasks: completedCount,
        dailyStats: data != null ? Map<String, int>.from(json.decode(data)) : {},
      );
      
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _updateTaskCounts(List<Task> tasks) {
    if (state.value == null) return;
    
    final completedCount = tasks.where((t) => t.completed).length;
    state = AsyncValue.data(state.value!.copyWith(
      totalTasks: tasks.length,
      completedTasks: completedCount,
    ));
  }

  Future<void> incrementDailyCompleted() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final currentStats = state.value ?? StatsData.empty();

      final updatedDailyStats = {...currentStats.dailyStats};
      updatedDailyStats[today] = (updatedDailyStats[today] ?? 0) + 1;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dailyStats', json.encode(updatedDailyStats));

      state = AsyncValue.data(currentStats.copyWith(
        dailyStats: updatedDailyStats,
        completedTasks: currentStats.completedTasks + 1,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadStats();
  }
}