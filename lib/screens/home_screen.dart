import 'package:flutter/material.dart';
import 'package:hymn_app/screens/Detail_Screens/hymn_detail_screen.dart';
import 'package:hymn_app/services/bible_service.dart';
import 'package:hymn_app/widgets/daily_verse.dart' show DailyVerse;
import 'package:hymn_app/widgets/hymn_preview.dart';
import 'package:hymn_app/widgets/search_bar.dart' show SearchBarItem;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  Map<String, String>? verse;
  List<Map<String, dynamic>> recentHymns = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerse();
    _loadRecentHymns();
  }

  Future<void> _loadVerse() async {
    final dailyVerse = await BibleService.getVerseOfDay();
    setState(() {
      verse = dailyVerse;
      isLoading = false;
    });
  }

  void _loadRecentHymns() {
    recentHymns = [
      {
        'id': 1,
        'number': 123,
        'title': 'ክርስቶስ ተነሳ',
        'firstLine': 'ክርስቶስ ተነሳ ከሙታን',
      },
      {
        'id': 2,
        'number': 145,
        'title': 'ለእግዚአብሔር ዘምሩ',
        'firstLine': 'ለእግዚአብሔር ዘምሩ አዲስ ዝማሬ',
      },
      {
        'id': 3,
        'number': 178,
        'title': 'ቅዱስ ቅዱስ ቅዱስ',
        'firstLine': 'ቅዱስ ቅዱስ ቅዱስ እግዚአብሔር',
      },
    ];
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.length > 2) {
        // searchResults = searchHymns(query);
      } else {
        searchResults = [];
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

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('እባክዎን ይጠብቁ...', style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'የኢትዮጵያ ኦርቶዶክስ ቤተክርስቲያን',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text('የምስጋና መዝሙሮች', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SearchBarItem(
              placeholder: 'ፈልግ በቁጥር ወይም በስም...',
              value: searchQuery,
              onChanged: _handleSearch,
            ),
            const SizedBox(height: 16),
            if (searchResults.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('የፍለጋ ውጤቶች', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...searchResults.map(
                    (hymn) => HymnPreview(
                      hymn: hymn,
                      onTap: () => _navigateToHymn(context, hymn['id']),
                    ),
                  ),
                ],
              )
            else ...[
              if (verse != null) DailyVerse(verse: verse!),
              const SizedBox(height: 24),
              Text('የቅርብ ጊዜ መዝሙሮች', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ...recentHymns.map(
                (hymn) => HymnPreview(
                  hymn: hymn,
                  onTap: () => _navigateToHymn(context, hymn['id']),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/hymns'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C), // Deep purple
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'ሁሉንም መዝሙሮች ይመልከቱ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
