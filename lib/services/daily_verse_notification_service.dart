import 'package:hymn_app/services/bible_service.dart';
import 'package:hymn_app/services/notification_service.dart';

/// Service class to initialize and manage daily verse notifications.
/// Ensures the scheduled notification uses the same verse as displayed in the home screen.
class DailyVerseNotificationService {
  static final DailyVerseNotificationService _instance =
      DailyVerseNotificationService._internal();

  factory DailyVerseNotificationService() {
    return _instance;
  }

  DailyVerseNotificationService._internal();

  /// Initializes the daily verse notification by:
  /// 1. Getting the verse of the day from BibleService (same as home screen)
  /// 2. Formatting it for notification display
  /// 3. Scheduling it using NotificationService
  Future<void> initializeDailyVerseNotification() async {
    try {
      // Get the verse of the day - same method used in home_screen.dart
      final verse = await BibleService.getVerseOfDay();

      // Extract verse text and reference separately
      final verseText = verse['text'] ?? '';
      final reference = verse['reference'] ?? '';

      // Schedule the daily notification with verse text and reference
      // Reference will appear in the title, verse text in the body
      await NotificationService().scheduleDailyNotification(
        verseText.isNotEmpty ? verseText : "Stay inspired with daily verses!",
        reference,
      );

      print('Daily verse notification initialized successfully');
      print('Verse: $verseText');
      print('Reference: $reference');
    } catch (e) {
      print('Error initializing daily verse notification: $e');
      // Schedule a default notification if there's an error
      await NotificationService().scheduleDailyNotification(
        "Stay inspired with daily verses!",
        "",
      );
    }
  }

  /// Checks if the daily verse notification is already scheduled
  Future<bool> isNotificationScheduled() async {
    return await NotificationService().checkNotificationScheduled();
  }

  /// Reschedules the daily verse notification with the current day's verse
  /// Useful for updating the notification when needed
  Future<void> rescheduleNotification() async {
    await initializeDailyVerseNotification();
  }
}

