import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hymn_app/layouts/tab_layout.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState>? navigatorKey;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/mezmur_debter_logo');

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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap or action
    if (response.actionId == 'read_action' || response.actionId == null) {
      // Navigate to hymn screen (tab index 1)
      if (navigatorKey?.currentState != null) {
        navigatorKey!.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TabLayout(initialIndex: 0)),
          (route) => false,
        );
      }
    }
  }

  /// Check if notification permission is granted
  Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking notification permission: $e');
      // On Android < 13, notifications are enabled by default
      return true;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
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

  /// Schedule a single notification for a specific date and time
  Future<void> scheduleNotificationForDate(
    int notificationId,
    tz.TZDateTime scheduledDate,
    String verse,
    String reference,
  ) async {
    // Create action buttons
    const readAction = AndroidNotificationAction(
      'read_action',
      'አንብብ',
      showsUserInterface: true,
    );

    // Format the content title with reference if available
    String contentTitle = 'የዕለቱ የመጽሐፍ ቅዱስ ጥቅስ';
    if (reference.isNotEmpty) {
      contentTitle = '$contentTitle - $reference';
    }

    // Create BigTextStyleInformation for expanded notification
    final bigTextStyleInformation = BigTextStyleInformation(
      verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
      contentTitle: contentTitle,
      htmlFormatBigText: true,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_verse_channel_id',
      'Daily Verse Notifications',
      channelDescription: 'Receive a daily Bible verse notification',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      icon: 'notification_icon',
      styleInformation: bigTextStyleInformation,
      actions: [readAction],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'daily_verse_category',
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      final hasExactPermission = await _checkExactAlarmPermission();
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        contentTitle,
        verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: hasExactPermission
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      print('Error scheduling notification $notificationId: $e');
      // Fallback scheduling without exact alarm
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        contentTitle,
        verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Legacy method kept for backward compatibility
  /// Now delegates to scheduleNotificationForDate for a single notification
  Future<void> scheduleDailyNotification([String verse = "", String reference = ""]) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10, // hour (10 AM in 24-hour format)
      24, // minute
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotificationForDate(0, scheduledDate, verse, reference);
    print('Daily verse notification scheduled for: $scheduledDate');
  }

  Future<bool> checkNotificationScheduled() async {
    final pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    // Check if any daily verse notifications are scheduled (IDs 0-29)
    return pending.any((notification) => notification.id >= 0 && notification.id < 30);
  }
}
