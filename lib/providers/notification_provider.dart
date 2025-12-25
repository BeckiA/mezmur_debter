import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hymn_app/services/notification_service.dart';
import 'package:hymn_app/services/daily_verse_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _permissionRequested = false;
  bool _isInitialized = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get permissionRequested => _permissionRequested;
  bool get isInitialized => _isInitialized;

  NotificationProvider() {
    // Start initialization in background
    _initialize();
  }

  /// Initialize the provider by loading preferences
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _loadNotificationPreference();
      await _checkPermissionStatus();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _initialize() async {
    await _loadNotificationPreference();
    await _checkPermissionStatus();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _permissionRequested = prefs.getBool('notificationPermissionRequested') ?? false;
  }

  Future<void> _checkPermissionStatus() async {
    final status = await NotificationService().checkNotificationPermission();
    // If permission was denied and user previously had notifications enabled,
    // we should update the UI state
    if (!status && _notificationsEnabled) {
      // Keep the preference as is, but user will need to grant permission
    }
  }

  Future<bool> requestPermission() async {
    final granted = await NotificationService().requestNotificationPermission();
    if (granted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationPermissionRequested', true);
      _permissionRequested = true;
      notifyListeners();
    }
    return granted;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;

    _notificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);

    if (enabled) {
      // Check if we have permission first
      final hasPermission = await NotificationService().checkNotificationPermission();
      if (!hasPermission) {
        // Request permission if not granted
        final granted = await requestPermission();
        if (granted) {
          // Schedule notification if permission granted
          await DailyVerseNotificationService().initializeDailyVerseNotification();
        } else {
          // Permission denied, disable notifications
          _notificationsEnabled = false;
          await prefs.setBool('notificationsEnabled', false);
          notifyListeners();
        }
      } else {
        // Permission already granted, schedule notification
        await DailyVerseNotificationService().initializeDailyVerseNotification();
      }
    } else {
      // Cancel all scheduled notifications
      await NotificationService().cancelAllNotifications();
    }
  }

  Future<bool> shouldRequestPermissionOnFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final requested = prefs.getBool('notificationPermissionRequested') ?? false;
    return !requested;
  }
}

