import 'package:flutter/material.dart';
import 'package:hymn_app/constants/app_colors.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
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
                hymn.number?.toString() ?? hymn.id.toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontWeight: FontWeight.bold,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: fontFamilyProvider.fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hymn.firstLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: fontFamilyProvider.fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
