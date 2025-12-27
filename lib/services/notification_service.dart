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
          MaterialPageRoute(builder: (context) => TabLayout(initialIndex: 1)),
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

  Future<void> scheduleDailyNotification([String verse = ""]) async {
    // Create action buttons
    const readAction = AndroidNotificationAction(
      'read_action',
      'አንብብ',
      showsUserInterface: true,
    );

    // Create BigTextStyleInformation for expanded notification
    final bigTextStyleInformation = BigTextStyleInformation(
      verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
      contentTitle: 'የዕለቱ የመጽሐፍ ቅዱስ ጥቅስ',
      htmlFormatBigText: true,
      summaryText: 'የዕለቱ ጥቅስ',
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

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, // Use UTC+3 time zone
      now.year,
      now.month,
      now.day,
      10, // hour (8 AM in 24-hour format)
      24, // minute
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
        'የዕለቱ የመጽሐፍ ቅዱስ ጥቅስ',
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
      // Create BigTextStyleInformation for fallback
      final fallbackBigTextStyleInformation = BigTextStyleInformation(
        verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
        contentTitle: 'የዕለቱ የመጽሐፍ ቅዱስ ጥቅስ',
        htmlFormatBigText: true,
        summaryText: 'የዕለቱ ጥቅስ',
      );

      const fallbackReadAction = AndroidNotificationAction(
        'read_action',
        'አንብብ',
        showsUserInterface: true,
      );

      final fallbackAndroidDetails = AndroidNotificationDetails(
        'daily_verse_channel_id',
        'Daily Verse Notifications',
        channelDescription: 'Receive a daily Bible verse notification',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: 'notification_icon',
        styleInformation: fallbackBigTextStyleInformation,
        actions: [fallbackReadAction],
      );

      final fallbackNotificationDetails = NotificationDetails(
        android: fallbackAndroidDetails,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'የዕለቱ የመጽሐፍ ቅዱስ ጥቅስ',
        verse.isNotEmpty ? verse : "Stay inspired with daily verses!",
        scheduledDate,
        fallbackNotificationDetails,
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
