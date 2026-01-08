import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/hymn.dart';

class HymnService {
  static List<Hymn>? _hymns;
  static bool _isLoaded = false;

  // Parse JSON data in background isolate
  static List<Hymn> _parseHymnsJson(String jsonString) {
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> hymnJson = entry.value;
      return Hymn.fromJson(hymnJson, index + 1);
    }).toList();
  }

  // Load hymns from JSON file
  static Future<void> _loadHymns() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/data/lyrics_data.json',
      );
      
      // Parse JSON in background isolate to avoid blocking main thread
      _hymns = await compute(_parseHymnsJson, jsonString);

      _isLoaded = true;
    } catch (e) {
      print('Error loading hymns: $e');
      _hymns = [];
      _isLoaded = true;
    }
  }

  // Get all hymns
  static Future<List<Hymn>> getAllHymns() async {
    await _loadHymns();
    return _hymns ?? [];
  }

  // Get hymn by ID
  static Future<Hymn?> getHymnById(int id) async {
    await _loadHymns();
    try {
      return _hymns?.firstWhere((hymn) => hymn.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get hymn by number (if number is available)
  static Future<Hymn?> getHymnByNumber(int number) async {
    await _loadHymns();
    try {
      return _hymns?.firstWhere((hymn) => hymn.number == number);
    } catch (e) {
      return null;
    }
  }

  // Search hymns - only searches in title and search terms
  static Future<List<Hymn>> searchHymns(String query) async {
    await _loadHymns();
    if (_hymns == null) return [];

    if (query.trim().isEmpty) return _hymns!;

    final lowercaseQuery = query.toLowerCase().trim();
    final queryWords =
        lowercaseQuery.split(' ').where((word) => word.isNotEmpty).toList();

    return _hymns!.where((hymn) {
      // Search by ID
      if (hymn.id.toString().contains(lowercaseQuery)) return true;

      // Search by number
      if (hymn.number != null &&
          hymn.number.toString().contains(lowercaseQuery)) {
        return true;
      }

      // Search in title (priority 1) - Amharic text
      final titleLower = hymn.title;
      if (titleLower.contains(lowercaseQuery)) return true;

      // Check if all query words are in title
      if (queryWords.every((word) => titleLower.contains(word))) return true;

      // Search in search terms - Amharic text
      if (hymn.searchTerms != null) {
        for (String term in hymn.searchTerms!) {
          final termLower = term.toLowerCase();
          if (termLower.contains(lowercaseQuery)) return true;

          // Check if all query words are in any search term
          if (queryWords.every((word) => termLower.contains(word))) return true;
        }
      }

      return false;
    }).toList();
  }
    // Get total hymn count
  static Future<int> getHymnCount() async {
    await _loadHymns();
    return _hymns?.length ?? 0;
  }

  // Get random hymn
  static Future<Hymn?> getRandomHymn() async {
    await _loadHymns();
    if (_hymns == null || _hymns!.isEmpty) return null;

    final random = DateTime.now().millisecondsSinceEpoch % _hymns!.length;
    return _hymns![random];
  }
}
