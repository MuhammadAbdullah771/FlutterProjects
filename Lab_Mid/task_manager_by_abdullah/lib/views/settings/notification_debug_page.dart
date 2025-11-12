import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';

class NotificationDebugPage extends StatefulWidget {
  const NotificationDebugPage({super.key});

  @override
  State<NotificationDebugPage> createState() => _NotificationDebugPageState();
}

class _NotificationDebugPageState extends State<NotificationDebugPage> {
  int _testSeconds = 30;

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Tests',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Immediate Notification'),
                    subtitle: const Text('Shows instantly'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await settingsVm.notificationService.showTestNotification();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sent! Check notification panel')),
                          );
                        }
                      },
                      child: const Text('Test'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text('Scheduled in $_testSeconds seconds'),
                    subtitle: const Text('Close app and wait'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_testSeconds > 10) {
                              setState(() => _testSeconds -= 10);
                            }
                          },
                        ),
                        Text('$_testSeconds'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (_testSeconds < 300) {
                              setState(() => _testSeconds += 10);
                            }
                          },
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await settingsVm.notificationService.showScheduledTestNotification();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Scheduled for $_testSeconds seconds! Close app and wait.'),
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          },
                          child: const Text('Schedule'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Pending'),
                    onPressed: () async {
                      try {
                        final count = await settingsVm.notificationService.getPendingNotificationCount();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                count > 0
                                    ? '$count notification(s) pending. Check console for details.'
                                    : 'No notifications pending',
                              ),
                            ),
                          );
                        }
                      } catch (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Tap "Immediate Notification" - should appear instantly\n\n'
                    '2. Tap "Schedule" - then CLOSE THE APP completely\n\n'
                    '3. Wait for the scheduled time\n\n'
                    '4. Notification should appear\n\n'
                    '5. Check console logs for detailed debugging info',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

