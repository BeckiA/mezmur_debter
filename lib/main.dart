import 'package:flutter/material.dart';
import 'package:hymn_app/layouts/tab_layout.dart';
import 'package:hymn_app/providers/theme_provider.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/providers/notification_provider.dart';
import 'package:hymn_app/services/notification_service.dart';
import 'package:hymn_app/services/daily_verse_notification_service.dart';
import 'package:hymn_app/theme/theme_store.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize timezones before using them
  tz.initializeTimeZones();
  final location = TZDateTime.now(local);
  print('Current time zone: ${location}');
  
  // Set up navigator key for notification navigation
  final navigatorKey = GlobalKey<NavigatorState>();
  NotificationService.navigatorKey = navigatorKey;
  
  await NotificationService().init();
  
  // Initialize notification provider and wait for it to load preferences
  final notificationProvider = NotificationProvider();
  await notificationProvider.initialize();
  
  // Request notification permission on first launch if needed
  final shouldRequest = await notificationProvider.shouldRequestPermissionOnFirstLaunch();
  if (shouldRequest) {
    final granted = await notificationProvider.requestPermission();
    if (granted) {
      // Initialize daily verse notification if permission granted and notifications enabled
      if (notificationProvider.notificationsEnabled) {
        await DailyVerseNotificationService().initializeDailyVerseNotification();
      }
    }
  } else {
    // Initialize daily verse notification if already enabled
    if (notificationProvider.notificationsEnabled) {
      await DailyVerseNotificationService().initializeDailyVerseNotification();
    }
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => FontFamilyProvider()),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Hymn App',
      navigatorKey: NotificationService.navigatorKey,
      home: TabLayout(),
      darkTheme: darkTheme,
      theme: lightTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
