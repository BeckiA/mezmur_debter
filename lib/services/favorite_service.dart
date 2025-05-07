import 'dart:async';
import 'package:hymn_app/services/hymn_service.dart';

import '../models/hymn.dart';

class FavoriteService {
  static List<int> _favoriteHymns = [3, 5]; // Pre-populated favorites

  // Check if a hymn is favorite
  static Future<bool> isFavorite(int hymnId) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate delay
    return _favoriteHymns.contains(hymnId);
  }

  // Toggle favorite status
  static Future<void> toggleFavorite(int hymnId) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate delay
    if (_favoriteHymns.contains(hymnId)) {
      _favoriteHymns.remove(hymnId);
    } else {
      _favoriteHymns.add(hymnId);
    }
  }

  // Get all favorite hymns (full objects)
  static Future<List<Hymn>> getFavoriteHymns() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay
    List<Hymn> hymns = [];
    for (int id in _favoriteHymns) {
      Hymn? hymn = await HymnService.getHymnById(id);
      if (hymn != null) {
        hymns.add(hymn);
      }
    }
    return hymns;
  }
}
