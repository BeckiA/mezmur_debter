import 'package:flutter/material.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/services/favorite_service.dart';
import 'package:hymn_app/services/hymn_service.dart';
import 'package:hymn_app/services/recent_hymns_service.dart';
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
  double fontSize = 24;
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

  void _increaseFontSize() {
    if (fontSize < 40) {
      setState(() {
        fontSize += 2;
      });
    }
  }

  void _decreaseFontSize() {
    if (fontSize > 16) {
      setState(() {
        fontSize -= 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                  style: textTheme.bodyLarge?.copyWith(fontFamily: 'Nyala'),
                ),
              );
            }

            if (hymn == null) {
              return Center(
                child: Text(
                  'መዝሙሩ አልተገኘም።',
                  style: textTheme.bodyLarge?.copyWith(fontFamily: 'Nyala'),
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
                              'መዝሙር ${hymn!.number}',
                              style: textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Nyala',
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hymn!.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Nyala-Bold',
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
                    child: Text(
                      hymn!.lyrics,
                      style: textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Nyala',
                        fontSize: fontSize,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),

                // Font size controls
                Container(
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
                        onPressed: _decreaseFontSize,
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: theme.iconTheme.color,
                          size: 28,
                        ),
                      ),
                      Text(
                        'መጠን',
                        style: textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Nyala',
                        ),
                      ),
                      IconButton(
                        onPressed: _increaseFontSize,
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: theme.iconTheme.color,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
