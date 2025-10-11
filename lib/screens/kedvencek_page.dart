import 'package:flutter/material.dart';
import '../data/market_stocks_data.dart';
import '../state/favorites_state.dart';
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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<MarketStock> _searchResults = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _favoritesState.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesState.removeListener(_onFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults.clear();
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

  @override
  Widget build(BuildContext context) {
    final favoriteStocks = _favoritesState.favoriteStocks;

    return Column(
      children: [
        // Status bar
        Container(
          width: double.infinity,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '9:30',
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Header
        Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: Color(0xFF1D293D)),
                onPressed: () {},
              ),
              SizedBox(width: 8),
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
                            autofocus: true,
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
                  _isSearching ? Icons.close : Icons.search,
                  color: Color(0xFF1D293D),
                ),
                onPressed: _toggleSearch,
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Color(0xFF1D293D)),
                onPressed: () {},
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
                final isFavorite = _favoritesState.isFavorite(stock.ticker);
                final dailyChangePercent = _getRandomDailyChangePercent();
                final isPositive = dailyChangePercent >= 0;

                return _buildSearchResultRow(
                  stock: stock,
                  isFavorite: isFavorite,
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
          // Filter row (only show when not searching)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
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
                            'Első',
                            style: TextStyle(
                              color: const Color(0xFF1D293D),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, size: 24),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.sort, size: 24),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, size: 24),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, size: 24),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Table header
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

                  return _buildStockRow(
                    stock: stock,
                    changePercent: _formatChangePercent(dailyChangePercent),
                    dailyChange: _formatChange(dailyChange, stock.currency),
                    currentPrice: _formatPrice(stock.currentPrice, stock.currency),
                    isPositive: isPositive,
                    isLast: index == favoriteStocks.length - 1,
                  );
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
            // Favorite icon
            GestureDetector(
              onTap: () {
                _favoritesState.toggleFavorite(stock.ticker);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: 24,
                  color: isFavorite ? const Color(0xFFFFC107) : const Color(0xFF94A3B8),
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
    return GestureDetector(
      onLongPress: () {
        // Show delete confirmation
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Eltávolítás'),
            content: Text('Biztosan eltávolítod a ${stock.ticker} részvényt a kedvencek közül?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Mégse'),
              ),
              TextButton(
                onPressed: () {
                  _favoritesState.removeFavorite(stock.ticker);
                  Navigator.pop(context);
                },
                child: Text('Eltávolítás', style: TextStyle(color: Colors.red)),
              ),
            ],
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
    );
  }
}
