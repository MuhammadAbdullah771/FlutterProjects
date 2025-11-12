import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/services/notification_service.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import 'export_page.dart';
import 'notification_sound_page.dart';
import 'notification_debug_page.dart';
import 'permissions_check_page.dart';
import 'android_diagnostic_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsViewModel, TaskViewModel>(
      builder: (_, settingsVm, taskVm, __) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Theme'),
                value: settingsVm.isDarkMode,
                onChanged: settingsVm.toggleTheme,
              ),
              SwitchListTile(
                title: const Text('Notifications'),
                value: settingsVm.notificationsEnabled,
                onChanged: (value) async {
                  await settingsVm.toggleNotifications(value);
                  await taskVm.setNotificationPreferences(
                    enabled: value,
                    soundOption: settingsVm.selectedSound,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('Notification sound'),
                subtitle: Text(settingsVm.selectedSound.label),
                onTap: () async {
                  final selected = await Navigator.of(context)
                      .push<NotificationSoundOption>(
                    MaterialPageRoute(
                      builder: (_) => NotificationSoundPage(
                        options: settingsVm.soundOptions,
                        selected: settingsVm.selectedSound,
                      ),
                    ),
                  );
                  if (selected != null) {
                    await settingsVm.updateSound(selected);
                    await taskVm.setNotificationPreferences(
                      enabled: settingsVm.notificationsEnabled,
                      soundOption: selected,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('Test notification (immediate)'),
                subtitle: const Text('Send a test notification now'),
                onTap: () async {
                  await settingsVm.notificationService.showTestNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent! Check your notification panel.'),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Test scheduled notification'),
                subtitle: const Text('Schedule notification for 30 seconds from now'),
                onTap: () async {
                  await settingsVm.notificationService.showScheduledTestNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scheduled! Wait 30 seconds for notification.'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                },
              ),
              Card(
                color: Colors.red.shade50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.warning_amber, color: Colors.red.shade700),
                  title: Text(
                    'Android Fix - START HERE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  subtitle: const Text('Diagnose why notifications don\'t work'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AndroidDiagnosticPage()),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Permissions Check (Android 12+)'),
                subtitle: const Text('Grant required permissions'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PermissionsCheckPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Notification Debug'),
                subtitle: const Text('Test and debug notifications'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationDebugPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending_actions),
                title: const Text('View pending notifications'),
                subtitle: const Text('Check scheduled task reminders'),
                onTap: () async {
                  try {
                    final count = await settingsVm.notificationService.getPendingNotificationCount();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            count > 0
                                ? '$count notification(s) scheduled. Check console for details.'
                                : 'No notifications scheduled',
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error checking notifications: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup database'),
                subtitle: const Text('Export a copy of task data'),
                onTap: () async {
                  final file = await settingsVm.createBackup();
                  await Share.shareXFiles(
                    [
                      XFile(
                        file.path,
                        name: file.uri.pathSegments.isNotEmpty
                            ? file.uri.pathSegments.last
                            : 'task_manager_backup.db',
                      ),
                    ],
                    text: 'Task Manager backup from Task Manager by Abdullah',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup ready to share.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restore database'),
                subtitle: const Text('Import the last exported backup'),
                onTap: () async {
                  final file = await settingsVm.latestBackupFile();
                  if (file == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No backup found. Create one first.'),
                        ),
                      );
                    }
                    return;
                  }
                  await settingsVm.restoreBackup(file);
                  await taskVm.refreshTaskLists(schedule: true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database restored.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export & Share'),
                subtitle: const Text('Generate CSV or PDF'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExportPage()),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('Ad Placements'),
                subtitle: const Text('Integrate AdMob banner/native ads here. TODO.'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy policy'),
                subtitle: const Text('Link to privacy policy page. TODO'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of service'),
                subtitle: const Text('Add legal text or webview. TODO'),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Reset data'),
                textColor: Colors.red,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Reset all data'),
                          content: const Text(
                            'This will delete all tasks and settings. This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (confirm) {
                    await settingsVm.resetData();
                    await taskVm.resetAllData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All data reset.')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
