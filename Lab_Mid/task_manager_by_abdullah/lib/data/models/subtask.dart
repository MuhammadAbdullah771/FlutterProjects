class Subtask {
  final int? id;
  final int? taskId;
  final String title;
  final bool isDone;

  const Subtask({
    this.id,
    this.taskId,
    required this.title,
    this.isDone = false,
  });

  Subtask copyWith({int? id, int? taskId, String? title, bool? isDone}) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap({int? parentId}) => {
        'id': id,
        'task_id': parentId ?? taskId,
        'title': title,
        'is_done': isDone ? 1 : 0,
      };

  factory Subtask.fromMap(Map<String, dynamic> map) => Subtask(
        id: map['id'] as int?,
        taskId: map['task_id'] as int?,
        title: map['title'] as String,
        isDone: (map['is_done'] as int) == 1,
      );
}
