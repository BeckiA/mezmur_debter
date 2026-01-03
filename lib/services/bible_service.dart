import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class BibleService {
  static List<dynamic>? _bibleVerses;
  static const String _assetPath = 'assets/amharic_bible.json';

  // Month names mapping
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Loads the Bible verses from the JSON asset file
  static Future<void> _loadVerses() async {
    if (_bibleVerses != null) return; // Already loaded

    try {
      final String jsonString =
          await rootBundle.loadString(_assetPath);
      _bibleVerses = json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      print('Error loading Bible verses: $e');
      _bibleVerses = [];
    }
  }

  /// Gets the verse of the day based on current month and day
  static Future<Map<String, String>> getVerseOfDay() async {
    return getVerseForDate(DateTime.now());
  }

  /// Gets the verse for a specific date
  static Future<Map<String, String>> getVerseForDate(DateTime date) async {
    await _loadVerses();

    if (_bibleVerses == null || _bibleVerses!.isEmpty) {
      // Fallback verse if loading fails
      return {
        'text': 'Stay inspired with daily verses!',
        'reference': 'Psalm 119:105',
      };
    }

    final targetMonth = _monthNames[date.month - 1]; // Convert 1-12 to month name
    final targetDay = date.day;

    // Find the verse matching target month and day
    // If multiple entries exist for the same day, take the first one
    final verse = _bibleVerses!.firstWhere(
      (entry) =>
          entry['month'] == targetMonth && entry['day'] == targetDay,
      orElse: () => _bibleVerses!.first, // Fallback to first verse if not found
    );

    return {
      'text': verse['verse_text'] ?? '',
      'reference': verse['verse_reference'] ?? '',
    };
  }
}
