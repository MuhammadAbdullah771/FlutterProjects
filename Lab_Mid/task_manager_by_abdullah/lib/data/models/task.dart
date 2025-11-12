import '../../core/utils/date_utils.dart';
import '../../core/utils/recurrence_utils.dart';
import 'subtask.dart';
import 'tag.dart';
import 'task_occurrence.dart';

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.name == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

enum RepeatType { none, daily, weekly, interval }

extension RepeatTypeX on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.none:
        return 'None';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.interval:
        return 'Every N days';
    }
  }

  static RepeatType fromString(String value) {
    return RepeatType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => RepeatType.none,
    );
  }
}

class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final RepeatType repeatType;
  final int repeatInterval;
  final List<int> repeatWeekdays;
  final DateTime? repeatEndDate;
  final bool notificationEnabled;
  final int notificationMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Subtask> subtasks;
  final List<Tag> tags;
  final List<TaskOccurrence> occurrences;

  Task({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.repeatType = RepeatType.none,
    this.repeatInterval = 1,
    List<int>? repeatWeekdays,
    this.repeatEndDate,
    this.notificationEnabled = false,
    this.notificationMinutesBefore = 30,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.subtasks = const [],
    this.tags = const [],
    this.occurrences = const [],
  })  : repeatWeekdays = repeatWeekdays ?? const [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isRepeating => repeatType != RepeatType.none;

  double get completionProgress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1 : 0;
    }
    final completed = subtasks.where((s) => s.isDone).length;
    return completed / subtasks.length;
  }

  String get readableDueDate => DateUtilsHelper.formatDueDate(dueDate);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'due_datetime': dueDate?.toIso8601String(),
        'priority': priority.name,
        'is_completed': isCompleted ? 1 : 0,
        'repeat_type': repeatType.name,
        'repeat_interval': repeatInterval,
        'repeat_weekdays': RecurrenceUtils.encodeWeekdays(repeatWeekdays),
        'repeat_end_date': repeatEndDate?.toIso8601String(),
        'notification_enabled': notificationEnabled ? 1 : 0,
        'notification_minutes_before': notificationMinutesBefore,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Task.fromMap(
    Map<String, dynamic> map, {
    List<Subtask> subtasks = const [],
    List<Tag> tags = const [],
    List<TaskOccurrence> occurrences = const [],
  }) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_datetime'] != null
          ? DateTime.parse(map['due_datetime'] as String)
          : null,
      priority: TaskPriorityX.fromString(map['priority'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
      repeatType: RepeatTypeX.fromString(map['repeat_type'] as String),
      repeatInterval: map['repeat_interval'] as int? ?? 1,
      repeatWeekdays: RecurrenceUtils.decodeWeekdays(
        map['repeat_weekdays'] as int? ?? 0,
      ),
      repeatEndDate: map['repeat_end_date'] != null
          ? DateTime.tryParse(map['repeat_end_date'] as String)
          : null,
      notificationEnabled: (map['notification_enabled'] as int) == 1,
      notificationMinutesBefore:
          map['notification_minutes_before'] as int? ?? 30,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      subtasks: subtasks,
      tags: tags,
      occurrences: occurrences,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    RepeatType? repeatType,
    int? repeatInterval,
    List<int>? repeatWeekdays,
    DateTime? repeatEndDate,
    bool? notificationEnabled,
    int? notificationMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subtask>? subtasks,
    List<Tag>? tags,
    List<TaskOccurrence>? occurrences,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      repeatWeekdays: repeatWeekdays ?? this.repeatWeekdays,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationMinutesBefore:
          notificationMinutesBefore ?? this.notificationMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      tags: tags ?? this.tags,
      occurrences: occurrences ?? this.occurrences,
    );
  }
}
