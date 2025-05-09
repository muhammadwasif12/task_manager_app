class StatsData {
  final int totalTasks;
  final int completedTasks;
  final Map<String, int> dailyStats;

  StatsData({
    required this.totalTasks,
    required this.completedTasks,
    required this.dailyStats,
  });

  factory StatsData.empty() => StatsData(
        totalTasks: 0,
        completedTasks: 0,
        dailyStats: {},
      );

  StatsData copyWith({
    int? totalTasks,
    int? completedTasks,
    Map<String, int>? dailyStats,
  }) {
    return StatsData(
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      dailyStats: dailyStats ?? this.dailyStats,
    );
  }
}
