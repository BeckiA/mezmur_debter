import 'package:flutter/material.dart';
import 'package:hymn_app/layouts/tab_layout.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/screens/Detail_Screens/hymn_detail_screen.dart';
import 'package:hymn_app/services/favorite_service.dart';
import 'package:hymn_app/services/recent_hymns_service.dart';
import 'package:hymn_app/widgets/custom_app_bar.dart';
import 'package:hymn_app/widgets/hymn_list_item.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

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
    if (mounted) {
      setState(() {
        favorites = favHymns;
      });
    }
  }

  Future<void> removeFavorite(Hymn hymn) async {
    await FavoriteService.toggleFavorite(hymn.id);
    if (mounted) {
      setState(() {
        favorites.removeWhere((h) => h.id == hymn.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'ተወዳጅ መዝሙሮች', subtitle: 'የተመረጡ መዝሙሮች'),
      body:
          favorites.isNotEmpty
              ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final hymn = favorites[index];
                  return Dismissible(
                    key: Key('favorite_${hymn.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.trash2,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'ተወዳጅ መዝሙር ማስወገድ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontFamily: fontFamilyProvider.fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'ይህን መዝሙር ከተወዳጅ መዝሙሮች ማስወገድ ይፈልጋሉ?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: fontFamilyProvider.fontFamily,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text(
                                  'ደግመው አስብ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: fontFamilyProvider.fontFamily,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: Text(
                                  'ያስወግድ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: fontFamilyProvider.fontFamily,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      removeFavorite(hymn);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${hymn.title} ከተወዳጅ መዝሙሮች ተወግዷል',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: fontFamilyProvider.fontFamily,
                            ),
                          ),
                          action: SnackBarAction(
                            label: 'ደግመው አክል',
                            onPressed: () async {
                              await FavoriteService.toggleFavorite(hymn.id);
                              if (mounted) {
                                loadFavorites();
                              }
                            },
                          ),
                        ),
                      );
                    },
                    child: HymnListItem(
                      hymn: hymn,
                      isFavorite: true,
                      onTap: () async {
                        // Add to recent hymns when navigating
                        await RecentHymnsService.addRecentHymn(hymn.id);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => HymnDetailScreen(hymnId: hymn.id),
                          ),
                        );
                      },
                    ),
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
                          fontFamily: fontFamilyProvider.fontFamily,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ተወዳጅ መዝሙሮችን ለመጨመር ልብ ምልክቱን ይጫኑ',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: fontFamilyProvider.fontFamily,
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(
                            0.7,
                          ),
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
                          // Navigate to hymns tab (index 1)
                          final tabLayout =
                              context.findAncestorStateOfType<TabLayoutState>();
                          if (tabLayout != null) {
                            tabLayout.navigateToTab(1);
                          }
                        },
                        child: Text(
                          'መዝሙሮችን ያስሱ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: fontFamilyProvider.fontFamily,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
