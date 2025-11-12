class TaskOccurrence {
  final int? id;
  final int taskId;
  final DateTime occurrenceDate;
  final bool isCompleted;

  const TaskOccurrence({
    this.id,
    required this.taskId,
    required this.occurrenceDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'task_id': taskId,
        'occurrence_date': occurrenceDate.toIso8601String(),
        'is_completed': isCompleted ? 1 : 0,
      };

  factory TaskOccurrence.fromMap(Map<String, dynamic> map) => TaskOccurrence(
        id: map['id'] as int?,
        taskId: map['task_id'] as int,
        occurrenceDate: DateTime.parse(map['occurrence_date'] as String),
        isCompleted: (map['is_completed'] as int) == 1,
      );
}
