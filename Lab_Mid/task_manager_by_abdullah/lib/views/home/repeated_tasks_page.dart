import 'package:flutter/material.dart';
import '../../core/utils/recurrence_utils.dart';
import '../../data/models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_list_tile.dart';

class RepeatedTasksPage extends StatelessWidget {
  const RepeatedTasksPage({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        title: 'No repeating tasks',
        subtitle: 'Create a repeating task to keep habits consistent.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        final preview = RecurrenceUtils.previewOccurrences(task, take: 3);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TaskListTile(task: task),
            if (preview.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Wrap(
                  spacing: 6,
                  children: [
                    const Text('Upcoming:', style: TextStyle(fontSize: 12)),
                    ...preview.map(
                      (date) => Chip(
                        label: Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
