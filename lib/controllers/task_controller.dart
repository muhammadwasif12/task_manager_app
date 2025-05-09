import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'package:task_management_app/controllers/stats_controller.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref);
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final Ref ref;

  TaskNotifier(this.ref) : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTasks = prefs.getString('tasks');
      if (savedTasks != null) {
        state = List<Map<String, dynamic>>.from(json.decode(savedTasks))
            .map((json) => Task.fromJson(json))
            .toList();
        
        // Initialize stats with loaded tasks
        _updateStats();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasks', json.encode(state.map((e) => e.toJson()).toList()));
      _updateStats();
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  Future<void> _updateStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalTasks', state.length);
    await prefs.setInt('completedTasks', state.where((task) => task.completed).length);
    
    // Trigger stats refresh
    ref.read(statsProvider.notifier).refresh();
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    state = [
      ...state,
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        completed: false,
        createdAt: DateTime.now(),
      ),
    ];
    await _saveTasks();
  }

  Future<void> toggleTask(String taskId) async {
    final taskIndex = state.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return;

    final wasCompleted = state[taskIndex].completed;
    state = [
      for (final task in state)
        if (task.id == taskId) task.copyWith(completed: !task.completed) else task,
    ];

    await _saveTasks();

    // Only increment daily completed if marking as complete (not un-completing)
    if (!wasCompleted) {
      await ref.read(statsProvider.notifier).incrementDailyCompleted();
    }
  }

  Future<void> deleteTask(String taskId) async {
    state = state.where((task) => task.id != taskId).toList();
    await _saveTasks();
  }

  Future<void> clearAllTasks() async {
    state = [];
    await _saveTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    state = state.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask;
      }
      return task;
    }).toList();
    await _saveTasks();
  }
}