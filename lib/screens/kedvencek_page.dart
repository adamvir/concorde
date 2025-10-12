import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/market_stocks_data.dart';
import '../state/favorites_state.dart';
import '../state/watchlist_state.dart';
import 'reszveny_info_page.dart';
import 'dart:math';

// Widget a teljes kedvencek oldalhoz (ha külön navigáció kellene)
class KedvencekPage extends StatelessWidget {
  const KedvencekPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: KedvencekContent(),
      ),
    );
  }
}

// Kedvencek tartalom widget (ezt használjuk a main navigation-ben)
class KedvencekContent extends StatefulWidget {
  const KedvencekContent({super.key});

  @override
  State<KedvencekContent> createState() => _KedvencekContentState();
}

class _KedvencekContentState extends State<KedvencekContent> {
  final FavoritesState _favoritesState = FavoritesState();
  final WatchlistState _watchlistState = WatchlistState();
  bool _isSearching = false;
  bool _isFiltering = false; // Filter mode for current watchlist
  bool _isDetailedView = false; // Toggle between simple and detailed view
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _filterFocusNode = FocusNode();
  List<MarketStock> _searchResults = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _favoritesState.addListener(_onFavoritesChanged);
    _watchlistState.addListener(_onWatchlistChanged);
  }

  @override
  void dispose() {
    _favoritesState.removeListener(_onFavoritesChanged);
    _watchlistState.removeListener(_onWatchlistChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _filterController.dispose();
    _filterFocusNode.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  void _onWatchlistChanged() {
    setState(() {});
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults.clear();
        _searchFocusNode.unfocus();
      } else {
        // Close filter mode if open
        if (_isFiltering) {
          _isFiltering = false;
          _filterController.clear();
          _filterFocusNode.unfocus();
        }
        // Request focus immediately when entering search mode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _toggleFilter() {
    setState(() {
      _isFiltering = !_isFiltering;
      if (!_isFiltering) {
        _filterController.clear();
        _filterFocusNode.unfocus();
      } else {
        // Request focus immediately when entering filter mode
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _filterFocusNode.requestFocus();
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = MarketStocksData.searchStocks(query);
        // Limit results to 50 for performance
        if (_searchResults.length > 50) {
          _searchResults = _searchResults.sublist(0, 50);
        }
      }
    });
  }

  // Generate random daily change data for display
  double _getRandomDailyChangePercent() {
    return (_random.nextDouble() * 10 - 5); // -5% to +5%
  }

  double _getRandomDailyChange(double currentPrice) {
    double percent = _getRandomDailyChangePercent();
    return currentPrice * (percent / 100);
  }

  String _formatPrice(double price, String currency) {
    if (currency == 'HUF') {
      return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    } else {
      return price.toStringAsFixed(2);
    }
  }

  String _formatChange(double change, String currency) {
    String formatted;
    if (currency == 'HUF') {
      formatted = change.abs().toStringAsFixed(0);
    } else {
      formatted = change.abs().toStringAsFixed(2);
    }
    return change >= 0 ? '+$formatted' : '-$formatted';
  }

  String _formatChangePercent(double percent) {
    return '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%';
  }

  // Show lista selector bottom sheet (Figma design)
  void _showWatchlistSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lista items
              ..._watchlistState.watchlists.map((watchlist) {
                final isSelected = watchlist.id == _watchlistState.selectedWatchlistId;
                return GestureDetector(
                  onTap: () {
                    _watchlistState.selectWatchlist(watchlist.id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFEF3C6) : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      watchlist.name,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1D293D) : const Color(0xFF45556C),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                );
              }),
              // Divider
              Container(
                width: double.infinity,
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              // "Új lista létrehozása..." button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showAddWatchlistDialog();
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  padding: const EdgeInsets.only(left: 16, right: 24, top: 16, bottom: 16),
                  child: Row(
                    children: [
                      Icon(TablerIcons.plus, size: 24, color: Color(0xFF45556C)),
                      const SizedBox(width: 12),
                      Text(
                        'Új lista létrehozása...',
                        style: TextStyle(
                          color: const Color(0xFF45556C),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom padding
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Show list menu (kedvencek menu) - triggered by + button
  void _showListMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Kedvenc hozzáadása
                    _buildMenuOption(
                      icon: TablerIcons.star,
                      title: 'Kedvenc hozzáadása',
                      onTap: () {
                        Navigator.pop(context);
                        _showAddFavoriteDialog();
                      },
                    ),
                    // Lista átrendezése
                    _buildMenuOption(
                      icon: TablerIcons.arrows_sort,
                      title: 'Lista átrendezése',
                      onTap: () {
                        Navigator.pop(context);
                        _showReorderListPage();
                      },
                    ),
                    // Lista átnevezése
                    _buildMenuOption(
                      icon: TablerIcons.edit,
                      title: 'Lista átnevezése',
                      onTap: () {
                        Navigator.pop(context);
                        _showRenameListDialog();
                      },
                    ),
                    // Lista törlése
                    _buildMenuOption(
                      icon: TablerIcons.trash,
                      title: 'Lista törlése',
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteListDialog();
                      },
                    ),
                    // Divider
                    Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                    // Új lista létrehozása
                    Container(
                      width: double.infinity,
                      height: 56,
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 24,
                        bottom: 16,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showAddWatchlistDialog();
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              child: Icon(
                                TablerIcons.plus,
                                size: 24,
                                color: Color(0xFF45556C),
                              ),
                            ),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 260,
                              child: Text(
                                'Új lista létrehozása...',
                                style: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build menu options
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 24,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      child: Icon(
                        icon,
                        size: 24,
                        color: Color(0xFF45556C),
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 260,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: const Color(0xFF45556C),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show add favorite dialog - Full screen search page
  void _showAddFavoriteDialog() {
    final currentList = _watchlistState.selectedWatchlist;
    if (currentList == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AddFavoriteToListPage(
          listName: currentList.name,
          watchlistState: _watchlistState,
        ),
      ),
    );
  }

  // Show reorder list page
  void _showReorderListPage() {
    final currentList = _watchlistState.selectedWatchlist;
    if (currentList == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ReorderListPage(
          watchlistState: _watchlistState,
        ),
      ),
    );
  }

  // Show rename list dialog
  void _showRenameListDialog() {
    final currentList = _watchlistState.selectedWatchlist;
    if (currentList == null) return;

    final TextEditingController nameController = TextEditingController(
      text: currentList.name,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
          width: 312,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 264,
                      child: Text(
                        'Lista átnevezése',
                        style: TextStyle(
                          color: const Color(0xFF1D293D),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Lista neve',
                          labelStyle: const TextStyle(
                            color: Color(0xFF45556C),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                            letterSpacing: 0.10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              width: 1,
                              color: Color(0xFFCAD5E2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              width: 1,
                              color: Color(0xFFCAD5E2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              width: 2,
                              color: Color(0xFF1D293D),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF1D293D),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 16,
                  right: 24,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Mégse',
                        style: TextStyle(
                          color: Color(0xFF1D293D),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          final newName = nameController.text.trim();
                          _watchlistState.renameWatchlist(
                            currentList.id,
                            newName,
                          );
                          Navigator.pop(context);
                          // Show snackbar for list rename
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lista átnevezve: $newName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              backgroundColor: const Color(0xFF1D293D),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Mentés',
                        style: TextStyle(
                          color: Color(0xFF1D293D),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show delete list confirmation dialog (Figma design)
  void _showDeleteListDialog() {
    final currentList = _watchlistState.selectedWatchlist;
    if (currentList == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
          child: Container(
            width: 312,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Content section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      SizedBox(
                        width: 264,
                        child: Text(
                          'Lista törlése',
                          style: TextStyle(
                            color: const Color(0xFF1D293D),
                            fontSize: 24,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Message
                      SizedBox(
                        width: 264,
                        child: Text(
                          'Biztosan törlöd a "${currentList.name}" listát?',
                          style: TextStyle(
                            color: const Color(0xFF45556C),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 24,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Mégse button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Mégse',
                          style: TextStyle(
                            color: Color(0xFF1D293D),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Törlöm a listát button
                      TextButton(
                        onPressed: () {
                          final deletedListName = currentList.name;
                          _watchlistState.deleteWatchlist(currentList.id);
                          Navigator.pop(context);
                          // Show snackbar for list deletion
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lista törölve: $deletedListName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              backgroundColor: const Color(0xFF1D293D),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Törlöm a listát',
                          style: TextStyle(
                            color: Color(0xFF1D293D),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show add lista dialog (Figma design)
  void _showAddWatchlistDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
          width: 312,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Content section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const SizedBox(
                      width: 264,
                      child: Text(
                        'Új lista létrehozása',
                        style: TextStyle(
                          color: Color(0xFF1D293D),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TextField with floating label
                    SizedBox(
                      height: 56,
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Lista neve',
                          labelStyle: const TextStyle(
                            color: Color(0xFF45556C),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: Color(0xFFCAD5E2),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: Color(0xFFCAD5E2),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: Color(0xFF1D293D),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF1D293D),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 16,
                  right: 24,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Mégse button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Mégse',
                        style: TextStyle(
                          color: Color(0xFF1D293D),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mentés button
                    TextButton(
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          final newListName = nameController.text.trim();
                          _watchlistState.createWatchlist(newListName);
                          Navigator.pop(context);
                          // Show snackbar for list creation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Létrehoztál egy listát: $newListName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              backgroundColor: const Color(0xFF1D293D),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Mentés',
                        style: TextStyle(
                          color: Color(0xFF1D293D),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Get stocks from current watchlist instead of global favorites
    final currentWatchlistTickers = _watchlistState.selectedWatchlistTickers;
    var favoriteStocks = currentWatchlistTickers
        .map((ticker) => MarketStocksData.getStockByTicker(ticker))
        .where((stock) => stock != null)
        .cast<MarketStock>()
        .toList();

    // Apply filter if filter mode is active
    if (_isFiltering && _filterController.text.isNotEmpty) {
      final filterQuery = _filterController.text.toLowerCase();
      favoriteStocks = favoriteStocks.where((stock) {
        return stock.ticker.toLowerCase().contains(filterQuery) ||
               stock.name.toLowerCase().contains(filterQuery);
      }).toList();
    }

    return Column(
      children: [
        // App Bar Header
        Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              // Concorde logo
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: SvgPicture.asset(
                  'lib/assets/images/concorde.svg',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 8),
              if (!_isSearching)
                Expanded(
                  child: Text(
                    'Kedvencek',
                    style: TextStyle(
                      color: const Color(0xFF1D293D),
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF45556C), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Keresés részvények között...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF94A3B8),
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              color: const Color(0xFF1D293D),
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Icon(Icons.clear, color: Color(0xFF45556C), size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  _isSearching ? TablerIcons.x : TablerIcons.search,
                  color: Color(0xFF1D293D),
                ),
                onPressed: _toggleSearch,
              ),
              IconButton(
                icon: Icon(TablerIcons.speakerphone, color: Color(0xFF1D293D)),
                onPressed: () {
                  // TODO: Show notifications/announcements
                },
              ),
            ],
          ),
        ),
        // Show search results or favorites list
        if (_isSearching && _searchResults.isNotEmpty) ...[
          // Search results header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
            ),
            child: Text(
              '${_searchResults.length} találat${_searchResults.length >= 50 ? ' (első 50)' : ''}',
              style: TextStyle(
                color: const Color(0xFF45556C),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Search results list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final stock = _searchResults[index];
                final isInWatchlist = _watchlistState.isStockInCurrentWatchlist(stock.ticker);
                final dailyChangePercent = _getRandomDailyChangePercent();
                final isPositive = dailyChangePercent >= 0;

                return _buildSearchResultRow(
                  stock: stock,
                  isFavorite: isInWatchlist,
                  dailyChangePercent: dailyChangePercent,
                  isPositive: isPositive,
                  isLast: index == _searchResults.length - 1,
                );
              },
            ),
          ),
        ] else if (_isSearching && _searchController.text.isNotEmpty) ...[
          // No results
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Color(0xFFCAD5E2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nincs találat',
                    style: TextStyle(
                      color: const Color(0xFF45556C),
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Próbálj meg más keresési kifejezést',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (_isSearching) ...[
          // Search prompt
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Color(0xFFCAD5E2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Keress az 1000 részvény között',
                    style: TextStyle(
                      color: const Color(0xFF45556C),
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ticker vagy cégnév alapján',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Watchlist selector row (only show when not searching)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showWatchlistSelector(),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color(0xFFCAD5E2),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _watchlistState.selectedWatchlist?.name ?? 'Első',
                              style: TextStyle(
                                color: const Color(0xFF1D293D),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(TablerIcons.chevron_down, size: 24, color: Color(0xFF1D293D)),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(TablerIcons.plus, size: 24, color: Color(0xFF1D293D)),
                  onPressed: () => _showListMenu(),
                ),
                IconButton(
                  icon: Icon(TablerIcons.filter, size: 24, color: Color(0xFF1D293D)),
                  onPressed: _toggleFilter,
                ),
                IconButton(
                  icon: Icon(TablerIcons.dots_vertical, size: 24, color: Color(0xFF1D293D)),
                  onPressed: () {
                    setState(() {
                      _isDetailedView = !_isDetailedView;
                    });
                  },
                ),
              ],
            ),
          ),
          // Filter search bar (when filter mode is active)
          if (_isFiltering)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
                    onPressed: _toggleFilter,
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(TablerIcons.search, color: Color(0xFF45556C), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _filterController,
                              focusNode: _filterFocusNode,
                              onChanged: (query) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Lista szűrése....',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: const Color(0xFF1D293D),
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          if (_filterController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _filterController.clear();
                                setState(() {});
                              },
                              child: Icon(TablerIcons.x, color: Color(0xFF45556C), size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Table header (only show in simple view)
          if (!_isDetailedView)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
              ),
              child: Row(
                children: [
                  Text(
                    'Ticker',
                    style: TextStyle(
                      color: const Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 73,
                    child: Text(
                      ' Vált. %',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      'Napi vált.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(
                      'Akt. ár',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Detailed view header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Termék\nTőzsde   Típus   FX',
                      style: TextStyle(
                        color: const Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.50,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Vált. %',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Akt. ár\nNapi vált.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.50,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Favorites list
          if (favoriteStocks.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_border,
                      size: 64,
                      color: Color(0xFFCAD5E2),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nincs kedvenc részvény',
                      style: TextStyle(
                        color: const Color(0xFF45556C),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Használd a keresőt részvények hozzáadásához',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: favoriteStocks.length,
                itemBuilder: (context, index) {
                  final stock = favoriteStocks[index];
                  final dailyChangePercent = _getRandomDailyChangePercent();
                  final dailyChange = _getRandomDailyChange(stock.currentPrice);
                  final isPositive = dailyChangePercent >= 0;

                  if (_isDetailedView) {
                    return _buildDetailedStockRow(
                      stock: stock,
                      changePercent: _formatChangePercent(dailyChangePercent),
                      dailyChange: _formatChange(dailyChange, stock.currency),
                      currentPrice: _formatPrice(stock.currentPrice, stock.currency),
                      isPositive: isPositive,
                      isLast: index == favoriteStocks.length - 1,
                    );
                  } else {
                    return _buildStockRow(
                      stock: stock,
                      changePercent: _formatChangePercent(dailyChangePercent),
                      dailyChange: _formatChange(dailyChange, stock.currency),
                      currentPrice: _formatPrice(stock.currentPrice, stock.currency),
                      isPositive: isPositive,
                      isLast: index == favoriteStocks.length - 1,
                    );
                  }
                },
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSearchResultRow({
    required MarketStock stock,
    required bool isFavorite,
    required double dailyChangePercent,
    required bool isPositive,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReszvenyInfoPage(
              stockName: stock.name,
              ticker: stock.ticker,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: isLast ? 0 : 1,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Row(
          children: [
            // Add to watchlist icon
            GestureDetector(
              onTap: () {
                if (_watchlistState.isStockInCurrentWatchlist(stock.ticker)) {
                  _watchlistState.removeStockFromCurrentWatchlist(stock.ticker);
                } else {
                  _watchlistState.addStockToCurrentWatchlist(stock.ticker);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  _watchlistState.isStockInCurrentWatchlist(stock.ticker)
                      ? TablerIcons.star_filled
                      : TablerIcons.star,
                  size: 24,
                  color: _watchlistState.isStockInCurrentWatchlist(stock.ticker)
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Stock info
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.ticker,
                  style: TextStyle(
                    color: const Color(0xFF1D293D),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  stock.name,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  '${stock.exchange} • ${stock.currency}',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Price info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(stock.currentPrice, stock.currency),
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFD0FAE5)
                      : const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatChangePercent(dailyChangePercent),
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF007A55)
                        : const Color(0xFFC70036),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildStockRow({
    required MarketStock stock,
    required String changePercent,
    required String dailyChange,
    required String currentPrice,
    required bool isPositive,
    bool isLast = false,
  }) {
    return Dismissible(
      key: Key(stock.ticker),
      direction: DismissDirection.endToStart, // Swipe left
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFEC003F),
        child: Icon(
          TablerIcons.trash,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        // Haptic feedback
        HapticFeedback.mediumImpact();

        // Show delete confirmation (Figma style)
        return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
              child: Container(
                width: 312,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Content section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          SizedBox(
                            width: 264,
                            child: Text(
                              'Eltávolítás',
                              style: TextStyle(
                                color: const Color(0xFF1D293D),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Message
                          SizedBox(
                            width: 264,
                            child: Text(
                              'Biztosan eltávolítod a ${stock.name} részvényt a listáról?',
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 24,
                        bottom: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Mégse button
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Mégse',
                              style: TextStyle(
                                color: Color(0xFF1D293D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Eltávolítás button
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true); // Return true to confirm
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Eltávolítás',
                              style: TextStyle(
                                color: Color(0xFF1D293D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ?? false; // Return false if dialog dismissed without selection
      },
      onDismissed: (direction) {
        final listName = _watchlistState.selectedWatchlist?.name ?? 'Első';
        _watchlistState.removeStockFromCurrentWatchlist(stock.ticker);
        // Show snackbar for removal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Eltávolítva "$listName" listából',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            backgroundColor: const Color(0xFF1D293D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: _LongPressableStockRow(
        onLongPress: () {
          // Show remove confirmation dialog
          HapticFeedback.mediumImpact();
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
                child: Container(
                  width: 312,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Content section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            SizedBox(
                              width: 264,
                              child: Text(
                                'Eltávolítás',
                                style: TextStyle(
                                  color: const Color(0xFF1D293D),
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Message
                            SizedBox(
                              width: 264,
                              child: Text(
                                'Biztosan eltávolítod a ${stock.name} részvényt a listáról?',
                                style: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 16,
                          right: 24,
                          bottom: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Mégse button
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                'Mégse',
                                style: TextStyle(
                                  color: Color(0xFF1D293D),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Eltávolítás button
                            TextButton(
                              onPressed: () {
                                final listName = _watchlistState.selectedWatchlist?.name ?? 'Első';
                                _watchlistState.removeStockFromCurrentWatchlist(stock.ticker);
                                Navigator.pop(context);
                                // Show snackbar for removal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Eltávolítva "$listName" listából',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF1D293D),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                'Eltávolítás',
                                style: TextStyle(
                                  color: Color(0xFF1D293D),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReszvenyInfoPage(
                stockName: stock.name,
                ticker: stock.ticker,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: isLast ? 0 : 1,
                color: const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                stock.ticker,
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              SizedBox(
                width: 73,
                child: Text(
                  changePercent,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF007A55)
                        : const Color(0xFFEC003F),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  dailyChange,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF007A55)
                        : const Color(0xFFEC003F),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  currentPrice,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: const Color(0xFF1D293D),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build detailed stock row (PNG view)
  Widget _buildDetailedStockRow({
    required MarketStock stock,
    required String changePercent,
    required String dailyChange,
    required String currentPrice,
    required bool isPositive,
    bool isLast = false,
  }) {
    return Dismissible(
      key: Key('detailed_${stock.ticker}'),
      direction: DismissDirection.endToStart, // Swipe left
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFEC003F),
        child: Icon(
          TablerIcons.trash,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        // Haptic feedback
        HapticFeedback.mediumImpact();

        // Show delete confirmation (Figma style)
        return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
              child: Container(
                width: 312,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Content section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          SizedBox(
                            width: 264,
                            child: Text(
                              'Eltávolítás',
                              style: TextStyle(
                                color: const Color(0xFF1D293D),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Message
                          SizedBox(
                            width: 264,
                            child: Text(
                              'Biztosan eltávolítod a ${stock.name} részvényt a listáról?',
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 24,
                        bottom: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Mégse button
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Mégse',
                              style: TextStyle(
                                color: Color(0xFF1D293D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Eltávolítás button
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true); // Return true to confirm
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Eltávolítás',
                              style: TextStyle(
                                color: Color(0xFF1D293D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ?? false; // Return false if dialog dismissed without selection
      },
      onDismissed: (direction) {
        final listName = _watchlistState.selectedWatchlist?.name ?? 'Első';
        _watchlistState.removeStockFromCurrentWatchlist(stock.ticker);
        // Show snackbar for removal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Eltávolítva "$listName" listából',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            backgroundColor: const Color(0xFF1D293D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: _LongPressableStockRow(
      onLongPress: () {
        // Haptic feedback
        HapticFeedback.mediumImpact();

        // Show delete confirmation (Figma style)
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
              child: Container(
                width: 312,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Content section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          SizedBox(
                            width: 264,
                            child: Text(
                              'Eltávolítás',
                              style: TextStyle(
                                color: const Color(0xFF1D293D),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Message
                          SizedBox(
                            width: 264,
                            child: Text(
                              'Biztosan eltávolítod a ${stock.name} részvényt a listáról?',
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 24,
                        bottom: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Mégse button
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Mégse',
                              style: TextStyle(
                                color: Color(0xFF1D293D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Eltávolítás button
                          TextButton(
                            onPressed: () {
                              final listName = _watchlistState.selectedWatchlist?.name ?? 'Első';
                              _watchlistState.removeStockFromCurrentWatchlist(stock.ticker);
                              Navigator.pop(context);
                              // Show snackbar for removal
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Eltávolítva "$listName" listából',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF1D293D),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              'Eltávolítás',
                              style: TextStyle(
                                color: Color(0xFF1D293D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReszvenyInfoPage(
              stockName: stock.name,
              ticker: stock.ticker,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: isLast ? 0 : 1,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Row(
          children: [
            // Left side - Stock info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row: Stock name + icons
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stock.name,
                          style: TextStyle(
                            color: const Color(0xFF1D293D),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Icons (clock for market hours, E for earnings, etc.)
                      if (stock.ticker == 'MOL.BU' || stock.ticker == 'NVDA')
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            TablerIcons.clock,
                            size: 16,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                      if (stock.ticker == 'MOL.BU')
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFFEC003F),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'E',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (stock.ticker == 'AAPL')
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFF009966),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'V',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Second row: Exchange + Type + Currency
                  Text(
                    '${stock.exchange}   Részv.   ${stock.currency}',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Middle - Change percent
            SizedBox(
              width: 80,
              child: Text(
                changePercent,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isPositive
                      ? const Color(0xFF007A55)
                      : const Color(0xFFEC003F),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // Right side - Price + Daily change
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentPrice,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: const Color(0xFF1D293D),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dailyChange,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isPositive
                          ? const Color(0xFF007A55)
                          : const Color(0xFFEC003F),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// Add Favorite to List Page - Full screen search interface
class _AddFavoriteToListPage extends StatefulWidget {
  final String listName;
  final WatchlistState watchlistState;

  const _AddFavoriteToListPage({
    required this.listName,
    required this.watchlistState,
  });

  @override
  State<_AddFavoriteToListPage> createState() => _AddFavoriteToListPageState();
}

class _AddFavoriteToListPageState extends State<_AddFavoriteToListPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<MarketStock> _searchResults = [];

  @override
  void initState() {
    super.initState();
    widget.watchlistState.addListener(_onWatchlistChanged);
    // Auto-focus search on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.watchlistState.removeListener(_onWatchlistChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onWatchlistChanged() {
    setState(() {});
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults.clear();
      } else {
        _searchResults = MarketStocksData.searchStocks(query);
        // Limit results to 50 for performance
        if (_searchResults.length > 50) {
          _searchResults = _searchResults.sublist(0, 50);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current list stocks to show checkmarks
    final currentListTickers = widget.watchlistState.selectedWatchlistTickers;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kedvenc hozzáadása',
                          style: TextStyle(
                            color: const Color(0xFF1D293D),
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.27,
                          ),
                        ),
                        Text(
                          widget.listName,
                          style: TextStyle(
                            color: const Color(0xFF45556C),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFCAD5E2),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            child: Icon(
                              TablerIcons.search,
                              size: 24,
                              color: Color(0xFF45556C),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Termék keresése...',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: 0.10,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                color: const Color(0xFF1D293D),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Results list
            Expanded(
              child: _searchResults.isEmpty && _searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            TablerIcons.search,
                            size: 64,
                            color: Color(0xFFCAD5E2),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Keress részvényeket',
                            style: TextStyle(
                              color: const Color(0xFF45556C),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                TablerIcons.search_off,
                                size: 64,
                                color: Color(0xFFCAD5E2),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nincs találat',
                                style: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final stock = _searchResults[index];
                            final isInList = currentListTickers.contains(stock.ticker);
                            final isLast = index == _searchResults.length - 1;

                            return _buildStockRow(
                              stock: stock,
                              isInList: isInList,
                              isLast: isLast,
                            );
                          },
                        ),
            ),
            // Bottom button - "Kész"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D293D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(TablerIcons.check, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Kész',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
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

  Widget _buildStockRow({
    required MarketStock stock,
    required bool isInList,
    required bool isLast,
  }) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: TextStyle(
                      color: const Color(0xFF1D293D),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                      letterSpacing: 0.10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${stock.exchange}   Részv.   ${stock.currency}',
                    style: TextStyle(
                      color: const Color(0xFF45556C),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: 0.10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add/Remove button
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(
                isInList ? TablerIcons.circle_check_filled : TablerIcons.circle_plus,
                size: 24,
                color: isInList ? const Color(0xFF009966) : const Color(0xFF45556C),
              ),
              onPressed: () {
                final listName = widget.watchlistState.selectedWatchlist?.name ?? 'Első';
                if (isInList) {
                  widget.watchlistState.removeStockFromCurrentWatchlist(stock.ticker);
                  // Show snackbar for removal
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Eltávolítva "$listName" listából',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      backgroundColor: const Color(0xFF1D293D),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  widget.watchlistState.addStockToCurrentWatchlist(stock.ticker);
                  // Show snackbar for addition
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hozzáadva "$listName" listához',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      backgroundColor: const Color(0xFF1D293D),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Reorder List Page - Drag & Drop interface
class _ReorderListPage extends StatefulWidget {
  final WatchlistState watchlistState;

  const _ReorderListPage({
    required this.watchlistState,
  });

  @override
  State<_ReorderListPage> createState() => _ReorderListPageState();
}

class _ReorderListPageState extends State<_ReorderListPage> {
  @override
  void initState() {
    super.initState();
    widget.watchlistState.addListener(_onWatchlistChanged);
  }

  @override
  void dispose() {
    widget.watchlistState.removeListener(_onWatchlistChanged);
    super.dispose();
  }

  void _onWatchlistChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentListTickers = widget.watchlistState.selectedWatchlistTickers;
    final stocks = currentListTickers
        .map((ticker) => MarketStocksData.getStockByTicker(ticker))
        .where((stock) => stock != null)
        .cast<MarketStock>()
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: Text(
                      'Lista átrendezése',
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.27,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ReorderableListView
            Expanded(
              child: stocks.isEmpty
                  ? Center(
                      child: Text(
                        'Nincs elem a listában',
                        style: TextStyle(
                          color: const Color(0xFF45556C),
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: stocks.length,
                      onReorder: (oldIndex, newIndex) {
                        widget.watchlistState.reorderStocks(oldIndex, newIndex);
                      },
                      onReorderStart: (index) {
                        // Haptic feedback when drag starts
                        HapticFeedback.mediumImpact();
                      },
                      proxyDecorator: (child, index, animation) {
                        // iOS-style lift effect during drag
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final double elevation = Curves.easeInOut.transform(animation.value) * 8;
                            final double scale = 1.0 + (Curves.easeInOut.transform(animation.value) * 0.05);

                            return Transform.scale(
                              scale: scale,
                              child: Material(
                                elevation: elevation,
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final stock = stocks[index];
                        return _buildReorderableStockRow(
                          key: ValueKey(stock.ticker),
                          stock: stock,
                          isLast: index == stocks.length - 1,
                        );
                      },
                    ),
            ),
            // Bottom button - "Kész"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D293D),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(TablerIcons.check, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Kész',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableStockRow({
    required Key key,
    required MarketStock stock,
    required bool isLast,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Drag handle icon (left)
          Container(
            width: 48,
            height: 48,
            child: Icon(
              TablerIcons.grip_vertical,
              size: 24,
              color: Color(0xFF45556C),
            ),
          ),
          SizedBox(width: 4),
          // Stock name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                stock.name,
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Delete button (X icon on right)
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(
                TablerIcons.x,
                size: 24,
                color: Color(0xFF45556C),
              ),
              onPressed: () {
                // Show delete confirmation (Figma style)
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
                      child: Container(
                        width: 312,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Content section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  SizedBox(
                                    width: 264,
                                    child: Text(
                                      'Eltávolítás',
                                      style: TextStyle(
                                        color: const Color(0xFF1D293D),
                                        fontSize: 24,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.33,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Message
                                  SizedBox(
                                    width: 264,
                                    child: Text(
                                      'Biztosan eltávolítod a ${stock.name} részvényt a listáról?',
                                      style: TextStyle(
                                        color: const Color(0xFF45556C),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                        letterSpacing: 0.10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Actions section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 20,
                                left: 16,
                                right: 24,
                                bottom: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Mégse button
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text(
                                      'Mégse',
                                      style: TextStyle(
                                        color: Color(0xFF1D293D),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.43,
                                        letterSpacing: 0.10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Eltávolítás button
                                  TextButton(
                                    onPressed: () {
                                      final listName = widget.watchlistState.selectedWatchlist?.name ?? 'Első';
                                      widget.watchlistState.removeStockFromCurrentWatchlist(stock.ticker);
                                      Navigator.pop(context);
                                      // Show snackbar for removal
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Eltávolítva "$listName" listából',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          backgroundColor: const Color(0xFF1D293D),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: const Text(
                                      'Eltávolítás',
                                      style: TextStyle(
                                        color: Color(0xFF1D293D),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 1.43,
                                        letterSpacing: 0.10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

// Long Pressable Stock Row with iOS-style animation
class _LongPressableStockRow extends StatefulWidget {
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Widget child;

  const _LongPressableStockRow({
    required this.onLongPress,
    required this.onTap,
    required this.child,
  });

  @override
  State<_LongPressableStockRow> createState() => _LongPressableStockRowState();
}

class _LongPressableStockRowState extends State<_LongPressableStockRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _controller.forward();
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _controller.reverse();
    widget.onLongPress();
  }

  void _handleLongPressCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressCancel: _handleLongPressCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: _elevationAnimation.value,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: _controller.value > 0
                      ? const Color(0xFFF8FAFC)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
