import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/recurrence_utils.dart';
import '../data/models/subtask.dart';
import '../data/models/tag.dart';
import '../data/models/task.dart';
import '../data/models/task_filter.dart';
import '../data/models/task_occurrence.dart';
import '../data/services/database_service.dart';
import '../data/services/export_service.dart';
import '../data/services/notification_service.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel({
    required this.databaseService,
    required this.notificationService,
  });

  final DatabaseService databaseService;
  final NotificationService notificationService;
  final ExportService _exportService = ExportService();

  bool _loading = false;
  bool _notificationsEnabled = true;
  bool _permissionsChecked = false;

  final List<Task> _todayTasks = [];
  final List<Task> _completedTasks = [];
  final List<Task> _pendingTasks = [];
  final List<Task> _repeatingTasks = [];
  final List<Tag> _availableTags = [];

  TaskFilter _activeFilter = const TaskFilter();

  bool get isLoading => _loading;
  List<Task> get todayTasks => List.unmodifiable(_todayTasks);
  List<Task> get completedTasks => List.unmodifiable(_completedTasks);
  List<Task> get pendingTasks => List.unmodifiable(_pendingTasks);
  List<Task> get repeatingTasks => List.unmodifiable(_repeatingTasks);
  List<Tag> get availableTags => List.unmodifiable(_availableTags);
  TaskFilter get activeFilter => _activeFilter;

  Future<void> init({
    required bool notificationsEnabled,
    required NotificationSoundOption soundOption,
  }) async {
    _notificationsEnabled = notificationsEnabled;
    _permissionsChecked = false;
    await notificationService.setSound(soundOption);
    await _refreshTags();
    await refreshTaskLists(schedule: true);
  }

  Future<void> ensurePermissionsAndReschedule() async {
    if (!_notificationsEnabled || _permissionsChecked) return;
    _permissionsChecked = true;
    await notificationService.ensurePermissions();
    await refreshTaskLists(schedule: true);
  }

  Future<void> refreshTaskLists({bool schedule = false}) async {
    _loading = true;
    notifyListeners();

    try {
      final today = await databaseService.fetchTasks(
        filter: _activeFilter,
        dueToday: true,
        isCompleted: false,
      );
      final pending = await databaseService.fetchTasks(
        filter: _activeFilter,
        isCompleted: false,
      );
      final completed = await databaseService.fetchTasks(
        filter: _activeFilter,
        isCompleted: true,
      );

      _todayTasks
        ..clear()
        ..addAll(today);
      _pendingTasks
        ..clear()
        ..addAll(pending);
      _completedTasks
        ..clear()
        ..addAll(completed);
      _repeatingTasks
        ..clear()
        ..addAll(pending.where((task) => task.isRepeating));

      if (schedule && _notificationsEnabled) {
        await notificationService.rescheduleForTasks(_pendingTasks);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to refresh tasks: $error');
      debugPrint('$stackTrace');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setNotificationPreferences({
    required bool enabled,
    required NotificationSoundOption soundOption,
  }) async {
    _notificationsEnabled = enabled;
    if (!enabled) {
      _permissionsChecked = false;
    }
    await notificationService.setSound(soundOption);
    if (!enabled) {
      await notificationService.cancelAll();
    } else {
      _permissionsChecked = false;
      await notificationService.ensurePermissions();
      _permissionsChecked = true;
      await refreshTaskLists(schedule: true);
    }
  }

  Future<void> _refreshTags() async {
    final tags = await databaseService.fetchTags();
    _availableTags
      ..clear()
      ..addAll(tags);
  }

  Future<void> saveTask(Task task) async {
    final now = DateTime.now();
    if (task.id == null) {
      final taskWithDates = task.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      final id = await databaseService.insertTask(taskWithDates);
      final persisted = taskWithDates.copyWith(id: id);
      await _handleNotification(persisted);
    } else {
      final taskWithDates = task.copyWith(updatedAt: now);
      await databaseService.updateTask(taskWithDates);
      await _handleNotification(taskWithDates);
    }
    await refreshTaskLists(schedule: true);
  }

  Future<void> _handleNotification(Task task) async {
    if (!_notificationsEnabled) {
      debugPrint('Notifications disabled globally, skipping');
      return;
    }
    if (!_permissionsChecked) {
      await notificationService.ensurePermissions();
      _permissionsChecked = true;
    }
    if (task.notificationEnabled) {
      debugPrint('Scheduling notification for task ${task.id}: ${task.title}');
      await notificationService.scheduleTaskNotification(task);
    } else if (task.id != null) {
      debugPrint('Canceling notification for task ${task.id}');
      await notificationService.cancelTaskNotification(task.id!);
    }
  }

  Future<void> deleteTask(Task task) async {
    if (task.id == null) return;
    await databaseService.deleteTask(task.id!);
    await notificationService.cancelTaskNotification(task.id!);
    await refreshTaskLists(schedule: true);
  }

  Future<void> toggleSubtask(Subtask subtask) async {
    final updated = subtask.copyWith(isDone: !subtask.isDone);
    await databaseService.updateSubtask(updated);
    await refreshTaskLists(schedule: false);
  }

  Future<void> markTaskCompleted(Task task) async {
    if (task.id == null) return;
    
    debugPrint('Marking task ${task.id} as ${task.isCompleted ? "incomplete" : "complete"}');
    
    if (!task.isRepeating) {
      // Toggle completion status
      final newCompletionStatus = !task.isCompleted;
      await databaseService.markTaskCompletion(
        taskId: task.id!,
        isCompleted: newCompletionStatus,
      );
      
      // Handle notifications
      if (task.notificationEnabled) {
        if (newCompletionStatus) {
          // Task is now completed - cancel notification
          await notificationService.cancelTaskNotification(task.id!);
          debugPrint('Cancelled notification for completed task ${task.id}');
        } else {
          // Task is now incomplete - reschedule notification
          await notificationService.scheduleTaskNotification(task);
          debugPrint('Rescheduled notification for task ${task.id}');
        }
      }
    } else {
      final occurrence = TaskOccurrence(
        taskId: task.id!,
        occurrenceDate: task.dueDate ?? DateTime.now(),
        isCompleted: true,
      );
      await databaseService.insertOccurrence(occurrence);
      final next = RecurrenceUtils.nextOccurrence(task);
      if (next != null &&
          (task.repeatEndDate == null || !next.isAfter(task.repeatEndDate!))) {
        final nextTask = task.copyWith(
          dueDate: next,
          isCompleted: false,
          updatedAt: DateTime.now(),
        );
        await databaseService.updateTask(nextTask);
        await _handleNotification(nextTask);
      } else {
        await databaseService.markTaskCompletion(
          taskId: task.id!,
          isCompleted: true,
        );
        await notificationService.cancelTaskNotification(task.id!);
      }
    }
    await refreshTaskLists(schedule: true);
  }

  Future<void> completeSubtaskAndTaskIfNeeded(Task task, Subtask subtask) async {
    await toggleSubtask(subtask);
    final refreshedTask = (await databaseService.fetchTasks(
      filter: const TaskFilter(),
      isCompleted: task.isCompleted,
    ))
        .firstWhere((element) => element.id == task.id);
    final allDone = refreshedTask.subtasks.every((s) => s.isDone);
    if (allDone && !task.isCompleted) {
      await markTaskCompleted(task);
    }
  }

  Future<void> applyFilter(TaskFilter filter) async {
    _activeFilter = filter;
    await refreshTaskLists(schedule: false);
  }

  Future<void> clearFilters() async {
    _activeFilter = const TaskFilter();
    await refreshTaskLists(schedule: false);
  }

  Future<Tag> createTag(String name) async {
    final id = await databaseService.upsertTag(name);
    final tag = Tag(id: id, name: name);
    await _refreshTags();
    notifyListeners();
    return tag;
  }

  Future<void> exportTasksToCsv({
    required List<Task> tasks,
    String? filename,
  }) async {
    final file = await _exportService.exportCsv(tasks);
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          name: filename ?? file.uri.pathSegments.last,
        ),
      ],
      text: 'Tasks export',
      subject: 'Tasks',
    );
  }

  Future<void> exportTasksToPdf(List<Task> tasks) async {
    final bytes = await _exportService.exportPdfBytes(tasks);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tasks_export.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'Tasks PDF export');
  }

  Future<void> resetAllData() async {
    await databaseService.resetAll();
    await notificationService.cancelAll();
    await refreshTaskLists(schedule: false);
  }
}
