import 'package:flutter/foundation.dart';
import '../data/market_stocks_data.dart';

// Singleton state for managing favorite stocks
class FavoritesState extends ChangeNotifier {
  static final FavoritesState _instance = FavoritesState._internal();
  factory FavoritesState() => _instance;
  FavoritesState._internal();

  // Set of favorite stock tickers
  final Set<String> _favoriteTickers = {
    'NVDA',
    'TSLA',
    'AAPL',
    'INTC',
    'MOL',
    'OTP',
  };

  // Get list of favorite stocks
  List<MarketStock> get favoriteStocks {
    return _favoriteTickers
        .map((ticker) => MarketStocksData.getByTicker(ticker))
        .where((stock) => stock != null)
        .cast<MarketStock>()
        .toList();
  }

  // Check if a stock is favorited
  bool isFavorite(String ticker) {
    return _favoriteTickers.contains(ticker.toUpperCase());
  }

  // Add stock to favorites
  void addFavorite(String ticker) {
    if (!_favoriteTickers.contains(ticker.toUpperCase())) {
      print('FavoritesState: Adding $ticker to favorites');
      _favoriteTickers.add(ticker.toUpperCase());
      notifyListeners();
    }
  }

  // Remove stock from favorites
  void removeFavorite(String ticker) {
    if (_favoriteTickers.contains(ticker.toUpperCase())) {
      print('FavoritesState: Removing $ticker from favorites');
      _favoriteTickers.remove(ticker.toUpperCase());
      notifyListeners();
    }
  }

  // Toggle favorite status
  void toggleFavorite(String ticker) {
    if (isFavorite(ticker)) {
      removeFavorite(ticker);
    } else {
      addFavorite(ticker);
    }
  }

  // Get number of favorites
  int get count => _favoriteTickers.length;
}
