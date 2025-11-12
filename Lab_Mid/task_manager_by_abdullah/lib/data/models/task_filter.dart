import 'task.dart';

class TaskFilter {
  final String? query;
  final TaskPriority? priority;
  final String? tagName;
  final DateTime? startDate;
  final DateTime? endDate;

  const TaskFilter({
    this.query,
    this.priority,
    this.tagName,
    this.startDate,
    this.endDate,
  });

  TaskFilter copyWith({
    String? query,
    TaskPriority? priority,
    String? tagName,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TaskFilter(
      query: query ?? this.query,
      priority: priority ?? this.priority,
      tagName: tagName ?? this.tagName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  TaskFilter clear() => const TaskFilter();
}
