class LineSpan {
  final String text;
  final bool underline;

  LineSpan({required this.text, this.underline = false});

  factory LineSpan.fromJson(Map<String, dynamic> json) {
    return LineSpan(
      text: json['text'] ?? '',
      underline: json['underline'] == "true" || json['underline'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, if (underline) 'underline': true};
  }
}

class HymnLine {
  final String? text;
  final List<LineSpan>? spans;
  final String? repeat;
  final bool? indent;
  final bool? rightAlign;
  final bool? underline;

  HymnLine({this.text, this.spans, this.repeat, this.indent, this.rightAlign, this.underline});

  factory HymnLine.fromData(dynamic data) {
    if (data is String) {
      return HymnLine(text: data);
    } else if (data is Map) {
      final repeat = data['repeat']?.toString();
      final indent = data['indent'] == true || data['indent'] == "true";
      final rightAlign = data['rightAlign'] == true || data['rightAlign'] == "true";
      final underline = data['underline'] == true || data['underline'] == "true";
      if (data.containsKey('spans')) {
        final spansData = data['spans'];
        if (spansData is List) {
          final spansList = spansData.map((i) => LineSpan.fromJson(i as Map<String, dynamic>)).toList();
          return HymnLine(spans: spansList, repeat: repeat, indent: indent, rightAlign: rightAlign, underline: underline);
        }
      } else if (data.containsKey('text')) {
        return HymnLine(text: data['text']?.toString(), repeat: repeat, indent: indent, rightAlign: rightAlign, underline: underline);
      }
    }
    return HymnLine(text: data?.toString() ?? '');
  }

  dynamic toData() {
    if (spans != null) {
      return {
        'spans': spans!.map((s) => s.toJson()).toList(),
        if (repeat != null) 'repeat': repeat,
        if (indent == true) 'indent': true,
        if (rightAlign == true) 'rightAlign': true,
        if (underline == true) 'underline': true,
      };
    }
    if (repeat != null || indent == true || rightAlign == true || underline == true) {
      return {
        'text': text,
        if (repeat != null) 'repeat': repeat,
        if (indent == true) 'indent': true,
        if (rightAlign == true) 'rightAlign': true,
        if (underline == true) 'underline': true,
      };
    }
    return text;
  }
}

class StanzaGroup {
  final List<HymnLine>? lines;
  final List<int>? lineIndices;
  final String? repeat;

  StanzaGroup({this.lines, this.lineIndices, this.repeat});

  factory StanzaGroup.fromJson(Map<String, dynamic> json) {
    return StanzaGroup(
      lines: json['lines'] != null
          ? (json['lines'] as List).map((i) => HymnLine.fromData(i)).toList()
          : null,
      lineIndices: json['lineIndices'] != null
          ? List<int>.from(json['lineIndices'])
          : null,
      repeat: json['repeat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lines != null) 'lines': lines!.map((l) => l.toData()).toList(),
      if (lineIndices != null) 'lineIndices': lineIndices,
      if (repeat != null) 'repeat': repeat,
    };
  }
}

class Stanza {
  final List<HymnLine>? lines;
  final String? repeat;
  final List<StanzaGroup>? groups;

  Stanza({this.lines, this.repeat, this.groups});

  factory Stanza.fromJson(Map<String, dynamic> json) {
    return Stanza(
      lines:
          json['lines'] != null
              ? (json['lines'] as List)
                  .map((i) => HymnLine.fromData(i))
                  .toList()
              : null,
      repeat: json['repeat'],
      groups:
          json['groups'] != null
              ? (json['groups'] as List)
                  .map((i) => StanzaGroup.fromJson(i))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lines != null) 'lines': lines!.map((l) => l.toData()).toList(),
      if (repeat != null) 'repeat': repeat,
      if (groups != null) 'groups': groups!.map((e) => e.toJson()).toList(),
    };
  }
}

class Hymn {
  final int id;
  final int? number;
  final String title;
  final String firstLine;
  final String lyrics;
  final List<String>? searchTerms;
  final List<Stanza>? stanzas;

  Hymn({
    required this.id,
    this.number,
    required this.title,
    required this.firstLine,
    required this.lyrics,
    this.searchTerms,
    this.stanzas,
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
      stanzas:
          json['stanzas'] != null
              ? (json['stanzas'] as List)
                  .map((i) => Stanza.fromJson(i))
                  .toList()
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
      if (stanzas != null) 'stanzas': stanzas!.map((e) => e.toJson()).toList(),
    };
  }
}
