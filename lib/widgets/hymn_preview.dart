import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/hymn.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:provider/provider.dart';

class HymnPreview extends StatelessWidget {
  final Hymn hymn;
  final VoidCallback onTap;

  const HymnPreview({super.key, required this.hymn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        final baseFontSize = fontSizeProvider.fontSizeValue;
        
        return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: colors.primary.withOpacity(0.1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Circle with hymn number
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
                  ((hymn.number ?? hymn.id) + 5).toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: fontFamilyProvider.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: baseFontSize * 0.67, // 67% of base size
                  ),
                ),
              ),
              // Text content
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
                      style: TextStyle(
                        fontFamily: fontFamilyProvider.fontFamily,
                        fontSize: baseFontSize * 0.58, // 58% of base size
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 20, color: theme.hintColor),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
