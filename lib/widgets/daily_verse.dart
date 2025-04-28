import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' show LucideIcons;

class DailyVerse extends StatelessWidget {
  final Map<String, String> verse;

  const DailyVerse({Key? key, required this.verse}) : super(key: key);

  void shareVerse() {
    // You can use the `share_plus` package for actual sharing
    debugPrint('Sharing verse: ${verse['text']} - ${verse['reference']}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color(
              0xFF4A148C,
            ), // Deep purple (gradientStart for light theme)
            const Color(
              0xFF6A1B9A,
            ), // Lighter purple (gradientEnd for light theme)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'የዕለቱ የመጽሐፍ ቅዱስ ጥቅስ',
              style: TextStyle(
                fontFamily: 'Nyala-Bold',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Verse text
            Text(
              verse['text'] ?? '',
              style: const TextStyle(
                fontFamily: 'Nyala',
                fontSize: 20,
                height: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Reference
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                verse['reference'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Nyala',
                  fontSize: 16,
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Share button
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: shareVerse,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.share2, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'አጋራ',
                        style: TextStyle(
                          fontFamily: 'Nyala',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
