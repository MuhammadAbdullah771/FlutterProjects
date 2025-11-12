import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';

class PermissionsCheckPage extends StatefulWidget {
  const PermissionsCheckPage({super.key});

  @override
  State<PermissionsCheckPage> createState() => _PermissionsCheckPageState();
}

class _PermissionsCheckPageState extends State<PermissionsCheckPage> {
  bool _checking = false;

  Future<void> _checkAndRequestPermissions() async {
    setState(() => _checking = true);
    
    final settingsVm = context.read<SettingsViewModel>();
    await settingsVm.notificationService.ensurePermissions();
    
    setState(() => _checking = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission check complete! See console for details.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions Check')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Android 12+ Requirements',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'For scheduled notifications to work on Android 12+, you need to grant:',
                  ),
                  const SizedBox(height: 8),
                  const Text('1. ✅ Notification Permission'),
                  const Text('2. ⏰ Exact Alarm Permission (CRITICAL)'),
                  const Text('3. 🔋 Battery Optimization Exemption'),
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
                    'Check & Request Permissions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: _checking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(_checking ? 'Checking...' : 'Check Permissions'),
                    onPressed: _checking ? null : _checkAndRequestPermissions,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This will:\n'
                    '• Check all required permissions\n'
                    '• Request missing permissions\n'
                    '• Show detailed status in console\n'
                    '• Open Settings if needed',
                    style: TextStyle(fontSize: 12),
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
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Manual Steps',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If automatic request doesn\'t work, go to:\n\n'
                    '⏰ Exact Alarms:\n'
                    'Settings → Apps → Task Manager → Alarms & reminders → Allow\n\n'
                    '🔋 Battery:\n'
                    'Settings → Apps → Task Manager → Battery → Unrestricted\n\n'
                    '📱 Notifications:\n'
                    'Settings → Apps → Task Manager → Notifications → Allow',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'After Granting Permissions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green.shade700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Go back to Settings\n'
                    '2. Open "Notification Debug"\n'
                    '3. Test scheduled notification (30 seconds)\n'
                    '4. Close app and wait\n'
                    '5. Notification should appear!',
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

