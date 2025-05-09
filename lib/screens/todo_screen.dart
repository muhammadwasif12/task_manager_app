import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/controllers/task_controller.dart';
import 'package:task_management_app/controllers/stats_controller.dart';
import 'package:task_management_app/models/task_model.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final Color tealColor = Colors.teal;

  void _addTask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    await ref.read(taskProvider.notifier).addTask(title);
    _controller.clear();
    _focusNode.unfocus();
  }

  void _toggleTask(Task task) async {
    await ref.read(taskProvider.notifier).toggleTask(task.id);

    if (!task.completed) {
      await ref.read(statsProvider.notifier).incrementDailyCompleted();
    }
  }

  void _deleteTask(Task task) async {
    await ref.read(taskProvider.notifier).deleteTask(task.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: tealColor,
          secondary: Colors.teal[300],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Tasks'),
          centerTitle: true,
          backgroundColor: tealColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                _showClearAllDialog(context);
              },
              tooltip: 'Clear All Tasks',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Input Field and Add Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: tealColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: tealColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        cursorColor: Colors.teal,
                        decoration: InputDecoration(
                          hintText: 'What needs to be done?',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _addTask,
                      mini: true,
                      backgroundColor: tealColor,
                      elevation: 0,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Swipe instruction hint
              if (tasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 18,
                        color: tealColor.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Swipe left to delete',
                        style: TextStyle(
                          fontSize: 12,
                          color: tealColor.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              // Task List
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      tasks.isEmpty
                          ? Column(
                            key: const ValueKey('empty-state'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: tealColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first task above',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          )
                          : ListView.separated(
                            key: const ValueKey('task-list'),
                            itemCount: tasks.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return Dismissible(
                                key: ValueKey(task.id),
                                direction: DismissDirection.endToStart,
                                background: _buildSwipeBackground(),
                                secondaryBackground: _buildSwipeBackground(),
                                confirmDismiss: (direction) async {
                                  return await _showDeleteConfirmation(context);
                                },
                                onDismissed: (direction) => _deleteTask(task),
                                movementDuration: const Duration(
                                  milliseconds: 300,
                                ),
                                resizeDuration: const Duration(
                                  milliseconds: 200,
                                ),
                                dismissThresholds: const {
                                  DismissDirection.endToStart: 0.4,
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: tealColor.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: tealColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    leading: Transform.scale(
                                      scale: 1.3,
                                      child: Checkbox(
                                        value: task.completed,
                                        onChanged: (_) => _toggleTask(task),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        side: BorderSide(
                                          width: 1.5,
                                          color: Colors.grey.shade400,
                                        ),
                                        activeColor: tealColor,
                                      ),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        decoration:
                                            task.completed
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        color:
                                            task.completed
                                                ? Colors.grey.shade500
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Tasks'),
            content: const Text(
              'This will permanently delete all tasks. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(taskProvider.notifier).clearAllTasks();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
