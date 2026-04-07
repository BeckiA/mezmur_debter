class Hymn {
  final int id;
  final int? number;
  final String title;
  final String firstLine;
  final String lyrics;
  final List<String>? searchTerms;

  Hymn({
    required this.id,
    this.number,
    required this.title,
    required this.firstLine,
    required this.lyrics,
    this.searchTerms,
  });

  /// The user-facing hymn number, starting from 6 and skipping 55 and 88.
  int get displayNumber {
    final base = number ?? id;
    int display = base + 5;
    // Skip 55: if the number would be 55 or more, add an extra 1.
    if (display >= 55) display += 1;
    // Skip 88: if the number would be 88 or more, add another extra 1.
    if (display >= 88) display += 1;
    return display;
  }

  factory Hymn.fromJson(Map<String, dynamic> json, int id) {
    return Hymn(
      id: id,
      title: json['title'] ?? '',
      firstLine: json['first_line'] ?? '',
      lyrics: json['lyrics'] ?? '',
      searchTerms:
          json['search_terms'] != null
              ? List<String>.from(json['search_terms'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'first_line': firstLine,
      'lyrics': lyrics,
      'search_terms': searchTerms,
    };
  }
}
