class Task {
  final String id;
  final String title;
  final bool completed;
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'],
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Task copyWith({
    String? title,
    bool? completed,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }
}