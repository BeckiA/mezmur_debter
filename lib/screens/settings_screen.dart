import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:hymn_app/providers/theme_provider.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/providers/notification_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
          onTap: () => _showAboutBottomSheet(context, theme, fontFamilyProvider),
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
    VoidCallback? onTap,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        return Column(
          children: [
            InkWell(
              onTap: onTap ?? () {},
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

  void _showAboutBottomSheet(
    BuildContext context,
    ThemeData theme,
    FontFamilyProvider fontFamilyProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AboutBottomSheet(
        theme: theme,
        fontFamilyProvider: fontFamilyProvider,
      ),
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

class _AboutBottomSheet extends StatelessWidget {
  final ThemeData theme;
  final FontFamilyProvider fontFamilyProvider;

  const _AboutBottomSheet({
    required this.theme,
    required this.fontFamilyProvider,
  });

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Consumer<FontSizeProvider>(
            builder: (context, fontSizeProvider, _) {
              return Text(
                'ወደ ማህደረ ትዕዛዝ ተቀድቷል',
                style: TextStyle(
                  fontFamily: fontFamilyProvider.fontFamily,
                  fontSize: fontSizeProvider.fontSizeValue * 0.67,
                ),
              );
            },
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareApp() async {
    await Share.share(
      'መዝሙር ደብተር - የአምልኮና የምስጋና መዝሙሮች\n\n'
      'ይህ መተግበሪያ ለጥናትና ለአምልኮ አገልግሎት የተዘጋጀ ነው።',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, _) {
        final baseFontSize = fontSizeProvider.fontSizeValue;
        
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // App Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/EKA_Logo_Icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              LucideIcons.music,
                              size: 40,
                              color: theme.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // App Title
                    Text(
                      'መዝሙር ደብተር',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: fontFamilyProvider.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: baseFontSize * 1.25,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Developer Info
                    _buildInfoRow(
                      context,
                      theme,
                      fontFamilyProvider,
                      fontSizeProvider,
                      'Developer',
                      'Bereket Abera',
                      baseFontSize,
                    ),
                    const SizedBox(height: 16),
                    
                    // Email (clickable to copy)
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, 'berekeetabera@gmail.com'),
                      child: _buildInfoRow(
                        context,
                        theme,
                        fontFamilyProvider,
                        fontSizeProvider,
                        'Email',
                        'berekeetabera@gmail.com',
                        baseFontSize,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Share App Link
                    InkWell(
                      onTap: _shareApp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.share2,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'መተግበሪያውን ያጋሩ',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontFamily: fontFamilyProvider.fontFamily,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: baseFontSize * 0.67,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Description
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ስለ መተግበሪያው',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: fontFamilyProvider.fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: baseFontSize * 0.83,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ይህ መዝሙር ደብተር ለጥናት፣ ለአምልኮ እና ለምስጋና አገልግሎት የተዘጋጀ ነው። በዚህ መተግበሪያ ውስጥ የአማርኛ መዝሙሮችን በቀላሉ ማግኘት፣ መመልከት እና መጠቀም ይችላሉ።',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: fontFamilyProvider.fontFamily,
                              fontSize: baseFontSize * 0.67,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Privacy Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.shield,
                                size: 20,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'የግላዊነት መረጃ',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: fontFamilyProvider.fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: baseFontSize * 0.83,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• ምንም የተጠቃሚ ውሂብ አንሰብራም\n'
                            '• ምንም ማስታወቂያዎች የሉም\n'
                            '• የክህደት መዳረሻ የሚያስፈልገው የቅርብ ጊዜ መዝሙሮችን ለመከታተል ብቻ ነው',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: fontFamilyProvider.fontFamily,
                              fontSize: baseFontSize * 0.67,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ጥያቄዎች ወይም ሀሳቦች ካሉዎት፣ እባክዎን ያግኙን።',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: fontFamilyProvider.fontFamily,
                              fontSize: baseFontSize * 0.67,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _copyToClipboard(context, 'berekeetabera@gmail.com'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.mail,
                                    size: 18,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'berekeetabera@gmail.com',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontFamily: fontFamilyProvider.fontFamily,
                                      color: theme.primaryColor,
                                      fontSize: baseFontSize * 0.67,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    LucideIcons.copy,
                                    size: 16,
                                    color: theme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    ThemeData theme,
    FontFamilyProvider fontFamilyProvider,
    FontSizeProvider fontSizeProvider,
    String label,
    String value,
    double baseFontSize, {
    bool isClickable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: fontFamilyProvider.fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: baseFontSize * 0.67,
            color: theme.unselectedWidgetColor,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: fontFamilyProvider.fontFamily,
            fontSize: baseFontSize * 0.67,
            color: isClickable ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
            decoration: isClickable ? TextDecoration.underline : null,
          ),
        ),
      ],
    );
  }
}
