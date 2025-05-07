import 'package:flutter/material.dart';
import 'package:hymn_app/layouts/tab_layout.dart';
import 'package:hymn_app/providers/theme_provider.dart';
import 'package:hymn_app/theme/theme_store.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
      home: TabLayout(),
      darkTheme: darkTheme,
      theme: lightTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
