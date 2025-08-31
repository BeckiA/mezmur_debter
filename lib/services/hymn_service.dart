import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hymn.dart';

class HymnService {
  static List<Hymn>? _hymns;
  static bool _isLoaded = false;

  // Load hymns from JSON file
  static Future<void> _loadHymns() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/data/lyrics_data.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      _hymns =
          jsonData.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> hymnJson = entry.value;
            return Hymn.fromJson(hymnJson, index + 1);
          }).toList();

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

  // Search hymns
  static Future<List<Hymn>> searchHymns(String query) async {
    await _loadHymns();
    if (_hymns == null) return [];

    if (query.trim().isEmpty) return _hymns!;

    final lowercaseQuery = query.toLowerCase().trim();
    final queryWords =
        lowercaseQuery.split(' ').where((word) => word.isNotEmpty).toList();

    return _hymns!.where((hymn) {
      // Search by ID (exact match for numbers)
      if (RegExp(r'^\d+$').hasMatch(query) && hymn.id.toString() == query) {
        return true;
      }

      // Search by number (exact match for numbers)
      if (RegExp(r'^\d+$').hasMatch(query) &&
          hymn.number != null &&
          hymn.number.toString() == query) {
        return true;
      }

      // Search in title (priority 1) - Amharic text
      final titleLower = hymn.title;
      if (titleLower.contains(lowercaseQuery)) return true;

      // Check if all query words are in title
      if (queryWords.every((word) => titleLower.contains(word))) return true;

      // Search in first line (priority 2) - Amharic text
      final firstLineLower = hymn.firstLine;
      if (firstLineLower.contains(lowercaseQuery)) return true;

      // Check if all query words are in first line
      if (queryWords.every((word) => firstLineLower.contains(word)))
        return true;

      // Search in search terms (priority 3) - Amharic text
      if (hymn.searchTerms != null) {
        for (String term in hymn.searchTerms!) {
          final termLower = term;
          if (termLower.contains(lowercaseQuery)) return true;

          // Check if all query words are in any search term
          if (queryWords.every((word) => termLower.contains(word))) return true;
        }
      }

      // Search in lyrics (priority 4) - Amharic text, only for longer queries
      if (lowercaseQuery.length > 2) {
        final lyricsLower = hymn.lyrics;
        if (lyricsLower.contains(lowercaseQuery)) return true;

        // Check if all query words are in lyrics
        if (queryWords.every((word) => lyricsLower.contains(word))) return true;
      }

      return false;
    }).toList();
  }

  // Enhanced search with Amharic-specific features
  static Future<List<Hymn>> searchHymnsAdvanced(String query) async {
    await _loadHymns();
    if (_hymns == null) return [];

    if (query.trim().isEmpty) return _hymns!;

    final lowercaseQuery = query.toLowerCase().trim();
    final queryWords =
        lowercaseQuery
            .split(RegExp(r'\s+')) // Split by any whitespace
            .where((word) => word.isNotEmpty)
            .toList();

    return _hymns!.where((hymn) {
      // Search by ID (exact match for numbers)
      if (RegExp(r'^\d+$').hasMatch(query) && hymn.id.toString() == query) {
        return true;
      }

      // Search by number (exact match for numbers)
      if (RegExp(r'^\d+$').hasMatch(query) &&
          hymn.number != null &&
          hymn.number.toString() == query) {
        return true;
      }

      // Search in title (priority 1) - Amharic text
      final titleLower = hymn.title.toLowerCase();
      if (titleLower.contains(lowercaseQuery)) return true;

      // Check if all query words are in title
      if (queryWords.every((word) => titleLower.contains(word))) return true;

      // Search in first line (priority 2) - Amharic text
      final firstLineLower = hymn.firstLine.toLowerCase();
      if (firstLineLower.contains(lowercaseQuery)) return true;

      // Check if all query words are in first line
      if (queryWords.every((word) => firstLineLower.contains(word)))
        return true;

      // Search in search terms (priority 3) - Amharic text
      if (hymn.searchTerms != null) {
        for (String term in hymn.searchTerms!) {
          final termLower = term.toLowerCase();
          if (termLower.contains(lowercaseQuery)) return true;

          // Check if all query words are in any search term
          if (queryWords.every((word) => termLower.contains(word))) return true;
        }
      }

      // Search in lyrics (priority 4) - Amharic text, only for longer queries
      if (lowercaseQuery.length > 2) {
        final lyricsLower = hymn.lyrics.toLowerCase();
        if (lyricsLower.contains(lowercaseQuery)) return true;

        // Check if all query words are in lyrics
        if (queryWords.every((word) => lyricsLower.contains(word))) return true;
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
