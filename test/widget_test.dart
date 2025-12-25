// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymn_app/services/hymn_service.dart';
import 'package:hymn_app/models/hymn.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hymn Search Tests', () {
    test('Search functionality should work correctly', () async {
      // Test search by title
      final results1 = await HymnService.searchHymns('ሃሌ');
      expect(results1, isNotEmpty);
      expect(results1.any((hymn) => hymn.title.contains('ሃሌ')), isTrue);

      // Test search by first line
      final results2 = await HymnService.searchHymns('ለስምህ');
      expect(results2, isNotEmpty);
      expect(results2.any((hymn) => hymn.firstLine.contains('ለስምህ')), isTrue);

      // Test search by ID
      final results3 = await HymnService.searchHymns('1');
      expect(results3, isNotEmpty);
      expect(results3.any((hymn) => hymn.id == 1), isTrue);

      // Test empty search
      final results4 = await HymnService.searchHymns('');
      expect(results4, isNotEmpty); // Should return all hymns

      // Test search with no results
      final results5 = await HymnService.searchHymns('nonexistentterm');
      expect(results5, isEmpty);
    });

    test('Search should handle special characters and spaces', () async {
      // Test search with spaces
      final results1 = await HymnService.searchHymns('ሃሌ ሉያ');
      expect(results1, isNotEmpty);

      // Test search with trimmed whitespace
      final results2 = await HymnService.searchHymns('  ሃሌ  ');
      expect(results2, isNotEmpty);
    });

    test('Amharic text search should work correctly', () async {
      // Test search with Amharic characters that definitely exist
      final results1 = await HymnService.searchHymns('ምስጋና');
      expect(results1, isNotEmpty);

      // Test search with Amharic words that definitely exist
      final results2 = await HymnService.searchHymns('ጌታ');
      expect(results2, isNotEmpty);

      // Test search with Amharic phrases that definitely exist
      final results3 = await HymnService.searchHymns('ሃሌ ሉያ');
      expect(results3, isNotEmpty);

      // Test search with Amharic words that definitely exist
      final results4 = await HymnService.searchHymns('ክበር');
      expect(results4, isNotEmpty);
    });
  });
}
