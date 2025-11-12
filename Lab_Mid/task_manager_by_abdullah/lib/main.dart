import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/database_service.dart';
import 'data/services/notification_service.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  await databaseService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final settingsViewModel = SettingsViewModel(
    databaseService: databaseService,
    notificationService: notificationService,
  );
  await settingsViewModel.init();

  final taskViewModel = TaskViewModel(
    databaseService: databaseService,
    notificationService: notificationService,
  );
  await taskViewModel.init(
    notificationsEnabled: settingsViewModel.notificationsEnabled,
    soundOption: settingsViewModel.selectedSound,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsViewModel>.value(
          value: settingsViewModel,
        ),
        ChangeNotifierProvider<TaskViewModel>.value(
          value: taskViewModel,
        ),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (_, settings, __) {
        return MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }
}
