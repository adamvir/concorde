import 'package:flutter/foundation.dart';

/// Global currency state manager
/// Manages the selected currency across all pages
class CurrencyState extends ChangeNotifier {
  // Singleton pattern
  static final CurrencyState _instance = CurrencyState._internal();

  factory CurrencyState() {
    return _instance;
  }

  CurrencyState._internal();

  // Private field for selected currency
  String _selectedCurrency = 'HUF';

  // Getter for selected currency
  String get selectedCurrency => _selectedCurrency;

  // Setter for selected currency with notification
  void setSelectedCurrency(String currency) {
    if (_selectedCurrency != currency) {
      print('CurrencyState: Changing currency from $_selectedCurrency to $currency');
      _selectedCurrency = currency;
      notifyListeners();
      print('CurrencyState: Currency changed, listeners notified');
    }
  }

  // Available currencies
  static const List<String> availableCurrencies = ['HUF', 'USD', 'EUR'];
}
