import '../models/hymn.dart';

class HymnService {
  static final List<Hymn> _hymns = [
    Hymn(
      id: 1,
      number: 123,
      title: 'ክርስቶስ ተነሳ',
      firstLine: 'ክርስቶስ ተነሳ ከሙታን',
      lyrics: '''ክርስቶስ ተነሳ ከሙታን፤
በሞት ሞትን ረገጠ
በመቃብር ላሉትም ሕይወት ሆነላቸው!

ሃሌ ሃሌ ሃሌሉያ፤
ሃሌ ሃሌ ሃሌሉያ!

እንቁዋቁዋ ይነግራል፤
ዛሬ ጌታ ተነሣ!
ጨለማ ሰማይ ገፍቶ
ብርሃን በአድማስ ሰፍቷል።

ሃሌ ሃሌ ሃሌሉያ፤
ሃሌ ሃሌ ሃሌሉያ!''',
    ),
    Hymn(
      id: 2,
      number: 145,
      title: 'ለእግዚአብሔር ዘምሩ',
      firstLine: 'ለእግዚአብሔር ዘምሩ አዲስ ዝማሬ',
      lyrics: '''ለእግዚአብሔር ዘምሩ አዲስ ዝማሬ፤
አዳኝን አመስግኑ ቅዱስ በመዝሙር።

ስሙን ከፍ ከፍ አድርጉ፤
ስራውን አውሩ ለዓለም፤
ኃይሉን ተናገሩ ለሰው ሁሉ!''',
    ),
    Hymn(
      id: 3,
      number: 178,
      title: 'ቅዱስ ቅዱስ ቅዱስ',
      firstLine: 'ቅዱስ ቅዱስ ቅዱስ እግዚአብሔር',
      lyrics: '''ቅዱስ ቅዱስ ቅዱስ እግዚአብሔር ሁሉን የሚገዛ!
ጥዋት ተነስቶ ልባችን ያመሰግንሃል።
ቅዱስ ቅዱስ ቅዱስ መሃሪ ለዘላለም
ሦስት አካል አንድ ፍጹም አምላክ!

ቅዱስ ቅዱስ ቅዱስ! ቅዱሳንህ በሰማይ
አክሊልን ጥለዋል ፊትህ ላይ በደስታ
ኪሩቤል ሴራፊም በፊትህ ሰግደዋል
ነበርክ አለህም ለዘላለም ትኖራለህ!''',
    ),
    Hymn(
      id: 4,
      number: 205,
      title: 'ሰላም ለአንቺ ይሁን',
      firstLine: 'ሰላም ለአንቺ ይሁን ማርያም',
      lyrics: '''ሰላም ለአንቺ ይሁን ማርያም
የጸጋ እናት ቅድስት ድንግል
እግዚአብሔር ከአንቺ ጋር ነው
ሁለም ሴቶች ያመሰግኑሻል።

የአዳም ልጆች ተስፋ ሆንሻል
የእግዚአብሔር እናት ሆነሻልና
በልጅሽ መስቀል አዳምን አዳንሻል
የሰው ልጆችን ሁሉ ታድያለሽ።''',
    ),
    Hymn(
      id: 5,
      number: 267,
      title: 'አቤቱ አንተን እናመሰግናለን',
      firstLine: 'አቤቱ አንተን እናመሰግናለን',
      lyrics: '''አቤቱ አንተን እናመሰግናለን
አቤቱ አንተን እናመሰግናለን
አቤቱ አንተን እናመሰግናለን
ለታላቅ ፍቅርህ፤ ለታላቅ ጸጋህ።

በልጅህ ደም ታደስኸን፤
አንተ ነህ ባለጸጋ፤
ክብር ይሁንልህ
ዘወትር ከራብ አደንኸን፤
አንተ ነህ እረኛችን፤
ክብር ይሁንልህ።''',
    ),
  ];

  // Get all hymns
  static List<Hymn> getAllHymns() {
    return _hymns;
  }

  // Get hymn by ID
  static Future<Hymn?> getHymnById(int id) async {
    return _hymns.firstWhere(
      (hymn) => hymn.id == id,
      orElse: () => Hymn(
        id: -1,
        number: -1,
        title: 'Unknown',
        firstLine: 'Unknown',
        lyrics: 'Unknown',
      ),
    );
  }

  // Get hymn by number
  static Future<Hymn?> getHymnByNumber(int number) async {
    return _hymns.firstWhere(
      (hymn) => hymn.number == number,
      orElse: () => Hymn(
        id: -1,
        number: -1,
        title: 'Unknown',
        firstLine: 'Unknown',
        lyrics: 'Unknown',
      ),
    );
  }

  // Search hymns
  static Future<List<Hymn>> searchHymns(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _hymns.where((hymn) {
      return hymn.title.toLowerCase().contains(lowercaseQuery) ||
          hymn.firstLine.toLowerCase().contains(lowercaseQuery) ||
          hymn.number.toString().contains(lowercaseQuery);
    }).toList();
  }
}
