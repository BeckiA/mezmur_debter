import 'package:flutter/material.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return AppBar(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: elevation,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading:
          showBackButton
              ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: titleColor ?? colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: fontFamilyProvider.fontFamily,
              fontWeight: FontWeight.bold,
              color: titleColor ?? colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: fontFamilyProvider.fontFamily,
                color: (titleColor ?? colorScheme.onSurface).withOpacity(0.7),
                height: 1.1,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
