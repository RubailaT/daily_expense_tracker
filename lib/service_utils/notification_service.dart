// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class NotificationService {
//   final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   // Static constants
//   static const String _reminderTimeKey = 'reminder_time';
//   static const String _isReminderActiveKey = 'is_reminder_active';
//   static const int dailyReminderId = 0;
//   static const int weeklyDigestId = 1;
//   static const int instantNotificationId = 2;

//   // Channel IDs
//   static const String _dailyChannelId = 'expense_reminder';
//   static const String _weeklyChannelId = 'weekly_digest';
//   static const String _instantChannelId = 'instant_notifications';

//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     try {
//       final pendingNotifications =
//           await _notifications.pendingNotificationRequests();
//       print('Pending notifications: ${pendingNotifications.length}');
//       return pendingNotifications;
//     } catch (e) {
//       print('Error getting pending notifications: $e');
//       rethrow;
//     }
//   }

//   Future<List<ActiveNotification>?> getActiveNotifications() async {
//     try {
//       if (Platform.isAndroid) {
//         final activeNotifications = await _notifications
//             .resolvePlatformSpecificImplementation<
//                 AndroidFlutterLocalNotificationsPlugin>()
//             ?.getActiveNotifications();
//         print('Active notifications: ${activeNotifications?.length ?? 0}');
//         return activeNotifications;
//       }
//       return null;
//     } catch (e) {
//       print('Error getting active notifications: $e');
//       rethrow;
//     }
//   }

//   Future<void> cancelNotification(int id) async {
//     try {
//       await _notifications.cancel(id);
//       print('Cancelled notification with ID: $id');
//     } catch (e) {
//       print('Error cancelling notification: $e');
//       rethrow;
//     }
//   }

//   Future<NotificationDetails> getNotificationDetails({
//     required String channelId,
//     required String channelName,
//     required String channelDescription,
//   }) async {
//     final androidDetails = AndroidNotificationDetails(
//       channelId,
//       channelName,
//       channelDescription: channelDescription,
//       importance: Importance.max,
//       priority: Priority.high,
//       enableLights: true,
//       enableVibration: true,
//       playSound: true,
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     return NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//   }

//   Future<void> showScheduledNotification({
//     required String title,
//     required String body,
//     required int seconds,
//   }) async {
//     try {
//       const androidDetails = AndroidNotificationDetails(
//         'scheduled_channel',
//         'Scheduled Notifications',
//         channelDescription: 'Notifications that are scheduled for later',
//         importance: Importance.max,
//         priority: Priority.high,
//         enableLights: true,
//         enableVibration: true,
//         playSound: true,
//       );

//       const iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//       const details = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       final scheduledTime =
//           tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

//       await _notifications.zonedSchedule(
//         DateTime.now().millisecond, // Unique ID based on current time
//         title,
//         body,
//         scheduledTime,
//         details,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );
//       print('Scheduled notification for: $scheduledTime');
//     } catch (e) {
//       print('Error scheduling notification: $e');
//       rethrow;
//     }
//   }

//   // Helper method to create a unique notification ID
//   int _createUniqueId() {
//     return DateTime.now().millisecondsSinceEpoch.remainder(100000);
//   }

//   Future<void> initialize() async {
//     try {
//       tz.initializeTimeZones();

//       const androidSettings =
//           AndroidInitializationSettings('@mipmap/ic_launcher');
//       const iosSettings = DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//       );

//       const initializationSettings = InitializationSettings(
//         android: androidSettings,
//         iOS: iosSettings,
//       );

//       await _notifications.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: _onNotificationTap,
//       );

//       // Request permissions
//       if (Platform.isIOS) {
//         await _notifications
//             .resolvePlatformSpecificImplementation<
//                 IOSFlutterLocalNotificationsPlugin>()
//             ?.requestPermissions(
//               alert: true,
//               badge: true,
//               sound: true,
//             );
//       }
//       // else if (Platform.isAndroid) {
//       //   await _notifications
//       //       .resolvePlatformSpecificImplementation<
//       //           AndroidFlutterLocalNotificationsPlugin>()
//       //       ?.requestPermissions(
//       //         alert: true,
//       //         badge: true,
//       //         sound: true,
//       //       );
//       // }

//       print('Notification service initialized successfully');
//     } catch (e) {
//       print('Error initializing notification service: $e');
//       rethrow;
//     }
//   }

//   void _onNotificationTap(NotificationResponse response) {
//     print('Notification tapped: ${response.payload}');
//   }

//   Future<void> scheduleDailyReminder({
//     required TimeOfDay time,
//     required bool isActive,
//   }) async {
//     try {
//       if (!isActive) {
//         await cancelDailyReminder();
//         return;
//       }

//       const androidDetails = AndroidNotificationDetails(
//         _dailyChannelId,
//         'Expense Reminders',
//         channelDescription: 'Daily reminders to log expenses',
//         importance: Importance.max,
//         priority: Priority.high,
//         enableLights: true,
//         enableVibration: true,
//       );

//       const iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       const details = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       final scheduledTime = _nextInstanceOfTime(time);
//       print('Scheduling daily reminder for: ${scheduledTime.toString()}');

//       await _notifications.zonedSchedule(
//         dailyReminderId,
//         'Expense Reminder',
//         'Don\'t forget to log your expenses for today!',
//         scheduledTime,
//         details,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );

//       // Save settings
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_reminderTimeKey, '${time.hour}:${time.minute}');
//       await prefs.setBool(_isReminderActiveKey, isActive);

//       print('Daily reminder scheduled successfully');
//     } catch (e) {
//       print('Error scheduling daily reminder: $e');
//       rethrow;
//     }
//   }

//   Future<void> showInstantNotification({
//     required String title,
//     required String body,
//   }) async {
//     try {
//       const androidDetails = AndroidNotificationDetails(
//         _instantChannelId,
//         'Instant Notifications',
//         channelDescription: 'For immediate notifications',
//         importance: Importance.max,
//         priority: Priority.high,
//         enableLights: true,
//         enableVibration: true,
//       );

//       const iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       const details = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _notifications.show(
//         instantNotificationId,
//         title,
//         body,
//         details,
//       );

//       print('Instant notification sent successfully');
//     } catch (e) {
//       print('Error showing instant notification: $e');
//       rethrow;
//     }
//   }

//   // Helper methods
//   tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
//     final now = tz.TZDateTime.now(tz.local);
//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );

//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }

//     return scheduledDate;
//   }

//   // Getters for settings
//   Future<bool> isReminderActive() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_isReminderActiveKey) ?? false;
//   }

//   Future<TimeOfDay?> getReminderTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     final timeString = prefs.getString(_reminderTimeKey);
//     if (timeString != null) {
//       final parts = timeString.split(':');
//       return TimeOfDay(
//         hour: int.parse(parts[0]),
//         minute: int.parse(parts[1]),
//       );
//     }
//     return null;
//   }

//   // Cancellation methods
//   Future<void> cancelDailyReminder() async {
//     await _notifications.cancel(dailyReminderId);
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isReminderActiveKey, false);
//   }

//   Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isReminderActiveKey, false);
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// import 'package:shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _reminderTimeKey = 'reminder_time';
  static const String _isReminderActiveKey = 'is_reminder_active';
  static const int dailyReminderId = 0;
  static const int weeklyDigestId = 1;
  static const int instantNotificationId = 2;

  // Channel IDs
  static const String _dailyChannelId = 'expense_reminder';
  static const String _weeklyChannelId = 'weekly_digest';
  static const String _instantChannelId = 'instant_notifications';

  static const String reminderTimeKey = 'expense_reminder_time';
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _instantChannelId,
        'Instant Notifications',
        channelDescription: 'For immediate notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // await _notifications.show(
      //   instantNotificationId,
      //   title,
      //   body,
      //   details,
      // );

      print('Instant notification sent successfully');
    } catch (e) {
      print('Error showing instant notification: $e');
      rethrow;
    }
  }

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(settings);
  }

  Future<void> scheduleDaily(TimeOfDay reminderTime) async {
    // Cancel any existing notification
    await notificationsPlugin.cancel(0);

    // Save the reminder time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        reminderTimeKey, '${reminderTime.hour}:${reminderTime.minute}');

    // Calculate the next occurrence of the reminder time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      0,
      'Daily Expense Reminder',
      'Don\'t forget to log your expenses for today!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_expense_reminder',
          'Daily Expense Reminder',
          channelDescription: 'Daily reminder to log expenses',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<TimeOfDay?> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(reminderTimeKey);
    if (timeString == null) return null;

    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
