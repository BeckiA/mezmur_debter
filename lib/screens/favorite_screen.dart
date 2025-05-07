import 'package:flutter/material.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/services/favorite_service.dart';
import 'package:hymn_app/widgets/hymn_list_item.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Hymn> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favHymns = await FavoriteService.getFavoriteHymns();
    setState(() {
      favorites = favHymns;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ተወዳጅ መዝሙሮች',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Nyala-Bold',
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  favorites.isNotEmpty
                      ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final hymn = favorites[index];
                          return HymnListItem(
                            hymn: hymn,
                            isFavorite: true,
                            onTap: () {
                              Navigator.pushNamed(context, '/hymn/${hymn.id}');
                            },
                          );
                        },
                      )
                      : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.heartOff,
                                size: 60,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'ምንም ተወዳጅ መዝሙሮች የሉም',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Nyala-Bold',
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ተወዳጅ መዝሙሮችን ለመጨመር ልብ ምልክቱን ይጫኑ',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Nyala',
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.7),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/hymns');
                                },
                                child: Text(
                                  'መዝሙሮችን ያስሱ',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Nyala',
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
