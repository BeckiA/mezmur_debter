import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hymn_app/screens/Detail_Screens/hymn_detail_screen.dart';
import 'package:hymn_app/services/bible_service.dart';
import 'package:hymn_app/services/hymn_service.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/widgets/custom_app_bar.dart';
import 'package:hymn_app/widgets/daily_verse.dart' show DailyVerse;
import 'package:hymn_app/widgets/hymn_preview.dart';
import 'package:hymn_app/widgets/search_bar.dart' show SearchBarItem;
import 'package:hymn_app/layouts/tab_layout.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  Map<String, String>? verse;
  List<Hymn> recentHymns = [];
  List<Hymn> searchResults = [];
  bool isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadVerse();
    _loadRecentHymns();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadVerse() async {
    final dailyVerse = await BibleService.getVerseOfDay();
    setState(() {
      verse = dailyVerse;
      isLoading = false;
    });
  }

  Future<void> _loadRecentHymns() async {
    try {
      final allHymns = await HymnService.getAllHymns();
      setState(() {
        // Take first 3 hymns as recent hymns
        recentHymns = allHymns.take(3).toList();
      });
    } catch (e) {
      print('Error loading recent hymns: $e');
      setState(() {
        recentHymns = [];
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    setState(() {
      searchQuery = query;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set a new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        if (query.trim().isEmpty) {
          setState(() {
            searchResults = [];
          });
        } else {
          final results = await HymnService.searchHymns(query);
          setState(() {
            searchResults = results;
          });
        }
      } catch (e) {
        print('Error searching hymns: $e');
        setState(() {
          searchResults = [];
        });
      }
    });
  }

  void _navigateToHymn(BuildContext context, int hymnId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HymnDetailScreen(hymnId: hymnId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    if (isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'የአምልኮና የምስጋና መዝሙሮች'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('እባክዎን ይጠብቁ...', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'የአምልኮና የምስጋና መዝሙሮች'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBarItem(
              placeholder: 'በቁጥር ወይም በስም ፈልግ...',
              value: searchQuery,
              onChanged: _handleSearch,
            ),
            const SizedBox(height: 24),
            if (searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'የፍለጋ ውጤቶች',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: fontFamilyProvider.fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...searchResults.map(
                    (hymn) => HymnPreview(
                      hymn: hymn,
                      onTap: () => _navigateToHymn(context, hymn.id),
                    ),
                  ),
                ],
              )
            else ...[
              if (verse != null) DailyVerse(verse: verse!),
              const SizedBox(height: 24),
              Text(
                'የቅርብ ጊዜ መዝሙሮች',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...recentHymns.map(
                (hymn) => HymnPreview(
                  hymn: hymn,
                  onTap: () => _navigateToHymn(context, hymn.id),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the next tab (Hymns tab at index 1)
                    final tabLayout =
                        context.findAncestorStateOfType<TabLayoutState>();
                    if (tabLayout != null) {
                      tabLayout.navigateToTab(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C), // Deep purple
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  child:  Text(
                    'ሁሉንም መዝሙሮች ይመልከቱ',
                     style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
