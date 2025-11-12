import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_list_tile.dart';

class CompletedTasksPage extends StatelessWidget {
  const CompletedTasksPage({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        title: 'Nothing completed yet',
        subtitle: 'Complete a task to see it listed here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (_, index) => TaskListTile(task: tasks[index]),
    );
  }
}
