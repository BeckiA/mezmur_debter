import 'package:flutter/material.dart';
import 'package:hymn_app/screens/favorite_screen.dart';
import 'package:hymn_app/screens/home_screen.dart';
import 'package:hymn_app/screens/hymn_screen.dart';
import 'package:hymn_app/screens/settings_screen.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class TabLayout extends StatefulWidget {
  @override
  TabLayoutState createState() => TabLayoutState();
}

class TabLayoutController {
  final TabLayoutState _state;

  TabLayoutController(this._state);

  void navigateToTab(int index) {
    _state._onItemTapped(index);
  }
}

class TabLayoutState extends State<TabLayout> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Public method to navigate to a specific tab
  void navigateToTab(int index) {
    _onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomeScreen(),
          HymnsScreen(),
          FavoritesScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamilyProvider.fontFamily,
          fontSize: 12,
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilyProvider.fontFamily,
          fontSize: 12,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'መነሻ'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bookOpen),
            label: 'መዝሙሮች',
          ),
          BottomNavigationBarItem(icon: Icon(LucideIcons.heart), label: 'ተወዳጅ'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'ቅንብሮች',
          ),
        ],
      ),
    );
  }
}
