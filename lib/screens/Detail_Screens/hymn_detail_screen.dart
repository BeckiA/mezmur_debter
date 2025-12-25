import 'package:flutter/material.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/services/favorite_service.dart';
import 'package:hymn_app/services/hymn_service.dart';
import 'package:hymn_app/services/recent_hymns_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class HymnDetailScreen extends StatefulWidget {
  final int hymnId;
  const HymnDetailScreen({super.key, required this.hymnId});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  late Future<void> _loadData;
  Hymn? hymn;
  bool isFavorite = false;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _loadData = _fetchHymnData();
  }

  Future<void> _fetchHymnData() async {
    final fetchedHymn = await HymnService.getHymnById(widget.hymnId);
    final favStatus = await FavoriteService.isFavorite(widget.hymnId);

    // Add to recent hymns when hymn is loaded
    await RecentHymnsService.addRecentHymn(widget.hymnId);

    setState(() {
      hymn = fetchedHymn;
      isFavorite = favStatus;
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      isAnimating = true;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    await FavoriteService.toggleFavorite(widget.hymnId);
    setState(() {
      isFavorite = !isFavorite;
      isAnimating = false;
    });
  }

  void _increaseFontSize(FontSizeProvider fontSizeProvider) {
    final currentSize = fontSizeProvider.fontSize;
    if (currentSize == 'small') {
      fontSizeProvider.setFontSize('medium');
    } else if (currentSize == 'medium') {
      fontSizeProvider.setFontSize('large');
    }
  }

  void _decreaseFontSize(FontSizeProvider fontSizeProvider) {
    final currentSize = fontSizeProvider.fontSize;
    if (currentSize == 'large') {
      fontSizeProvider.setFontSize('medium');
    } else if (currentSize == 'medium') {
      fontSizeProvider.setFontSize('small');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: FutureBuilder(
          future: _loadData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: Text(
                  'እባክዎን ይጠብቁ...',
                  style: textTheme.bodyLarge?.copyWith(
                    fontFamily: fontFamilyProvider.fontFamily,
                  ),
                ),
              );
            }

            if (hymn == null) {
              return Center(
                child: Text(
                  'መዝሙሩ አልተገኘም።',
                  style: textTheme.bodyLarge?.copyWith(
                    fontFamily: fontFamilyProvider.fontFamily,
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.iconTheme.color,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'መዝሙር ${hymn!.id}',
                              style: textTheme.bodyMedium?.copyWith(
                                fontFamily: fontFamilyProvider.fontFamily,
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hymn!.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: fontFamilyProvider.fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.share, color: theme.iconTheme.color),
                        onPressed: () {
                          Share.share('${hymn!.title}\n\n${hymn!.lyrics}');
                        },
                      ),
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: AnimatedScale(
                          scale: isAnimating ? 1.3 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color:
                                isFavorite
                                    ? colorScheme.primary
                                    : theme.iconTheme.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Consumer<FontSizeProvider>(
                      builder: (context, provider, _) {
                        return Text(
                          hymn!.lyrics,
                          style: textTheme.bodyLarge?.copyWith(
                            fontFamily: fontFamilyProvider.fontFamily,
                            fontSize: provider.fontSizeValue,
                            height: 1.6,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Font size controls
                Consumer<FontSizeProvider>(
                  builder: (context, provider, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: theme.dividerColor)),
                        color: theme.cardColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => _decreaseFontSize(provider),
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: theme.iconTheme.color,
                              size: 28,
                            ),
                          ),
                          Text(
                            'መጠን',
                            style: textTheme.bodyLarge?.copyWith(
                              fontFamily: fontFamilyProvider.fontFamily,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _increaseFontSize(provider),
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: theme.iconTheme.color,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
