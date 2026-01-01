import 'package:flutter/material.dart';
import 'package:hymn_app/constants/app_colors.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:provider/provider.dart';

class HymnListItem extends StatelessWidget {
  final Hymn hymn;
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
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        final baseFontSize = fontSizeProvider.fontSizeValue;
        
        return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular number container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 16),
              child: Text(
                ((hymn.number ?? hymn.id) + 5).toString(),
                style: TextStyle(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: baseFontSize * 0.67, // 67% of base size
                ),
              ),
            ),
            // Title and first line
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hymn.title,
                    style: TextStyle(
                      fontFamily: fontFamilyProvider.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: baseFontSize * 0.67, // 67% of base size
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hymn.firstLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: fontFamilyProvider.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: baseFontSize * 0.58, // 58% of base size
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
