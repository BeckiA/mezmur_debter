import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:hymn_app/providers/theme_provider.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/providers/notification_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(theme, fontFamilyProvider),
              _buildGeneralSection(theme, themeProvider, fontFamilyProvider),
              _buildFontSizeSection(theme, fontFamilyProvider),
              _buildFontFamilySection(theme, fontFamilyProvider),
              _buildAboutSection(theme, fontFamilyProvider),
              _buildFooter(theme, fontFamilyProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, FontFamilyProvider fontFamilyProvider) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ቅንብሮች',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontFamily: fontFamilyProvider.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: fontSizeProvider.fontSizeValue * 1.5, // 1.5x for header
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneralSection(ThemeData theme, ThemeProvider themeProvider, FontFamilyProvider fontFamilyProvider) {
    return _buildSection(
      theme: theme,
      title: 'አጠቃላይ',
      fontFamilyProvider: fontFamilyProvider,
      children: [
        _buildSettingItem(
          theme: theme,
          icon:
              themeProvider.themeMode == ThemeMode.dark
                  ? LucideIcons.moon
                  : LucideIcons.sun,
          label: 'ጨለማ ገጽታ',
          fontFamilyProvider: fontFamilyProvider,
          trailing: FlutterSwitch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onToggle: (value) => themeProvider.toggleTheme(),
            activeColor: theme.primaryColor,
            inactiveColor: theme.unselectedWidgetColor,
            width: 50.0,
            height: 25.0,
            toggleSize: 20.0,
          ),
        ),
        _buildSettingItem(
          theme: theme,
          icon: LucideIcons.languages,
          label: 'ቋንቋ',
          fontFamilyProvider: fontFamilyProvider,
          trailing: Text(
            'አማርኛ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: fontFamilyProvider.fontFamily,
              color: theme.unselectedWidgetColor,
            ),
          ),
        ),
        _buildSettingItem(
          theme: theme,
          icon: LucideIcons.bell,
          label: 'ማሳወቂያዎች',
          fontFamilyProvider: fontFamilyProvider,
          trailing: Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return FlutterSwitch(
                value: notificationProvider.notificationsEnabled,
                onToggle: (value) async {
                  await notificationProvider.setNotificationsEnabled(value);
                  if (value && !notificationProvider.notificationsEnabled) {
                    // Show a message if permission was denied
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'ማሳወቂያ ለመላክ ፍቃድ ያስፈልጋል',
                            style: TextStyle(
                              fontFamily: fontFamilyProvider.fontFamily,
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                activeColor: theme.primaryColor,
                inactiveColor: theme.unselectedWidgetColor,
                width: 50.0,
                height: 25.0,
                toggleSize: 20.0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSection(ThemeData theme, FontFamilyProvider fontFamilyProvider) {
    final Map<String, String> fontSizes = {
      'small': 'ትንሽ',
      'medium': 'መካከለኛ',
      'large': 'ትልቅ',
    };

    return _buildSection(
      theme: theme,
      title: 'መዝሙር ማሳያ',
      fontFamilyProvider: fontFamilyProvider,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'የጽሑፍ መጠን',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: fontFamilyProvider.fontFamily,
              color: theme.unselectedWidgetColor,
            ),
          ),
        ),
        Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: fontSizes.keys.map((size) {
                final isSelected = fontSizeProvider.fontSize == size;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected 
                            ? theme.primaryColor.withOpacity(0.1) 
                            : theme.cardColor,
                        side: BorderSide(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => fontSizeProvider.setFontSize(size),
                      child: Text(
                        fontSizes[size]!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: fontFamilyProvider.fontFamily,
                          color: isSelected
                              ? theme.primaryColor
                              : theme.textTheme.bodyLarge?.color,
                          fontSize: size == 'small'
                              ? 14
                              : size == 'medium'
                                  ? 18
                                  : 22,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFontFamilySection(ThemeData theme, FontFamilyProvider fontFamilyProvider) {
    return _buildSection(
      theme: theme,
      title: 'መዝሙር ማሳያ',
      fontFamilyProvider: fontFamilyProvider,
      children: [
        _buildSettingItem(
          theme: theme,
          icon: LucideIcons.type,
          label: 'የፊደል አይነት',
          fontFamilyProvider: fontFamilyProvider,
          trailing: GestureDetector(
            onTap: () => _showFontFamilyBottomSheet(context, theme, fontFamilyProvider),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fontFamilyProvider.getFontDisplayName(fontFamilyProvider.fontFamily),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: fontFamilyProvider.fontFamily,
                    color: theme.unselectedWidgetColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: theme.unselectedWidgetColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFontFamilyBottomSheet(
    BuildContext context,
    ThemeData theme,
    FontFamilyProvider fontFamilyProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FontFamilyBottomSheet(
        theme: theme,
        fontFamilyProvider: fontFamilyProvider,
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme, FontFamilyProvider fontFamilyProvider) {
    return _buildSection(
      theme: theme,
      title: 'ስለ ትግበራው',
      fontFamilyProvider: fontFamilyProvider,
      children: [
        _buildLinkItem(
          theme: theme,
          icon: LucideIcons.info,
          label: 'ስለ እኛ',
          fontFamilyProvider: fontFamilyProvider,
        ),
        _buildLinkItem(
          theme: theme,
          icon: LucideIcons.heart,
          label: 'ይህን መተግበሪያ ይደግፉ',
          fontFamilyProvider: fontFamilyProvider,
        ),
        _buildLinkItem(
          theme: theme,
          icon: LucideIcons.share2,
          label: 'መተግበሪያውን ያጋሩ',
          fontFamilyProvider: fontFamilyProvider,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, FontFamilyProvider fontFamilyProvider) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Text(
                'ቅጂ 1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontSize: fontSizeProvider.fontSizeValue * 0.58, // 58% for footer
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '© 2025 የእውነት ቃል አገልግሎት',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontSize: fontSizeProvider.fontSizeValue * 0.58, // 58% for footer
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
    required FontFamilyProvider fontFamilyProvider,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeProvider.fontSizeValue * 1.0, // Full size for section titles
                ),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Widget trailing,
    required FontFamilyProvider fontFamilyProvider,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        return Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  width: 35,
                  alignment: Alignment.center,
                  child: Icon(icon, size: 22, color: theme.iconTheme.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: fontFamilyProvider.fontFamily,
                      fontSize: fontSizeProvider.fontSizeValue * 0.67, // 67% for labels
                    ),
                  ),
                ),
                trailing,
              ],
            ),
            Divider(color: theme.dividerColor),
          ],
        );
      },
    );
  }

  Widget _buildLinkItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required FontFamilyProvider fontFamilyProvider,
    bool showDivider = true,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        return Column(
          children: [
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    width: 35,
                    alignment: Alignment.center,
                    child: Icon(icon, size: 22, color: theme.iconTheme.color),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: fontFamilyProvider.fontFamily,
                      fontSize: fontSizeProvider.fontSizeValue * 0.67, // 67% for links
                    ),
                  ),
                ],
              ),
            ),
            if (showDivider) Divider(color: theme.dividerColor),
          ],
        );
      },
    );
  }
}

class _FontFamilyBottomSheet extends StatelessWidget {
  final ThemeData theme;
  final FontFamilyProvider fontFamilyProvider;

  const _FontFamilyBottomSheet({
    required this.theme,
    required this.fontFamilyProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'የፊደል አይነት ይምረጡ',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Nyala-Bold',
                          fontSize: fontSizeProvider.fontSizeValue * 1.25, // 1.25x for bottom sheet header
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'የሚመርጡትን የፊደል አይነት ይምረጡ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Nyala',
                          color: theme.unselectedWidgetColor,
                          fontSize: fontSizeProvider.fontSizeValue * 0.67, // 67% for subtitle
                        ),
                      ),
                    ],
                  ),
                ),
                // Font list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: FontFamilyProvider.availableFonts.length,
                    itemBuilder: (context, index) {
                      final fontFamily = FontFamilyProvider.availableFonts[index];
                      final isSelected = fontFamilyProvider.fontFamily == fontFamily;
                      final displayName = fontFamilyProvider.getFontDisplayName(fontFamily);

                      return InkWell(
                        onTap: () {
                          fontFamilyProvider.setFontFamily(fontFamily);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withOpacity(0.1)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontFamily: fontFamily,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: fontSizeProvider.fontSizeValue * 0.67, // 67% for list items
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  LucideIcons.check,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}
