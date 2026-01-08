import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymn_app/screens/favorite_screen.dart';
import 'package:hymn_app/screens/home_screen.dart';
import 'package:hymn_app/screens/hymn_screen.dart';
import 'package:hymn_app/screens/settings_screen.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class TabLayout extends StatefulWidget {
  final int? initialIndex;
  
  const TabLayout({super.key, this.initialIndex});

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
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialIndex ?? 0;
    _selectedIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
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

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    
    // Check if back button was pressed within the last 2 seconds
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // First press - show snackbar
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'መተግበሪያውን ለመዘጋት እባክዎ በድጋሚ የመውጫ ምልክቱን ይጫኑ ',
            style: TextStyle(
              fontFamily: Provider.of<FontFamilyProvider>(context, listen: false).fontFamily,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false; // Don't exit
    } else {
      // Second press within 2 seconds - exit the app
      return true; // Allow exit
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
