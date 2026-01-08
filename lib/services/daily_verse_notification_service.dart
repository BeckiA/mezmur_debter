import 'package:hymn_app/services/bible_service.dart';
import 'package:hymn_app/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

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
  /// 1. Pre-loading Bible verses once
  /// 2. Scheduling notifications for the next 30 days
  /// 3. Each notification gets the correct verse for that specific day
  /// 4. This ensures users always get the current day's verse, not yesterday's
  Future<void> initializeDailyVerseNotification() async {
    try {
      // Pre-load Bible verses once to avoid repeated async calls
      await BibleService.getVerseOfDay();
      
      // Cancel all existing notifications first
      await NotificationService().cancelAllNotifications();

      final now = DateTime.now();
      final baseDate = DateTime(now.year, now.month, now.day, 10, 24);
      
      // Start from tomorrow if the scheduled time has passed today
      int daysToAdd = baseDate.isBefore(now) ? 1 : 0;
      
      // Schedule notifications for the next 30 days, each with the correct verse
      // Use sync method since verses are already loaded
      int scheduledCount = 0;
      for (int i = 0; i < 30; i++) {
        final targetDate = baseDate.add(Duration(days: daysToAdd + i));
        final tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          10,
          24,
        );

        // Get the verse for this specific date (synchronous since verses are pre-loaded)
        final verse = BibleService.getVerseForDateSync(targetDate);
        final verseText = verse['text'] ?? '';
        final reference = verse['reference'] ?? '';

        // Schedule notification with unique ID (use day offset as ID)
        await NotificationService().scheduleNotificationForDate(
          i, // Use index as notification ID
          scheduledDate,
          verseText.isNotEmpty ? verseText : "Stay inspired with daily verses!",
          reference,
        );
        scheduledCount++;
        
        // Yield to event loop every 5 notifications to avoid blocking
        if (i % 5 == 4) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }

      print('Daily verse notifications initialized successfully');
      print('Scheduled $scheduledCount notifications for the next ${30 - daysToAdd} days');
    } catch (e) {
      print('Error initializing daily verse notifications: $e');
      // Fallback: schedule a single notification for tomorrow
      try {
        final now = DateTime.now();
        DateTime targetDate = DateTime(now.year, now.month, now.day, 10, 24);
        if (targetDate.isBefore(now)) {
          targetDate = targetDate.add(const Duration(days: 1));
        }
        final verse = await BibleService.getVerseForDate(targetDate);
        final verseText = verse['text'] ?? '';
        final reference = verse['reference'] ?? '';
        
        final tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          10,
          24,
        );
        
        await NotificationService().scheduleNotificationForDate(
          0,
          scheduledDate,
          verseText.isNotEmpty ? verseText : "Stay inspired with daily verses!",
          reference,
        );
      } catch (fallbackError) {
        print('Error in fallback notification scheduling: $fallbackError');
      }
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

