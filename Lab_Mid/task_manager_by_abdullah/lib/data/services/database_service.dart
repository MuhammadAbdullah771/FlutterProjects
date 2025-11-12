import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/date_utils.dart';
import '../models/subtask.dart';
import '../models/tag.dart';
import '../models/task.dart';
import '../models/task_filter.dart';
import '../models/task_occurrence.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static const _dbName = 'task_manager.db';
  static const _dbVersion = 2;

  Database? _db;
  DatabaseFactory? _factoryOverride;

  Future<void> setFactory(DatabaseFactory factory) async {
    _factoryOverride = factory;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    throw StateError('Database not initialized');
  }

  Future<void> init({String? pathOverride}) async {
    if (_db != null) return;

    final factory = _factoryOverride ?? databaseFactory;
    late final String dbPath;

    if (pathOverride != null) {
      dbPath = pathOverride;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      dbPath = p.join(directory.path, _dbName);
    }

    _db = await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => _createSchema(db),
        onUpgrade: (db, oldVersion, newVersion) =>
            _migrateSchema(db, oldVersion, newVersion),
      ),
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_datetime TEXT,
        priority TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        repeat_type TEXT NOT NULL DEFAULT 'none',
        repeat_interval INTEGER NOT NULL DEFAULT 1,
        repeat_weekdays INTEGER NOT NULL DEFAULT 0,
        repeat_end_date TEXT,
        notification_enabled INTEGER NOT NULL DEFAULT 0,
        notification_minutes_before INTEGER NOT NULL DEFAULT 30,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');

    await db.execute('''
      CREATE TABLE task_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY(tag_id) REFERENCES tags(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE occurrences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        occurrence_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> _migrateSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS occurrences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER NOT NULL,
          occurrence_date TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
        );
      ''');
    }
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (task.subtasks.isNotEmpty) {
      await upsertSubtasks(id, task.subtasks);
    }
    if (task.tags.isNotEmpty) {
      await assignTags(id, task.tags);
    }
    return id;
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    await upsertSubtasks(task.id!, task.subtasks);
    await assignTags(task.id!, task.tags);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> fetchTasks({
    TaskFilter? filter,
    bool? isCompleted,
    bool dueToday = false,
    bool repeatingOnly = false,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (isCompleted != null) {
      whereClauses.add('is_completed = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }
    if (repeatingOnly) {
      whereClauses.add("repeat_type != 'none'");
    }
    if (filter?.priority != null) {
      whereClauses.add('priority = ?');
      whereArgs.add(filter!.priority!.name);
    }
    if (filter?.query != null && filter!.query!.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR description LIKE ?)');
      final likeQuery = '%${filter.query!.trim()}%';
      whereArgs
        ..add(likeQuery)
        ..add(likeQuery);
    }
    if (dueToday) {
      final start = DateUtilsHelper.startOfDay(DateTime.now());
      final end = DateUtilsHelper.endOfDay(DateTime.now());
      whereClauses.add('due_datetime BETWEEN ? AND ?');
      whereArgs
        ..add(start.toIso8601String())
        ..add(end.toIso8601String());
    } else {
      if (filter?.startDate != null) {
        whereClauses.add('due_datetime >= ?');
        whereArgs.add(filter!.startDate!.toIso8601String());
      }
      if (filter?.endDate != null) {
        whereClauses.add('due_datetime <= ?');
        whereArgs.add(filter!.endDate!.toIso8601String());
      }
    }

    if (filter?.tagName != null) {
      final tagRows = await db.rawQuery('''
        SELECT tt.task_id FROM task_tags tt
        INNER JOIN tags t ON t.id = tt.tag_id
        WHERE t.name = ?
      ''', [filter!.tagName]);
      if (tagRows.isEmpty) {
        return [];
      }
      final taskIds = tagRows.map((e) => e['task_id'] as int).toList();
      final placeholders = List.filled(taskIds.length, '?').join(',');
      whereClauses.add('id IN ($placeholders)');
      whereArgs.addAll(taskIds);
    }

    final results = await db.query(
      'tasks',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs,
      orderBy:
          'CASE WHEN due_datetime IS NULL THEN 1 ELSE 0 END, due_datetime ASC, created_at DESC',
    );

    final tasks = <Task>[];
    for (final row in results) {
      final taskId = row['id'] as int;
      final subtasks = await _subtasksForTask(taskId);
      final tags = await _tagsForTask(taskId);
      final occurrences = await _occurrencesForTask(taskId);
      tasks.add(
        Task.fromMap(
          row,
          subtasks: subtasks,
          tags: tags,
          occurrences: occurrences,
        ),
      );
    }
    return tasks;
  }

  Future<List<Subtask>> _subtasksForTask(int taskId) async {
    final db = await database;
    final rows = await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return rows.map(Subtask.fromMap).toList();
  }

  Future<List<Tag>> _tagsForTask(int taskId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT t.id, t.name FROM tags t
      INNER JOIN task_tags tt ON tt.tag_id = t.id
      WHERE tt.task_id = ?
    ''', [taskId]);
    return rows.map(Tag.fromMap).toList();
  }

  Future<List<TaskOccurrence>> _occurrencesForTask(int taskId) async {
    final db = await database;
    final rows = await db.query(
      'occurrences',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'occurrence_date DESC',
    );
    return rows.map(TaskOccurrence.fromMap).toList();
  }

  Future<void> upsertSubtasks(int taskId, List<Subtask> subtasks) async {
    final db = await database;
    await db.delete('subtasks', where: 'task_id = ?', whereArgs: [taskId]);
    for (final subtask in subtasks) {
      if (subtask.title.trim().isEmpty) continue;
      await db.insert(
        'subtasks',
        subtask.copyWith(taskId: taskId).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> assignTags(int taskId, List<Tag> tags) async {
    final db = await database;
    await db.delete('task_tags', where: 'task_id = ?', whereArgs: [taskId]);
    for (final tag in tags) {
      final tagId = tag.id ?? await upsertTag(tag.name);
      await db.insert('task_tags', {
        'task_id': taskId,
        'tag_id': tagId,
      });
    }
  }

  Future<int> upsertTag(String name) async {
    final db = await database;
    final existing = await db.query(
      'tags',
      where: 'LOWER(name) = ?',
      whereArgs: [name.toLowerCase()],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return db.insert('tags', {'name': name});
  }

  Future<List<Tag>> fetchTags() async {
    final db = await database;
    final rows = await db.query('tags', orderBy: 'name');
    return rows.map(Tag.fromMap).toList();
  }

  Future<void> updateSubtask(Subtask subtask) async {
    final db = await database;
    await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<void> insertOccurrence(TaskOccurrence occurrence) async {
    final db = await database;
    await db.insert('occurrences', occurrence.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markTaskCompletion({
    required int taskId,
    required bool isCompleted,
  }) async {
    final db = await database;
    await db.update(
      'tasks',
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> resetAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('task_tags');
      await txn.delete('subtasks');
      await txn.delete('occurrences');
      await txn.delete('tasks');
    });
  }

  Future<File> exportDatabaseFile() async {
    final path = await _dbPath();
    final file = File(path);
    final directory = await getApplicationDocumentsDirectory();
    final backup = File(p.join(directory.path, 'task_manager_backup.db'));
    await backup.writeAsBytes(await file.readAsBytes());
    return backup;
  }

  Future<File?> latestBackupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final backup = File(p.join(directory.path, 'task_manager_backup.db'));
    if (await backup.exists()) {
      return backup;
    }
    return null;
  }

  Future<void> importDatabaseFile(File file) async {
    final path = await _dbPath();
    await file.copy(path);
    await _db?.close();
    _db = null;
    await init(pathOverride: path);
  }

  Future<String> _dbPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, _dbName);
  }
}
