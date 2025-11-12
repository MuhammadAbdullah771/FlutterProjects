import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/task.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../widgets/subtask_tile.dart';
import 'task_form_page.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TaskFormPage(existingTask: task)),
            ),
          ),
        ],
      ),
      body: Consumer<TaskViewModel>(
        builder: (_, vm, __) {
          // Get the most up-to-date version of the task from all lists
          final allTasks = [
            ...vm.todayTasks,
            ...vm.pendingTasks,
            ...vm.repeatingTasks,
            ...vm.completedTasks,
          ];
          
          final refreshedTask = allTasks.firstWhere(
            (t) => t.id == task.id,
            orElse: () => task,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(refreshedTask.title, style: theme.textTheme.headlineSmall),
                subtitle: Text(refreshedTask.description ?? 'No description'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(DateUtilsHelper.formatDueDate(refreshedTask.dueDate)),
                subtitle: Text(
                  'Created ${DateUtilsHelper.fullDateTime.format(refreshedTask.createdAt)}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Priority'),
                subtitle: Text(refreshedTask.priority.label),
              ),
              if (refreshedTask.isRepeating)
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Repeat'),
                  subtitle: Text('${refreshedTask.repeatType.label} • every ${refreshedTask.repeatInterval}'),
                ),
              if (refreshedTask.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: refreshedTask.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag.name),
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      )
                      .toList(),
                ),
              const Divider(height: 32),
              Text('Subtasks', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (refreshedTask.subtasks.isEmpty)
                const Text('No subtasks added.'),
              ...refreshedTask.subtasks.map(
                (subtask) => SubtaskTile(
                  subtask: subtask,
                  onChanged: (value) => vm.toggleSubtask(
                    subtask.copyWith(isDone: value),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: Icon(refreshedTask.isCompleted ? Icons.undo : Icons.check),
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        await vm.markTaskCompleted(refreshedTask);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                refreshedTask.isCompleted
                                    ? 'Task marked as active'
                                    : 'Task completed! 🎉',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                label: Text(
                  refreshedTask.isCompleted ? 'Mark as active' : 'Mark completed',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
