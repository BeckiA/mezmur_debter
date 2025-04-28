import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' show LucideIcons;

class HymnListItem extends StatelessWidget {
  final Map<String, dynamic> hymn;
  final VoidCallback onTap;
  final bool isFavorite;

  const HymnListItem({
    Key? key,
    required this.hymn,
    required this.onTap,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      splashColor: colors.primary.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 1),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Number circle
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF4A148C),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 16),
              child: Text(
                hymn['number'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nyala-Bold',
                  fontSize: 16,
                ),
              ),
            ),
            // Title and first line
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hymn['title'],
                    style: TextStyle(
                      fontFamily: 'Nyala-Bold',
                      fontSize: 16,
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hymn['firstLine'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nyala',
                      fontSize: 14,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            // Favorite Heart
            if (isFavorite)
              Icon(LucideIcons.heart, size: 18, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
