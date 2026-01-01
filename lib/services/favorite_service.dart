import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hymn_app/services/hymn_service.dart';

import '../models/hymn.dart';

class FavoriteService {
  static const String _favoriteHymnsKey = 'favorite_hymns';

  // Load favorite hymn IDs from local storage
  static Future<List<int>> _loadFavoriteHymnIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favoriteHymnIds = prefs.getStringList(_favoriteHymnsKey) ?? [];
      return favoriteHymnIds
          .map((id) => int.tryParse(id) ?? 0)
          .where((id) => id > 0)
          .toList();
    } catch (e) {
      print('Error loading favorite hymns: $e');
      return [];
    }
  }

  // Save favorite hymn IDs to local storage
  static Future<bool> _saveFavoriteHymnIds(List<int> hymnIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> hymnIdStrings = hymnIds.map((id) => id.toString()).toList();
      final success = await prefs.setStringList(_favoriteHymnsKey, hymnIdStrings);
      if (!success) {
        print('Warning: Failed to save favorite hymns to SharedPreferences');
      }
      return success;
    } catch (e) {
      print('Error saving favorite hymns: $e');
      return false;
    }
  }

  // Check if a hymn is favorite
  static Future<bool> isFavorite(int hymnId) async {
    try {
      List<int> favoriteHymnIds = await _loadFavoriteHymnIds();
      return favoriteHymnIds.contains(hymnId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Toggle favorite status
  static Future<void> toggleFavorite(int hymnId) async {
    try {
      List<int> favoriteHymnIds = await _loadFavoriteHymnIds();
      if (favoriteHymnIds.contains(hymnId)) {
        // Remove from favorites and local storage
        favoriteHymnIds.remove(hymnId);
      } else {
        // Add to favorites
        favoriteHymnIds.add(hymnId);
      }
      // Save updated list to local storage
      await _saveFavoriteHymnIds(favoriteHymnIds);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // Get all favorite hymns (full objects)
  static Future<List<Hymn>> getFavoriteHymns() async {
    try {
      List<int> favoriteHymnIds = await _loadFavoriteHymnIds();
      List<Hymn> hymns = [];
      for (int id in favoriteHymnIds) {
        Hymn? hymn = await HymnService.getHymnById(id);
        if (hymn != null) {
          hymns.add(hymn);
        }
      }
      return hymns;
    } catch (e) {
      print('Error getting favorite hymns: $e');
      return [];
    }
  }

  // Remove a specific hymn from favorites (explicit removal method)
  static Future<void> removeFavorite(int hymnId) async {
    try {
      List<int> favoriteHymnIds = await _loadFavoriteHymnIds();
      favoriteHymnIds.remove(hymnId);
      await _saveFavoriteHymnIds(favoriteHymnIds);
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  // Clear all favorites
  static Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoriteHymnsKey);
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }
}
