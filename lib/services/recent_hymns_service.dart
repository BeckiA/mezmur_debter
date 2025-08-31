import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hymn.dart';
import 'hymn_service.dart';

class RecentHymnsService {
  static const String _recentHymnsKey = 'recent_hymns';
  static const int _maxRecentHymns = 3;

  // Add a hymn to recent list
  static Future<void> addRecentHymn(int hymnId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentHymns = prefs.getStringList(_recentHymnsKey) ?? [];

      // Remove if already exists (to move to front)
      recentHymns.remove(hymnId.toString());

      // Add to front
      recentHymns.insert(0, hymnId.toString());

      // Keep only the most recent hymns
      if (recentHymns.length > _maxRecentHymns) {
        recentHymns = recentHymns.take(_maxRecentHymns).toList();
      }

      await prefs.setStringList(_recentHymnsKey, recentHymns);
    } catch (e) {
      print('Error adding recent hymn: $e');
    }
  }

  // Get recent hymns as full Hymn objects
  static Future<List<Hymn>> getRecentHymns({int limit = 3}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentHymnIds = prefs.getStringList(_recentHymnsKey) ?? [];

      List<Hymn> recentHymns = [];

      // Get full hymn objects for each ID
      for (String idString in recentHymnIds.take(limit)) {
        int hymnId = int.tryParse(idString) ?? 0;
        if (hymnId > 0) {
          Hymn? hymn = await HymnService.getHymnById(hymnId);
          if (hymn != null) {
            recentHymns.add(hymn);
          }
        }
      }

      return recentHymns;
    } catch (e) {
      print('Error getting recent hymns: $e');
      return [];
    }
  }

  // Clear all recent hymns
  static Future<void> clearRecentHymns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentHymnsKey);
    } catch (e) {
      print('Error clearing recent hymns: $e');
    }
  }

  // Remove a specific hymn from recent list
  static Future<void> removeRecentHymn(int hymnId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentHymns = prefs.getStringList(_recentHymnsKey) ?? [];
      recentHymns.remove(hymnId.toString());
      await prefs.setStringList(_recentHymnsKey, recentHymns);
    } catch (e) {
      print('Error removing recent hymn: $e');
    }
  }

  // Get recent hymn IDs only (for debugging or other uses)
  static Future<List<int>> getRecentHymnIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentHymnIds = prefs.getStringList(_recentHymnsKey) ?? [];
      return recentHymnIds
          .map((id) => int.tryParse(id) ?? 0)
          .where((id) => id > 0)
          .toList();
    } catch (e) {
      print('Error getting recent hymn IDs: $e');
      return [];
    }
  }

  // Get count of recent hymns
  static Future<int> getRecentHymnsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentHymnIds = prefs.getStringList(_recentHymnsKey) ?? [];
      return recentHymnIds.length;
    } catch (e) {
      print('Error getting recent hymns count: $e');
      return 0;
    }
  }
}
