import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/screens/Detail_Screens/hymn_detail_screen.dart';
import 'package:hymn_app/services/hymn_service.dart';
import 'package:hymn_app/services/recent_hymns_service.dart';
import 'package:hymn_app/widgets/custom_app_bar.dart';
import 'package:hymn_app/widgets/hymn_list_item.dart';
import 'package:hymn_app/widgets/search_bar.dart';
import 'package:hymn_app/providers/font_family_provider.dart';
import 'package:provider/provider.dart';

class HymnsScreen extends StatefulWidget {
  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  List<Hymn> hymns = [];
  List<Hymn> filteredHymns = [];
  String searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  double _headerOpacity = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHymns();
    _scrollController.addListener(() {
      setState(() {
        double offset = _scrollController.offset;
        _headerOpacity = offset < 100 ? 1.0 - (offset / 300) : 0.7;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHymns() async {
    try {
      final allHymns = await HymnService.getAllHymns();
      setState(() {
        hymns = allHymns;
        filteredHymns = allHymns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading hymns: $e');
    }
  }

  Future<void> _handleSearch(String query) async {
    setState(() {
      searchQuery = query;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set a new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isLoading = true;
      });

      try {
        if (query.trim().isEmpty) {
          setState(() {
            filteredHymns = hymns;
            _isLoading = false;
          });
        } else {
          final searchResults = await HymnService.searchHymns(query);
          setState(() {
            filteredHymns = searchResults;
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error searching hymns: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontFamilyProvider = Provider.of<FontFamilyProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'መዝሙሮች', subtitle: 'ሁሉም መዝሙሮች'),
      body: Column(
        children: [
          AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _headerOpacity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarItem(
                placeholder: 'ፈልግ በቁጥር ወይም በስም...',
                value: searchQuery,
                onChanged: _handleSearch,
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredHymns.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          searchQuery.isEmpty
                              ? 'ምንም መዝሙር አልተገኘም'
                              : 'ለ "$searchQuery" ምንም ውጤት አልተገኘም',
                          style: TextStyle(
                            fontFamily: fontFamilyProvider.fontFamily,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: filteredHymns.length,
                      itemBuilder: (context, index) {
                        final hymn = filteredHymns[index];
                        return HymnListItem(
                          hymn: hymn,
                          onTap: () async {
                            // Add to recent hymns when navigating
                            await RecentHymnsService.addRecentHymn(hymn.id);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        HymnDetailScreen(hymnId: hymn.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
