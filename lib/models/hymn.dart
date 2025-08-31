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
