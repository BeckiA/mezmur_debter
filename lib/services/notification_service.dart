import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> _checkExactAlarmPermission() async {
    try {
      // First check if we already have permission
      final status = await Permission.scheduleExactAlarm.status;
      if (status.isGranted) {
        return true;
      }

      // If not, request it
      final requestedStatus = await Permission.scheduleExactAlarm.request();
      return requestedStatus.isGranted;
    } catch (e) {
      print('Permission check error: $e');
      return false; // Default to false if there's an error
    }
  }

  Future<void> scheduleDailyNotification([String verse = ""]) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_verse_channel_id',
      'Daily Verse Notifications',
      channelDescription: 'Receive a daily Bible verse notification',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, // Use UTC+3 time zone
      now.year,
      now.month,
      now.day,
      17, // hour (8 AM in 24-hour format)
      45, // minute
    );
    // print('Scheduled date: $scheduledDate');
    print('Current date: $now');
    print("Local time zone: ${tz.local}");
    if (scheduledDate.isBefore(now)) {
      print('Scheduled date is before now, adding one day');
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      final hasExactPermission = await _checkExactAlarmPermission();
      print('Exact alarm permission granted: $hasExactPermission');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Verse of the Day',
        verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: hasExactPermission
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      final isScheduled = await checkNotificationScheduled();
      if (isScheduled) {
        print('Notification scheduled successfully!');
      } else {
        print('Failed to schedule notification.');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      // Fallback to inexact scheduling
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Verse of the Day',
        verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<bool> checkNotificationScheduled() async {
    final pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pending.any((notification) => notification.id == 0);
  }
}
