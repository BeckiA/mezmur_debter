import 'dart:async';

class BibleService {
  static final List<Map<String, String>> _bibleVerses = [
    {
      'id': '1',
      'text':
          'ይህም የዘላለም ሕይወት ነው፤ አንተ ብቻ እውነተኛ አምላክ እንደ ሆንህ፥ የላክኸውንም ኢየሱስ ክርስቶስን እንዲያውቁ።',
      'reference': 'ዮሐንስ 17:3',
    },
    {
      'id': '2',
      'text': 'አትፍሩ አትደንግጡም... ማንም አላውቅም።',
      'reference': 'ኢሳይያስ 44:8',
    },
    {'id': '3', 'text': 'እግዚአብሔርን በፍጹም ልብህ ውደድ...', 'reference': 'ሉቃስ 10:27'},
    {'id': '4', 'text': 'እግዚአብሔር ዓለሙን እንዲህ ወዶአል...', 'reference': 'ዮሐንስ 3:16'},
    {'id': '5', 'text': 'በጸጋ ነው የዳናችሁት...', 'reference': 'ኤፌሶን 2:8'},
    {
      'id': '6',
      'text': 'ሁሉን ለእግዚአብሔር ክብር አድርጉ።',
      'reference': '1ኛ ቆሮንቶስ 10:31',
    },
    {'id': '7', 'text': 'በእግዚአብሔር ላይ ፍጹም ታመን...', 'reference': 'ምሳሌ 3:5-6'},
  ];

  // Public method to get verse of the day
  static Future<Map<String, String>> getVerseOfDay() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
    final today = DateTime.now();
    final dayOfYear = _getDayOfYear(today);
    final verseIndex = dayOfYear % _bibleVerses.length;
    return _bibleVerses[verseIndex];
  }

  // Private helper function to get day of year (0-365)
  static int _getDayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    final diff = date.difference(start).inMilliseconds;
    const oneDay = 1000 * 60 * 60 * 24;
    return (diff / oneDay).floor();
  }
}
