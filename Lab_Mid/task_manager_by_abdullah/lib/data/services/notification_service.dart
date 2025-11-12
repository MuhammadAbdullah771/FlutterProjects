import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../core/utils/recurrence_utils.dart';
import '../models/task.dart';

class NotificationSoundOption {
  final String id;
  final String label;
  final String? androidUri;
  final String? iosSound;

  const NotificationSoundOption({
    required this.id,
    required this.label,
    this.androidUri,
    this.iosSound,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _channel =
      MethodChannel('task_manager/notifications');

  bool _initialized = false;
  NotificationSoundOption _soundOption = soundOptions.first;

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  @pragma('vm:entry-point')
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.id}, payload: ${response.payload}');
    // The notification was tapped - app will open automatically
    // You can add navigation logic here if needed
  }

  static const soundOptions = <NotificationSoundOption>[
    NotificationSoundOption(
      id: 'default',
      label: 'System Default',
      androidUri: null,
      iosSound: null,
    ),
    NotificationSoundOption(
      id: 'alarm',
      label: 'System Alarm',
      androidUri: 'content://settings/system/alarm_alert',
      iosSound: 'alarm.caf',
    ),
    NotificationSoundOption(
      id: 'notification',
      label: 'System Notification',
      androidUri: 'content://settings/system/notification_sound',
      iosSound: 'default.caf',
    ),
    NotificationSoundOption(
      id: 'ringtone',
      label: 'System Ringtone',
      androidUri: 'content://settings/system/ringtone',
      iosSound: 'ring.caf',
    ),
  ];

  Future<void> init() async {
    if (_initialized) return;

    if (!_isSupportedPlatform) {
      debugPrint(
        'Local notifications are not supported on this platform. Initialization skipped.',
      );
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: iosInit,
        ),
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
      );

      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Create HIGH PRIORITY notification channel for Android 8+
        const channel = AndroidNotificationChannel(
          'task_reminders',
          'Task Reminders',
          description: 'High priority notifications for task reminders',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFF00FF00),
          showBadge: true,
        );
        
        await androidPlugin.createNotificationChannel(channel);
        debugPrint('✓ HIGH PRIORITY notification channel created for Android 8+');
        
        // Request notification permissions for Android 13+
        if (Platform.isAndroid) {
          final granted = await androidPlugin.requestNotificationsPermission();
          debugPrint('Notification permission granted: $granted');
        }
      }

      tz.initializeTimeZones();
      // Use a fixed timezone for now - you can enhance this later
      // For Android, the system will handle the correct time anyway
      try {
        // Try common timezones based on system locale
        final now = DateTime.now();
        final offsetHours = now.timeZoneOffset.inHours;
        final offsetMinutes = now.timeZoneOffset.inMinutes % 60;
        
        // Try to find a matching timezone based on offset
        String tzName = 'UTC';
        if (offsetHours == -8) tzName = 'America/Los_Angeles';
        else if (offsetHours == -5) tzName = 'America/New_York';
        else if (offsetHours == 0) tzName = 'Europe/London';
        else if (offsetHours == 1) tzName = 'Europe/Paris';
        else if (offsetHours == 5 && offsetMinutes == 30) tzName = 'Asia/Kolkata';
        else if (offsetHours == 8) tzName = 'Asia/Singapore';
        
        try {
          tz.setLocalLocation(tz.getLocation(tzName));
          debugPrint('Set timezone to: $tzName');
        } catch (e) {
          tz.setLocalLocation(tz.getLocation('UTC'));
          debugPrint('Fallback to UTC timezone');
        }
      } catch (error) {
        debugPrint('Error setting timezone: $error');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
      _initialized = true;
    } on MissingPluginException catch (error, stackTrace) {
      debugPrint(
        'Local notifications plugin not found. Notifications disabled: $error',
      );
      debugPrint('$stackTrace');
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'Failed to initialize local notifications. Notifications disabled: $error',
      );
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected error during notification initialization: $error',
      );
      debugPrint('$stackTrace');
    }
  }

  NotificationSoundOption get currentSound => _soundOption;

  Future<void> setSound(NotificationSoundOption option) async {
    _soundOption = option;
  }

  Future<void> ensurePermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    debugPrint('');
    debugPrint('🔔 ========== REQUESTING PERMISSIONS (Android 12+) ==========');

    // Request notification permission (Android 13+)
    final notificationStatus = await Permission.notification.status;
    debugPrint('📱 Notification permission status: $notificationStatus');
    
    if (notificationStatus.isDenied || notificationStatus.isRestricted) {
      final result = await Permission.notification.request();
      debugPrint('📱 Notification permission result: $result');
      
      if (!result.isGranted) {
        debugPrint('❌ CRITICAL: Notification permission NOT granted!');
        debugPrint('   User must enable in Settings → Apps → Task Manager → Notifications');
      }
    } else {
      debugPrint('✅ Notification permission already granted');
    }

    if (Platform.isAndroid) {
      // CRITICAL: Request exact alarm permission (Android 12+)
      try {
        final canSchedule =
            await _channel.invokeMethod<bool>('canScheduleExactAlarms');
        debugPrint('⏰ Can schedule exact alarms: $canSchedule');
        
        if (canSchedule == false) {
          debugPrint('⚠️  REQUESTING EXACT ALARM PERMISSION...');
          debugPrint('   This will open Settings. User MUST enable it!');
          await _channel.invokeMethod('requestExactAlarmPermission');
          
          // Wait a bit and check again
          await Future.delayed(const Duration(seconds: 2));
          final canScheduleAfter =
              await _channel.invokeMethod<bool>('canScheduleExactAlarms');
          
          if (canScheduleAfter == true) {
            debugPrint('✅ Exact alarm permission GRANTED!');
          } else {
            debugPrint('❌ CRITICAL: Exact alarm permission NOT granted!');
            debugPrint('   Scheduled notifications will NOT work without this!');
            debugPrint('   Go to: Settings → Apps → Task Manager → Alarms & reminders → Allow');
          }
        } else {
          debugPrint('✅ Exact alarm permission already granted');
        }
      } catch (error) {
        debugPrint('❌ Error checking exact alarm permission: $error');
      }

      // Request to ignore battery optimizations
      try {
        final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
        debugPrint('🔋 Battery optimization status: $batteryStatus');
        
        if (!batteryStatus.isGranted) {
          final result = await Permission.ignoreBatteryOptimizations.request();
          debugPrint('🔋 Battery optimization result: $result');
          
          if (result.isGranted) {
            debugPrint('✅ Battery optimization disabled');
          } else {
            debugPrint('⚠️  Battery optimization still enabled (may affect notifications)');
          }
        } else {
          debugPrint('✅ Battery optimization already disabled');
        }
      } catch (error) {
        debugPrint('⚠️  Battery optimization request failed: $error');
      }

      // Request system alert window permission for full-screen intent
      try {
        final systemAlertStatus = await Permission.systemAlertWindow.status;
        debugPrint('🪟 System alert window status: $systemAlertStatus');
        
        if (!systemAlertStatus.isGranted) {
          final result = await Permission.systemAlertWindow.request();
          debugPrint('🪟 System alert window result: $result');
        }
      } catch (error) {
        debugPrint('⚠️  System alert window request failed: $error');
      }
    }

    debugPrint('🔔 ========== PERMISSIONS CHECK COMPLETE ==========');
    debugPrint('');
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (!_initialized) {
      debugPrint('❌ Cannot schedule notification - service not initialized');
      return;
    }
    
    if (task.id == null || !task.notificationEnabled) {
      debugPrint('⏭️  Task ${task.id} - notification disabled or no ID');
      return;
    }
    
    if (task.dueDate == null) {
      debugPrint('⏭️  Task ${task.id} - no due date set');
      return;
    }

    debugPrint('');
    debugPrint('🔔 ========== SCHEDULING NOTIFICATION ==========');
    debugPrint('📝 Task ID: ${task.id}');
    debugPrint('📝 Task Title: ${task.title}');
    debugPrint('📅 Due Date: ${task.dueDate}');
    debugPrint('⏰ Remind: ${task.notificationMinutesBefore} minutes before');
    
    final now = DateTime.now();
    final lead = Duration(minutes: task.notificationMinutesBefore.clamp(0, 10080)); // Max 1 week
    final scheduledTime = task.dueDate!.subtract(lead);

    debugPrint('🕐 Current time: $now');
    debugPrint('🕐 Scheduled time: $scheduledTime');
    debugPrint('⏱️  Time difference: ${scheduledTime.difference(now).inMinutes} minutes');

    DateTime targetTime;
    if (scheduledTime.isBefore(now) || scheduledTime.isAtSameMomentAs(now)) {
      // If scheduled time has passed, check if due date is still in future
      if (task.dueDate!.isBefore(now)) {
        debugPrint('❌ Task ${task.id} - due date is in the past, skipping');
        return;
      }
      // Schedule for 1 minute from now if the time has already passed
      targetTime = now.add(const Duration(minutes: 1));
      debugPrint('⚠️  Scheduled time passed, will notify in 1 minute instead');
      debugPrint('   Original scheduled time was: $scheduledTime');
      debugPrint('   Adjusted to: $targetTime');
    } else {
      targetTime = scheduledTime;
      final minutesUntil = targetTime.difference(now).inMinutes;
      final secondsUntil = targetTime.difference(now).inSeconds;
      debugPrint('✅ Will notify in $minutesUntil minutes ($secondsUntil seconds)');
    }

    // HIGH PRIORITY settings for Android 8+ with background support
    final androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'High priority notifications for task reminders',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: const Color(0xFF00FF00),
      ledOnMs: 1000,
      ledOffMs: 500,
      ticker: 'Task reminder',
      sound: _soundOption.androidUri != null
          ? UriAndroidNotificationSound(_soundOption.androidUri!)
          : const RawResourceAndroidNotificationSound('notification'),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ongoing: false,
      autoCancel: true,
      onlyAlertOnce: false,
      showWhen: true,
      when: targetTime.millisecondsSinceEpoch,
      usesChronometer: false,
      channelShowBadge: true,
      showProgress: false,
      styleInformation: BigTextStyleInformation(
        'Due: ${task.readableDueDate}',
        htmlFormatBigText: false,
        contentTitle: '⏰ ${task.title}',
        htmlFormatContentTitle: false,
        summaryText: 'Task Reminder',
        htmlFormatSummaryText: false,
      ),
    );

    final iosDetails = DarwinNotificationDetails(
      sound: _soundOption.iosSound,
      presentBadge: true,
      presentAlert: true,
      presentSound: true,
    );

    try {
      // Convert to TZDateTime
      debugPrint('🌍 Converting to timezone...');
      debugPrint('   Local timezone: ${tz.local.name}');
      
      final tzDateTime = tz.TZDateTime.from(targetTime, tz.local);
      final tzNow = tz.TZDateTime.now(tz.local);
      
      debugPrint('🕐 TZ Current time: $tzNow');
      debugPrint('🕐 TZ Scheduled time: $tzDateTime');
      debugPrint('⏱️  TZ Time difference: ${tzDateTime.difference(tzNow).inSeconds} seconds');
      
      // Double check the time is in the future
      if (tzDateTime.isBefore(tzNow) || tzDateTime.isAtSameMomentAs(tzNow)) {
        debugPrint('⚠️  WARNING: Scheduled time is not in future!');
        debugPrint('   Adjusting to 15 seconds from now for testing...');
        final adjustedTime = tzNow.add(const Duration(seconds: 15));
        
        debugPrint('📤 Calling zonedSchedule with adjusted time: $adjustedTime');
        
        final scheduleMode = Platform.isAndroid 
            ? AndroidScheduleMode.alarmClock 
            : AndroidScheduleMode.exactAllowWhileIdle;
        
        await _plugin.zonedSchedule(
          task.id!,
          '⏰ ${task.title}',
          'Due: ${task.readableDueDate}',
          adjustedTime,
          NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id.toString(),
        );
        debugPrint('✅ Notification scheduled for 15 seconds from now with $scheduleMode mode');
      } else {
        debugPrint('📤 Calling zonedSchedule...');
        // Try alarmClock mode for Android - more aggressive and reliable
        final scheduleMode = Platform.isAndroid 
            ? AndroidScheduleMode.alarmClock 
            : AndroidScheduleMode.exactAllowWhileIdle;
        
        debugPrint('📱 Using schedule mode: ${Platform.isAndroid ? "alarmClock (Android)" : "exactAllowWhileIdle"}');
        
        await _plugin.zonedSchedule(
          task.id!,
          '⏰ ${task.title}',
          'Due: ${task.readableDueDate}',
          tzDateTime,
          NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id.toString(),
        );
        debugPrint('✅ zonedSchedule called successfully with $scheduleMode mode');
      }
      
      // Verify it was scheduled
      debugPrint('🔍 Verifying notification was scheduled...');
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint('📋 Total pending notifications: ${pending.length}');
      
      final isScheduled = pending.any((n) => n.id == task.id);
      if (isScheduled) {
        debugPrint('✅✅✅ SUCCESS: Notification IS in pending queue!');
        final notification = pending.firstWhere((n) => n.id == task.id);
        debugPrint('   ID: ${notification.id}');
        debugPrint('   Title: ${notification.title}');
        debugPrint('   Body: ${notification.body}');
      } else {
        debugPrint('❌❌❌ ERROR: Notification NOT found in pending queue!');
        debugPrint('   Expected ID: ${task.id}');
        debugPrint('   Pending IDs: ${pending.map((n) => n.id).toList()}');
      }
      
      debugPrint('🔔 ========== END SCHEDULING ==========');
      debugPrint('');
          
    } catch (error, stackTrace) {
      debugPrint('❌❌❌ EXCEPTION while scheduling notification!');
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('🔔 ========== END SCHEDULING (WITH ERROR) ==========');
      debugPrint('');
    }
  }

  Future<void> cancelTaskNotification(int taskId) async {
    if (!_initialized) return;
    await _plugin.cancel(taskId);
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  Future<void> rescheduleForTasks(List<Task> tasks) async {
    if (!_initialized) return;

    try {
      await cancelAll();
      int scheduled = 0;
      for (final task in tasks) {
        if (!task.notificationEnabled) continue;
        await scheduleTaskNotification(task);
        scheduled++;
        if (task.isRepeating) {
          final next = RecurrenceUtils.nextOccurrence(task);
          if (next != null &&
              task.repeatEndDate != null &&
              next.isAfter(task.repeatEndDate!)) {
            await cancelTaskNotification(task.id!);
          }
        }
      }
      debugPrint('Scheduled $scheduled notifications');
    } catch (error, stackTrace) {
      debugPrint('Failed to reschedule notifications: $error');
      debugPrint('$stackTrace');
    }
  }

  /// Test notification - shows immediately
  Future<void> showTestNotification() async {
    if (!_initialized) {
      debugPrint('Cannot show test notification - service not initialized');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for due tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'Test notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentBadge: true,
      presentAlert: true,
      presentSound: true,
    );

    try {
      await _plugin.show(
        999999,
        'Test Notification',
        'If you see this, notifications are working!',
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
      debugPrint('Test notification shown');
    } catch (error, stackTrace) {
      debugPrint('Failed to show test notification: $error');
      debugPrint('$stackTrace');
    }
  }

  /// Test scheduled notification - fires in 30 seconds
  Future<void> showScheduledTestNotification() async {
    if (!_initialized) {
      debugPrint('Cannot show scheduled test - service not initialized');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for due tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ticker: 'Scheduled test',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentBadge: true,
      presentAlert: true,
      presentSound: true,
    );

    try {
      final scheduledTime = DateTime.now().add(const Duration(seconds: 30));
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
      
      debugPrint('🧪 TEST: Scheduling for 30 seconds from now');
      debugPrint('   Current: ${tz.TZDateTime.now(tz.local)}');
      debugPrint('   Scheduled: $tzDateTime');
      
      // Use alarmClock mode for Android for maximum reliability
      final scheduleMode = Platform.isAndroid 
          ? AndroidScheduleMode.alarmClock 
          : AndroidScheduleMode.exactAllowWhileIdle;
      
      await _plugin.zonedSchedule(
        999998,
        '⏰ Scheduled Test',
        'This notification was scheduled 30 seconds ago!',
        tzDateTime,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      debugPrint('✅ Test notification scheduled with $scheduleMode mode');
      
      // Verify
      final pending = await _plugin.pendingNotificationRequests();
      final isScheduled = pending.any((n) => n.id == 999998);
      debugPrint(isScheduled 
          ? '✅ Test notification IS in pending queue' 
          : '❌ Test notification NOT in pending queue');
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to schedule test notification: $error');
      debugPrint('$stackTrace');
    }
  }

  /// Get count of pending notifications
  Future<int> getPendingNotificationCount() async {
    if (!_initialized) {
      debugPrint('Cannot get pending notifications - service not initialized');
      return 0;
    }
    
    try {
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint('📋 Pending notifications: ${pending.length}');
      
      if (pending.isEmpty) {
        debugPrint('No pending notifications scheduled');
      } else {
        for (final notification in pending) {
          debugPrint('  ⏰ ID: ${notification.id}, Title: ${notification.title ?? "No title"}');
          if (notification.body != null) {
            debugPrint('     Body: ${notification.body}');
          }
        }
      }
      
      return pending.length;
    } catch (error, stackTrace) {
      debugPrint('❌ Error getting pending notifications: $error');
      debugPrint('Stack trace: $stackTrace');
      return 0;
    }
  }
}
