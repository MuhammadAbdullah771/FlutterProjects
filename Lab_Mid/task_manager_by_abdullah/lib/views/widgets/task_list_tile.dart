import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/task.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../task/task_detail_page.dart';
import '../task/task_form_page.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({super.key, required this.task});

  final Task task;

  Color _priorityColor(BuildContext context) {
    switch (task.priority) {
      case TaskPriority.low:
        return Colors.greenAccent.shade400;
      case TaskPriority.medium:
        return Colors.orangeAccent;
      case TaskPriority.high:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = task.completionProgress;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) async {
                    final vm = context.read<TaskViewModel>();
                    await vm.markTaskCompleted(task);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _priorityColor(context).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.priority.label,
                            style:
                                Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: _priorityColor(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                        if (task.isRepeating)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.repeatType.label,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ...task.tags.map(
                          (tag) => Chip(
                            label: Text(tag.name),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateUtilsHelper.formatDueDate(task.dueDate),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    if (task.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).round()}% • ${task.subtasks.where((s) => s.isDone).length}/${task.subtasks.length} subtasks',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TaskFormPage(existingTask: task),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
