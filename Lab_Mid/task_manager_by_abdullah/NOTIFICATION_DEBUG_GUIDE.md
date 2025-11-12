# Notification Debugging Guide

## 🔍 How to Debug Notifications

I've added comprehensive logging and a debug page to help identify why scheduled notifications aren't working.

### 📱 Step 1: Open Notification Debug Page

1. Open the app
2. Go to **Settings**
3. Tap **"Notification Debug"** (new option at the top)

### 🧪 Step 2: Test Immediate Notification

1. In Debug page, tap **"Test" under "Immediate Notification"**
2. ✅ Notification should appear instantly
3. If this works, the notification system is functional

### ⏰ Step 3: Test Scheduled Notification

1. In Debug page, adjust seconds (default 30)
2. Tap **"Schedule"**
3. **CLOSE THE APP COMPLETELY** (swipe away from recent apps)
4. Wait for the scheduled time
5. ✅ Notification should appear

### 📊 Step 4: Check Console Logs

When you create a task with notification, watch the console for detailed logs:

```
🔔 ========== SCHEDULING NOTIFICATION ==========
📝 Task ID: 1
📝 Task Title: Buy groceries
📅 Due Date: 2024-11-08 15:30:00.000
⏰ Remind: 30 minutes before
🕐 Current time: 2024-11-08 15:00:00.000
🕐 Scheduled time: 2024-11-08 15:00:00.000
⏱️  Time difference: 0 minutes
⚠️  Scheduled time passed, will notify in 10 seconds
🌍 Converting to timezone...
   Local timezone: UTC
🕐 TZ Current time: 2024-11-08 15:00:00.000Z
🕐 TZ Scheduled time: 2024-11-08 15:00:10.000Z
⏱️  TZ Time difference: 10 seconds
📤 Calling zonedSchedule...
✅ zonedSchedule called successfully
🔍 Verifying notification was scheduled...
📋 Total pending notifications: 1
✅✅✅ SUCCESS: Notification IS in pending queue!
   ID: 1
   Title: ⏰ Buy groceries
   Body: Due: Today • 3:30 PM
🔔 ========== END SCHEDULING ==========
```

## 🚨 Common Issues & Solutions

### Issue 1: Time Difference Shows 0 or Negative

**Log shows**:
```
⏱️  Time difference: 0 minutes
⚠️  Scheduled time passed, will notify in 10 seconds
```

**Cause**: You're setting a due time that's already passed, or the reminder time makes it in the past.

**Solution**: 
- Set due time at least 1 minute in the future
- If using "At time", set due time in future
- If using "30 min before", set due time at least 30 minutes in future

### Issue 2: Notification NOT in Pending Queue

**Log shows**:
```
❌❌❌ ERROR: Notification NOT found in pending queue!
   Expected ID: 1
   Pending IDs: []
```

**Causes**:
1. Exact alarm permission not granted
2. Battery optimization killing the app
3. Do Not Disturb blocking notifications

**Solutions**:
1. **Grant Exact Alarm Permission**:
   - Settings → Apps → Task Manager → Alarms & reminders → **Allow**

2. **Disable Battery Optimization**:
   - Settings → Apps → Task Manager → Battery → **Unrestricted**

3. **Check Do Not Disturb**:
   - Settings → Sound → Do Not Disturb → **Off** or add Task Manager to priority

4. **Manufacturer Settings** (Xiaomi, Huawei, Oppo, Samsung):
   - Enable "Autostart" or "Background running"

### Issue 3: Exception While Scheduling

**Log shows**:
```
❌❌❌ EXCEPTION while scheduling notification!
Error: [error message]
```

**Solution**: Check the error message for specific issue. Common errors:
- Permission denied → Grant permissions
- Invalid time → Check due date is in future
- Plugin not initialized → Restart app

### Issue 4: Notification Scheduled But Doesn't Fire

**Log shows**:
```
✅✅✅ SUCCESS: Notification IS in pending queue!
```

But notification doesn't appear at scheduled time.

**Causes**:
1. App killed by system
2. Battery saver active
3. Do Not Disturb enabled

**Solutions**:
1. **Keep App in Memory**:
   - Don't force close the app
   - Let it run in background

2. **Disable Battery Saver**:
   - Turn off battery saver mode

3. **Check Notification Settings**:
   - Settings → Apps → Task Manager → Notifications → **Allowed**
   - Make sure "Task Reminders" channel is enabled

## 📋 Testing Checklist

### ✅ Basic Tests

- [ ] Immediate notification works
- [ ] 30-second scheduled notification works (with app closed)
- [ ] Can see pending notifications count
- [ ] Console shows detailed logs

### ✅ Permission Tests

- [ ] Notification permission granted
- [ ] Exact alarm permission granted (Android 12+)
- [ ] Battery optimization disabled
- [ ] Autostart enabled (manufacturer specific)

### ✅ Real Task Tests

- [ ] Create task due in 2 minutes with "At time" reminder
- [ ] Save task
- [ ] Check console logs show "SUCCESS: Notification IS in pending queue"
- [ ] Close app
- [ ] Wait 2 minutes
- [ ] Notification appears

## 🔧 How to Share Logs

If notifications still don't work, share the console logs:

1. Run app with: `flutter run`
2. Create a task with notification
3. Copy the entire log output between:
   ```
   🔔 ========== SCHEDULING NOTIFICATION ==========
   ...
   🔔 ========== END SCHEDULING ==========
   ```
4. Share this log for debugging

## 📱 Quick Test Procedure

1. **Open app**
2. **Go to Settings → Notification Debug**
3. **Test immediate** (should work instantly)
4. **Schedule for 30 seconds**
5. **Close app completely**
6. **Wait 30 seconds**
7. **Check if notification appears**

If step 3 works but step 7 doesn't, it's a permission or battery optimization issue.

## 🎯 Expected Behavior

### When Creating Task:
1. Console shows detailed scheduling logs
2. Logs confirm notification in pending queue
3. No error messages

### At Notification Time:
1. Device wakes up (if sleeping)
2. Notification appears with sound/vibration
3. Tapping notification opens app
4. Works even if app was closed

### When Viewing Pending:
1. Shows correct count
2. Console lists all pending notifications
3. No crashes

## ✅ Success Indicators

You'll know notifications are working when you see:

```
✅✅✅ SUCCESS: Notification IS in pending queue!
```

And the notification actually appears at the scheduled time.

## 🆘 Still Not Working?

If notifications still don't fire after following this guide:

1. Check manufacturer-specific settings (Xiaomi, Huawei, etc.)
2. Try on a different Android device
3. Share the console logs for further debugging
4. Check if other apps' notifications work on your device

The detailed logs will help identify exactly where the issue is!

