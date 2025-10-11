import 'package:flutter/foundation.dart';

// Watchlist (Mappa) model
class Watchlist {
  final String id;
  String name;
  List<String> tickers; // List of stock tickers in this watchlist

  Watchlist({
    required this.id,
    required this.name,
    List<String>? tickers,
  }) : tickers = tickers ?? [];
}

// Watchlist State Management
class WatchlistState extends ChangeNotifier {
  static final WatchlistState _instance = WatchlistState._internal();
  factory WatchlistState() => _instance;

  WatchlistState._internal() {
    _initializeDefaultWatchlists();
  }

  final List<Watchlist> _watchlists = [];
  String _selectedWatchlistId = '';

  List<Watchlist> get watchlists => List.unmodifiable(_watchlists);
  String get selectedWatchlistId => _selectedWatchlistId;

  Watchlist? get selectedWatchlist {
    try {
      return _watchlists.firstWhere((w) => w.id == _selectedWatchlistId);
    } catch (e) {
      return _watchlists.isNotEmpty ? _watchlists.first : null;
    }
  }

  List<String> get selectedWatchlistTickers {
    return selectedWatchlist?.tickers ?? [];
  }

  void _initializeDefaultWatchlists() {
    // Create default watchlists
    final defaultWatchlist = Watchlist(
      id: 'default_1',
      name: 'Első',
      tickers: ['NVDA', 'TSLA', 'AAPL', 'INTC', 'MOL.BU', 'OTP.BU'],
    );

    final techWatchlist = Watchlist(
      id: 'tech_1',
      name: 'Tech',
      tickers: ['MSFT', 'GOOGL', 'META', 'AMZN'],
    );

    _watchlists.add(defaultWatchlist);
    _watchlists.add(techWatchlist);
    _selectedWatchlistId = defaultWatchlist.id;
  }

  // Create new watchlist
  void createWatchlist(String name) {
    final newWatchlist = Watchlist(
      id: 'watchlist_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      tickers: [],
    );
    _watchlists.add(newWatchlist);
    notifyListeners();
  }

  // Rename watchlist
  void renameWatchlist(String id, String newName) {
    final watchlist = _watchlists.firstWhere((w) => w.id == id);
    watchlist.name = newName;
    notifyListeners();
  }

  // Delete watchlist
  void deleteWatchlist(String id) {
    _watchlists.removeWhere((w) => w.id == id);

    // If deleted watchlist was selected, select first available
    if (_selectedWatchlistId == id && _watchlists.isNotEmpty) {
      _selectedWatchlistId = _watchlists.first.id;
    }

    notifyListeners();
  }

  // Select watchlist
  void selectWatchlist(String id) {
    _selectedWatchlistId = id;
    notifyListeners();
  }

  // Add stock to current watchlist
  void addStockToCurrentWatchlist(String ticker) {
    final watchlist = selectedWatchlist;
    if (watchlist != null && !watchlist.tickers.contains(ticker)) {
      watchlist.tickers.add(ticker);
      notifyListeners();
    }
  }

  // Remove stock from current watchlist
  void removeStockFromCurrentWatchlist(String ticker) {
    final watchlist = selectedWatchlist;
    if (watchlist != null) {
      watchlist.tickers.remove(ticker);
      notifyListeners();
    }
  }

  // Check if stock is in current watchlist
  bool isStockInCurrentWatchlist(String ticker) {
    final watchlist = selectedWatchlist;
    return watchlist?.tickers.contains(ticker) ?? false;
  }

  // Move stock to different watchlist
  void moveStockToWatchlist(String ticker, String fromWatchlistId, String toWatchlistId) {
    final fromWatchlist = _watchlists.firstWhere((w) => w.id == fromWatchlistId);
    final toWatchlist = _watchlists.firstWhere((w) => w.id == toWatchlistId);

    fromWatchlist.tickers.remove(ticker);
    if (!toWatchlist.tickers.contains(ticker)) {
      toWatchlist.tickers.add(ticker);
    }

    notifyListeners();
  }

  // Reorder stocks in current watchlist
  void reorderStocks(int oldIndex, int newIndex) {
    final watchlist = selectedWatchlist;
    if (watchlist == null) return;

    // Adjust index if moving down
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final ticker = watchlist.tickers.removeAt(oldIndex);
    watchlist.tickers.insert(newIndex, ticker);

    notifyListeners();
  }
}
