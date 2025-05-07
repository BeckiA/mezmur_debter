import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:hymn_app/providers/theme_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  String fontSize = 'medium';

  final Map<String, String> fontSizes = {
    'small': 'ትንሽ',
    'medium': 'መካከለኛ',
    'large': 'ትልቅ',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(theme),
              _buildGeneralSection(theme, themeProvider),
              _buildFontSizeSection(theme),
              _buildAboutSection(theme),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'ቅንብሮች',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Nyala-Bold',
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSection(ThemeData theme, ThemeProvider themeProvider) {
    return _buildSection(
      theme: theme,
      title: 'አጠቃላይ',
      children: [
        _buildSettingItem(
          theme: theme,
          icon:
              themeProvider.themeMode == ThemeMode.dark
                  ? LucideIcons.moon
                  : LucideIcons.sun,
          label: 'ጨለማ ገጽታ',

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
          trailing: Text(
            'አማርኛ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Nyala',
              color: theme.unselectedWidgetColor,
            ),
          ),
        ),
        _buildSettingItem(
          theme: theme,
          icon: LucideIcons.laptop,
          label: 'ማሳወቂያዎች',
          trailing: FlutterSwitch(
            value: notificationsEnabled,
            onToggle: (value) => setState(() => notificationsEnabled = value),
            activeColor: theme.primaryColor,
            inactiveColor: theme.unselectedWidgetColor,
            width: 50.0,
            height: 25.0,
            toggleSize: 20.0,
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'መዝሙር ማሳያ',
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'የጽሑፍ መጠን',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Nyala',
              color: theme.unselectedWidgetColor,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              fontSizes.keys.map((size) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        side: BorderSide(
                          color:
                              fontSize == size
                                  ? theme.primaryColor
                                  : Colors.transparent,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => setState(() => fontSize = size),
                      child: Text(
                        fontSizes[size]!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Nyala',
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize:
                              size == 'small'
                                  ? 14
                                  : size == 'medium'
                                  ? 18
                                  : 22,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'ስለ ትግበራው',
      children: [
        _buildLinkItem(theme: theme, icon: LucideIcons.info, label: 'ስለ እኛ'),
        _buildLinkItem(
          theme: theme,
          icon: LucideIcons.heart,
          label: 'ይህን መተግበሪያ ይደግፉ',
        ),
        _buildLinkItem(
          theme: theme,
          icon: LucideIcons.share2,
          label: 'መተግበሪያውን ያጋሩ',
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            'ቅጂ 1.0.0',
            style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Nyala'),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2025 የኢትዮጵያ ኦርቶዶክስ ቤተክርስቲያን',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Nyala'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Nyala-Bold',
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
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
                style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Nyala'),
              ),
            ),
            trailing,
          ],
        ),
        Divider(color: theme.dividerColor),
      ],
    );
  }

  Widget _buildLinkItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    bool showDivider = true,
  }) {
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
                style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Nyala'),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(color: theme.dividerColor),
      ],
    );
  }
}
