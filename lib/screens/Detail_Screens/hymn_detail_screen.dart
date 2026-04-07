import 'package:flutter/material.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/providers/font_size_provider.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:hymn_app/services/favorite_service.dart';
import 'package:hymn_app/services/hymn_service.dart';
import 'package:hymn_app/services/recent_hymns_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
  late int currentHymnId;
  int totalHymnCount = 0;

  @override
  void initState() {
    super.initState();
    currentHymnId = widget.hymnId;
    _loadData = _fetchHymnData();
    _fetchTotalHymnCount();
    // Enable wakelock to keep screen on while viewing hymn
    WakelockPlus.enable();
  }

  Future<void> _fetchTotalHymnCount() async {
    final count = await HymnService.getHymnCount();
    if (mounted) {
      setState(() {
        totalHymnCount = count;
      });
    }
  }

  @override
  void dispose() {
    // Disable wakelock when leaving the screen
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _fetchHymnData() async {
    final fetchedHymn = await HymnService.getHymnById(currentHymnId);
    final favStatus = await FavoriteService.isFavorite(currentHymnId);

    // Add to recent hymns when hymn is loaded
    await RecentHymnsService.addRecentHymn(currentHymnId);

    if (mounted) {
      setState(() {
        hymn = fetchedHymn;
        isFavorite = favStatus;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      isAnimating = true;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    await FavoriteService.toggleFavorite(currentHymnId);
    if (mounted) {
      setState(() {
        isFavorite = !isFavorite;
        isAnimating = false;
      });
    }
  }

  void _navigateToNextHymn() {
    if (currentHymnId < totalHymnCount) {
      setState(() {
        currentHymnId++;
        _loadData = _fetchHymnData();
      });
    }
  }

  void _navigateToPreviousHymn() {
    if (currentHymnId > 1) {
      setState(() {
        currentHymnId--;
        _loadData = _fetchHymnData();
      });
    }
  }

  void _shareHymn() {
    if (hymn == null) return;
    
    // Ensure we have the full lyrics text
    final lyricsText = hymn!.lyrics;
    final titleText = hymn!.title;
    
    // Construct the share text with proper formatting
    final shareText = StringBuffer();
    shareText.writeln(titleText);
    shareText.writeln(); // Empty line
    shareText.write(lyricsText);
    
    // Share with subject for better formatting
    Share.share(
      shareText.toString(),
      subject: titleText,
    );
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

  Widget _buildHymnLine(HymnLine line, TextStyle? style) {
    if (line.spans != null) {
      return Text.rich(
        TextSpan(
          children: line.spans!
              .map((span) => TextSpan(
                    text: span.text,
                    style: style?.copyWith(
                      decoration: span.underline ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ))
              .toList(),
        ),
      );
    }
    return Text(
      line.text ?? '',
      style: style,
    );
  }

  Widget _buildStanzaPart(List<HymnLine> lines, String? repeat, TextStyle? style, Color themeColor) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lyrics text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) => _buildHymnLine(line, style)).toList(),
            ),
          ),
          // Repeat marker (bracket + label)
          if (repeat != null) ...[
            const SizedBox(width: 8),
            _buildRepeatMarker(repeat, style, themeColor),
          ],
        ],
      ),
    );
  }

  Widget _buildStanza(Stanza stanza, TextStyle? style) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stanza.groups != null)
            ...stanza.groups!.asMap().entries.map((entry) {
              final isLastGroup = entry.key == stanza.groups!.length - 1;
              final hasLinesAfter = stanza.lines != null && stanza.lines!.isNotEmpty;
              return Padding(
                padding: EdgeInsets.only(bottom: (isLastGroup && !hasLinesAfter) ? 0 : 8),
                child: _buildStanzaPart(entry.value.lines, entry.value.repeat, style, themeColor),
              );
            }),
          if (stanza.lines != null && stanza.lines!.isNotEmpty)
            _buildStanzaPart(stanza.lines!, stanza.repeat, style, themeColor),
        ],
      ),
    );
  }

  Widget _buildRepeatMarker(String label, TextStyle? style, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The bracket line
        CustomPaint(
          painter: _BracketPainter(color: color.withOpacity(0.6)),
          size: const Size(12, double.infinity),
        ),
        const SizedBox(width: 6),
        // The label (አዘ or 2X)
        Text(
          label,
          style: style?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Scaffold(
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
                        LucideIcons.arrowLeft,
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
                            'መዝሙር ${hymn!.displayNumber}',
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
                      icon: Icon(LucideIcons.share2, color: theme.iconTheme.color),
                      onPressed: _shareHymn,
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hymn!.stanzas != null && hymn!.stanzas!.isNotEmpty)
                            ...hymn!.stanzas!.map((stanza) => _buildStanza(
                                  stanza,
                                  textTheme.bodyLarge?.copyWith(
                                    fontFamily: fontFamilyProvider.fontFamily,
                                    fontSize: provider.fontSizeValue,
                                    height: 1.6,
                                  ),
                                ))
                          else
                            Text(
                              hymn!.lyrics,
                              style: textTheme.bodyLarge?.copyWith(
                                fontFamily: fontFamilyProvider.fontFamily,
                                fontSize: provider.fontSizeValue,
                                height: 1.6,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
    
              // Font size and navigation controls
              Consumer<FontSizeProvider>(
                builder: (context, provider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: theme.dividerColor)),
                      color: theme.cardColor,
                    ),
                    child: SafeArea(
                      top: false,
                      bottom: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous Hymn Button
                            IconButton(
                              onPressed: currentHymnId > 1 ? _navigateToPreviousHymn : null,
                              icon: Icon(
                                LucideIcons.chevronLeft,
                                color: currentHymnId > 1 ? theme.iconTheme.color : theme.disabledColor,
                                size: 28,
                              ),
                            ),
                            
                            // Font Size Controls (Grouped in center)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _decreaseFontSize(provider),
                                  icon: Icon(
                                    LucideIcons.minusCircle,
                                    color: theme.iconTheme.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'መጠን',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontFamily: fontFamilyProvider.fontFamily,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => _increaseFontSize(provider),
                                  icon: Icon(
                                    LucideIcons.plusCircle,
                                    color: theme.iconTheme.color,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),

                            // Next Hymn Button
                            IconButton(
                              onPressed: currentHymnId < totalHymnCount ? _navigateToNextHymn : null,
                              icon: Icon(
                                LucideIcons.chevronRight,
                                color: currentHymnId < totalHymnCount ? theme.iconTheme.color : theme.disabledColor,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}
