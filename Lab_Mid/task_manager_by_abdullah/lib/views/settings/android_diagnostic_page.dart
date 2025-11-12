import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidDiagnosticPage extends StatefulWidget {
  const AndroidDiagnosticPage({super.key});

  @override
  State<AndroidDiagnosticPage> createState() => _AndroidDiagnosticPageState();
}

class _AndroidDiagnosticPageState extends State<AndroidDiagnosticPage> {
  static const MethodChannel _channel = MethodChannel('task_manager/notifications');
  
  bool? _canScheduleExactAlarms;
  String _androidVersion = 'Unknown';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _checking = true);

    try {
      // Get Android version
      if (Platform.isAndroid) {
        _androidVersion = Platform.operatingSystemVersion;
      }

      // Check exact alarm permission
      final canSchedule = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      setState(() {
        _canScheduleExactAlarms = canSchedule;
      });
    } catch (e) {
      debugPrint('Error checking status: $e');
    }

    setState(() => _checking = false);
  }

  Future<void> _openExactAlarmSettings() async {
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
      
      // Wait for user to return
      await Future.delayed(const Duration(seconds: 3));
      _checkStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid12Plus = _androidVersion.contains('12') || 
                            _androidVersion.contains('13') || 
                            _androidVersion.contains('14');

    return Scaffold(
      appBar: AppBar(title: const Text('Android Diagnostic')),
      body: RefreshIndicator(
        onRefresh: _checkStatus,
        child: ListView(
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
                        Icon(Icons.phone_android, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Device Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.blue.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Platform: ${Platform.operatingSystem}'),
                    Text('Version: $_androidVersion'),
                    Text('Android 12+: ${isAndroid12Plus ? "Yes" : "No"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: _canScheduleExactAlarms == true 
                  ? Colors.green.shade50 
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _canScheduleExactAlarms == true 
                              ? Icons.check_circle 
                              : Icons.error,
                          color: _canScheduleExactAlarms == true 
                              ? Colors.green.shade700 
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exact Alarm Permission',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _canScheduleExactAlarms == true 
                                    ? Colors.green.shade700 
                                    : Colors.red.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_checking)
                      const Center(child: CircularProgressIndicator())
                    else if (_canScheduleExactAlarms == true)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ GRANTED',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Scheduled notifications will work!'),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '❌ NOT GRANTED',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This is why notifications don\'t work!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.settings),
                            label: const Text('Open Settings to Grant'),
                            onPressed: _openExactAlarmSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
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
                        Icon(Icons.help_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How to Grant Permission',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.orange.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Tap "Open Settings to Grant" above\n'
                      '2. Find "Alarms & reminders" or "Schedule exact alarms"\n'
                      '3. Toggle it to ON/Allow\n'
                      '4. Come back to this screen\n'
                      '5. Pull down to refresh\n'
                      '6. Should show ✅ GRANTED',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
              onPressed: _checking ? null : _checkStatus,
            ),
          ],
        ),
      ),
    );
  }
}

