import 'package:flutter/material.dart';
import 'package:hymn_app/models/hymn.dart';
import 'package:hymn_app/screens/Detail_Screens/hymn_detail_screen.dart';
import 'package:hymn_app/services/hymn_service.dart';
import 'package:hymn_app/widgets/hymn_list_item.dart';
import 'package:hymn_app/widgets/search_bar.dart';

class HymnsScreen extends StatefulWidget {
  @override
  _HymnsScreenState createState() => _HymnsScreenState();
}

class _HymnsScreenState extends State<HymnsScreen> {
  List<Hymn> hymns = [];
  // List<Hymn> filteredHymns = [];
  List<Hymn> filteredHymns = HymnService.getAllHymns();

  // String searchTerm = '';
  // String hymnNumber = '';
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];
  final ScrollController _scrollController = ScrollController();
  // final TextEditingController _searchController = TextEditingController();
  // final TextEditingController _numberController = TextEditingController();

  double _headerOpacity = 1.0;

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.length > 2) {
        // searchResults = searchHymns(query);
      } else {
        searchResults = [];
      }
    });
  }

  @override
  // void initState() {
  //   super.initState();
  //   hymns = HymnService.getAllHymns();
  //   filteredHymns = hymns;
  //   _scrollController.addListener(() {
  //     setState(() {
  //       double offset = _scrollController.offset;
  //       _headerOpacity = offset < 100 ? 1.0 - (offset / 300) : 0.7;
  //     });
  //   });
  // }
  // void searchHymns(String text) {
  //   setState(() {
  //     searchTerm = text;
  //     if (text.isNotEmpty) {
  //       filteredHymns =
  //           hymns.where((hymn) {
  //             final query = text.toLowerCase();
  //             return hymn.title.toLowerCase().contains(query) ||
  //                 hymn.firstLine.toLowerCase().contains(query) ||
  //                 hymn.number.toString().contains(query);
  //           }).toList();
  //     } else {
  //       filteredHymns = hymns;
  //     }
  //   });
  // }
  // void navigateToHymnByNumber() {
  //   if (hymnNumber.isNotEmpty) {
  //     final hymn = hymns.firstWhere(
  //       (h) => h.number.toString() == hymnNumber,
  //       orElse:
  //           () => Hymn(
  //             id: -1,
  //             title: 'Not Found',
  //             firstLine: '',
  //             number: -1,
  //             lyrics: '',
  //           ),
  //     );
  //     if (hymn != null) {
  //       Navigator.pushNamed(context, '/hymn/${hymn.id}');
  //       _numberController.clear();
  //       setState(() {
  //         hymnNumber = '';
  //       });
  //     }
  //   }
  // }
  // void clearSearch() {
  //   _searchController.clear();
  //   searchHymns('');
  //   FocusScope.of(context).unfocus();
  // }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: _headerOpacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'መዝሙሮች',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Nyala-Bold',
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),

                  child: SearchBarItem(
                    placeholder: 'ፈልግ በቁጥር ወይም በስም...',
                    value: searchQuery,
                    onChanged: _handleSearch,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                filteredHymns.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'ምንም መዝሙር አልተገኘም',
                          style: TextStyle(fontFamily: 'Nyala', fontSize: 18),
                        ),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredHymns.length,
                      itemBuilder: (context, index) {
                        final hymn = filteredHymns[index];
                        return HymnListItem(
                          hymn: hymn,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          HymnDetailScreen(hymnId: hymn.id),
                                ),
                              ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
