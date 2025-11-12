import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_list_tile.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        title: 'No tasks yet',
        subtitle: 'Tap the + button to create your first task.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (_, index) => TaskListTile(task: tasks[index]),
    );
  }
}
