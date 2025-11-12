import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_manager_by_abdullah/data/models/task.dart';
import 'package:task_manager_by_abdullah/data/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseService databaseService;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    databaseFactory = databaseFactoryFfi;
    databaseService = DatabaseService();
    await databaseService.setFactory(databaseFactory);
    await databaseService.init(pathOverride: inMemoryDatabasePath);
  });

  test('insert and fetch task', () async {
    final task = Task(
      title: 'Test task',
      description: 'Testing',
      dueDate: DateTime(2024, 10, 1, 12),
      notificationEnabled: true,
    );
    final id = await databaseService.insertTask(task);
    expect(id, isNonZero);
    final results = await databaseService.fetchTasks();
    expect(results.length, 1);
    expect(results.first.title, 'Test task');
  });
}
