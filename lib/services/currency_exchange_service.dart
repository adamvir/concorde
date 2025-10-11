import 'package:flutter/foundation.dart';
import '../data/mock_portfolio_data.dart';

class CurrencyExchangeService extends ChangeNotifier {
  static final CurrencyExchangeService _instance = CurrencyExchangeService._internal();
  factory CurrencyExchangeService() => _instance;
  CurrencyExchangeService._internal();

  final MockPortfolioData _portfolioData = MockPortfolioData();

  // Exchange rates (same as MarketData)
  static const Map<String, double> rates = {
    'HUF': 1.0,
    'USD': 380.0,  // 1 USD = 380 HUF
    'EUR': 410.0,  // 1 EUR = 410 HUF
  };

  // Convert between currencies
  // Example: exchangeCurrency('TBSZ-2024', 100, 'USD', 'EUR')
  // Converts 100 USD to EUR
  bool exchangeCurrency({
    required String accountName,
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return false;
    if (amount <= 0) return false;

    AccountPortfolio? account = _portfolioData.getAccountByName(accountName);
    if (account == null) return false;

    // Check if account has enough cash in source currency
    int fromIndex = account.cash.indexWhere((c) => c.currency == fromCurrency);
    if (fromIndex < 0 || account.cash[fromIndex].amount < amount) {
      return false; // Not enough cash
    }

    // Calculate conversion
    // Convert from -> HUF -> to
    double hufAmount = amount * rates[fromCurrency]!;
    double toAmount = hufAmount / rates[toCurrency]!;

    // Deduct from source currency
    account.cash[fromIndex] = Cash(
      currency: fromCurrency,
      amount: account.cash[fromIndex].amount - amount,
    );

    // Add to target currency
    int toIndex = account.cash.indexWhere((c) => c.currency == toCurrency);
    if (toIndex >= 0) {
      account.cash[toIndex] = Cash(
        currency: toCurrency,
        amount: account.cash[toIndex].amount + toAmount,
      );
    } else {
      // Create new cash entry
      account.cash.add(Cash(
        currency: toCurrency,
        amount: toAmount,
      ));
    }

    notifyListeners();
    return true;
  }

  // Get exchange rate between two currencies
  static double getRate(String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return 1.0;
    double hufAmount = rates[fromCurrency] ?? 1.0;
    double targetRate = rates[toCurrency] ?? 1.0;
    return hufAmount / targetRate;
  }

  // Get available cash in a currency
  double getAvailableCash(String accountName, String currency) {
    AccountPortfolio? account = _portfolioData.getAccountByName(accountName);
    if (account == null) return 0.0;

    int index = account.cash.indexWhere((c) => c.currency == currency);
    return index >= 0 ? account.cash[index].amount : 0.0;
  }
}
