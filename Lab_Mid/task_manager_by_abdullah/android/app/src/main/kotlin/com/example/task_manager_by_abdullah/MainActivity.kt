package com.example.task_manager_by_abdullah

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "task_manager/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create notification channel for Android 8+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canScheduleExactAlarms" -> {
                        result.success(canScheduleExactAlarms())
                    }

                    "requestExactAlarmPermission" -> {
                        requestExactAlarmPermission()
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "task_reminders"
            val channelName = "Task Reminders"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = "High priority notifications for task reminders"
                enableLights(true)
                lightColor = android.graphics.Color.GREEN
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 250, 500)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun canScheduleExactAlarms(): Boolean {
        // Android 12 (API 31) and above require special permission
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            android.util.Log.d("MainActivity", "Android < 12: Exact alarms allowed by default")
            return true
        }
        
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val canSchedule = alarmManager.canScheduleExactAlarms()
        
        android.util.Log.d("MainActivity", "Android 12+: Can schedule exact alarms = $canSchedule")
        
        return canSchedule
    }

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            android.util.Log.d("MainActivity", "Android < 12: No permission needed")
            return
        }

        android.util.Log.d("MainActivity", "Opening exact alarm permission settings...")

        try {
            // Try the specific exact alarm settings first (Android 12+)
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            if (intent.resolveActivity(packageManager) != null) {
                android.util.Log.d("MainActivity", "Opening ACTION_REQUEST_SCHEDULE_EXACT_ALARM")
                startActivity(intent)
            } else {
                // Fallback to app details
                android.util.Log.d("MainActivity", "Fallback to app details settings")
                val fallbackIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(fallbackIntent)
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error opening settings: ${e.message}")
            e.printStackTrace()
        }
    }
}
