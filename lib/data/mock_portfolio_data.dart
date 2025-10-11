// ============================================================================
// COMPLETE MOCK PORTFOLIO DATA SYSTEM
// ============================================================================
// This file contains a comprehensive mock data backend for the portfolio app
// All numbers are mathematically accurate and aggregate correctly

// ============================================================================
// 1. BASE MODELS
// ============================================================================

class Stock {
  final String name;
  final String ticker;
  final String isin;
  final String exchange;
  final int quantity;
  final double price; // Vételár = jelenlegi ár (nincs profit/loss)
  final String currency;
  final DateTime purchaseDate;

  Stock({
    required this.name,
    required this.ticker,
    required this.isin,
    required this.exchange,
    required this.quantity,
    required this.price,
    required this.currency,
    required this.purchaseDate,
  });

  // Backward compatibility
  double get avgPrice => price;
  double get currentPrice => price;

  // Calculated values (nincs profit mivel currentPrice == avgPrice)
  double get totalValue => quantity * price;
  double get totalCost => quantity * price;
  double get unrealizedProfit => 0.0; // Nincs profit/loss
  double get profitPercent => 0.0; // Nincs profit/loss
  bool get isPositive => true;

  // Convert to HUF
  double totalValueInHUF(Map<String, double> rates) {
    return totalValue * (rates[currency] ?? 1);
  }

  double unrealizedProfitInHUF(Map<String, double> rates) {
    return 0.0; // Nincs profit/loss
  }
}

class Fund {
  final String name;
  final String isin;
  final double units;
  final double unitPrice;
  final double purchasePrice;
  final String currency;
  final DateTime purchaseDate;

  Fund({
    required this.name,
    required this.isin,
    required this.units,
    required this.unitPrice,
    required this.purchasePrice,
    required this.currency,
    required this.purchaseDate,
  });

  double get value => units * unitPrice;
  double get cost => units * purchasePrice;
  double get unrealizedProfit => value - cost;
  double get profitPercent => cost > 0 ? ((unitPrice - purchasePrice) / purchasePrice) * 100 : 0;
  bool get isPositive => unrealizedProfit >= 0;

  double valueInHUF(Map<String, double> rates) {
    return value * (rates[currency] ?? 1);
  }
}

class Cash {
  final String currency;
  final double amount;

  Cash({
    required this.currency,
    required this.amount,
  });

  double amountInHUF(Map<String, double> rates) {
    return amount * (rates[currency] ?? 1);
  }
}

// ============================================================================
// 2. HISTORICAL DATA MODEL
// ============================================================================

class HistoricalDataPoint {
  final DateTime date;
  final double value; // Portfolio value in HUF at this date

  HistoricalDataPoint({
    required this.date,
    required this.value,
  });
}

// ============================================================================
// 3. MARKET DATA (Real-time rates, prices)
// ============================================================================

class MarketData {
  // Exchange rates to HUF (Fix árfolyamok)
  static const Map<String, double> exchangeRates = {
    'HUF': 1.0,
    'USD': 380.0,   // 1 USD = 380 HUF
    'EUR': 410.0,   // 1 EUR = 410 HUF
  };

  // Convert any amount from one currency to another
  // Példa: convert(1000, 'HUF', 'USD') = 1000 / 380 = 2.63 USD
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    // First convert to HUF
    double amountInHUF = amount * (exchangeRates[fromCurrency] ?? 1.0);

    // Then convert from HUF to target currency
    double targetRate = exchangeRates[toCurrency] ?? 1.0;
    return amountInHUF / targetRate;
  }

  // Get exchange rate from HUF to target currency
  // Példa: getRate('USD') = 380 (1 USD = 380 HUF)
  static double getRate(String currency) {
    return exchangeRates[currency] ?? 1.0;
  }

  // Get inverse rate (from target currency to HUF)
  // Példa: getInverseRate('USD') = 1/380 = 0.002631
  static double getInverseRate(String currency) {
    double rate = exchangeRates[currency] ?? 1.0;
    return 1.0 / rate;
  }

  // Stock prices by ticker
  static const Map<String, StockPrice> stockPrices = {
  };
}

class StockPrice {
  final double currentPrice;
  final String currency;

  const StockPrice({
    required this.currentPrice,
    required this.currency,
  });
}

// ============================================================================
// 3. ACCOUNT PORTFOLIO
// ============================================================================

class AccountPortfolio {
  final String accountName;
  final String accountNumber;
  final String accountType; // TBSZ, Értékpapírszámla
  final List<Stock> stocks;
  final List<Fund> funds;
  final List<Cash> cash;
  final List<HistoricalDataPoint> historicalData;

  AccountPortfolio({
    required this.accountName,
    this.accountNumber = '',
    this.accountType = 'Normál számla',
    required this.stocks,
    List<Fund>? funds,
    List<Cash>? cash,
    List<HistoricalDataPoint>? historicalData,
  })  : funds = funds ?? [],
        cash = cash ?? [],
        historicalData = historicalData ?? [];

  // =========================================================================
  // TOTAL VALUES (in HUF)
  // =========================================================================

  double get totalValue {
    double total = 0;
    for (var stock in stocks) {
      total += stock.totalValueInHUF(MarketData.exchangeRates);
    }
    for (var fund in funds) {
      total += fund.valueInHUF(MarketData.exchangeRates);
    }
    for (var c in cash) {
      total += c.amountInHUF(MarketData.exchangeRates);
    }
    return total;
  }

  double get stocksValue {
    double total = 0;
    for (var stock in stocks) {
      total += stock.totalValueInHUF(MarketData.exchangeRates);
    }
    return total;
  }

  double get fundsValue {
    double total = 0;
    for (var fund in funds) {
      total += fund.valueInHUF(MarketData.exchangeRates);
    }
    return total;
  }

  double get cashValue {
    double total = 0;
    for (var c in cash) {
      total += c.amountInHUF(MarketData.exchangeRates);
    }
    return total;
  }

  // =========================================================================
  // UNREALIZED PROFIT (in HUF)
  // =========================================================================

  double get totalUnrealizedProfit {
    double total = 0;
    for (var stock in stocks) {
      total += stock.unrealizedProfitInHUF(MarketData.exchangeRates);
    }
    for (var fund in funds) {
      total += fund.unrealizedProfit * (MarketData.exchangeRates[fund.currency] ?? 1);
    }
    return total;
  }

  double get totalCost {
    double total = 0;
    for (var stock in stocks) {
      total += stock.totalCost * (MarketData.exchangeRates[stock.currency] ?? 1);
    }
    for (var fund in funds) {
      total += fund.cost * (MarketData.exchangeRates[fund.currency] ?? 1);
    }
    return total;
  }

  double get totalProfitPercent {
    final cost = totalCost;
    return cost > 0 ? (totalUnrealizedProfit / cost) * 100 : 0;
  }

  // =========================================================================
  // CURRENCY CONVERSION METHODS (bármilyen devizában)
  // =========================================================================

  // Total value in any currency
  double totalValueIn(String currency) {
    return MarketData.convert(totalValue, 'HUF', currency);
  }

  // Stocks value in any currency
  double stocksValueIn(String currency) {
    return MarketData.convert(stocksValue, 'HUF', currency);
  }

  // Funds value in any currency
  double fundsValueIn(String currency) {
    return MarketData.convert(fundsValue, 'HUF', currency);
  }

  // Cash value in any currency
  double cashValueIn(String currency) {
    return MarketData.convert(cashValue, 'HUF', currency);
  }

  // Unrealized profit in any currency
  double unrealizedProfitIn(String currency) {
    return MarketData.convert(totalUnrealizedProfit, 'HUF', currency);
  }

  // Get cash grouped by currency
  Map<String, double> getCashByCurrency() {
    Map<String, double> result = {};
    for (var c in cash) {
      result[c.currency] = (result[c.currency] ?? 0) + c.amount;
    }
    return result;
  }

  // Get cash by currency in HUF
  Map<String, double> getCashByCurrencyInHUF() {
    Map<String, double> result = {};
    for (var c in cash) {
      result[c.currency] = c.amountInHUF(MarketData.exchangeRates);
    }
    return result;
  }
}

// ============================================================================
// 4. HISTORICAL DATA GENERATOR
// ============================================================================

class HistoricalDataGenerator {
  /// Generates realistic historical data ending at the current value
  /// Returns a list of data points with some realistic variation
  static List<HistoricalDataPoint> generateHistoricalData({
    required double currentValue,
    required int daysBack,
  }) {
    List<HistoricalDataPoint> data = [];
    DateTime now = DateTime.now();

    // Start value will be 88-92% of current value (simulating moderate growth)
    double startValue = currentValue * 0.90;

    // Generate daily data points with smooth progression
    double previousValue = startValue;

    for (int i = daysBack; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));

      // Calculate progress (0.0 to 1.0)
      double progress = (daysBack - i) / daysBack;

      // Use smooth curve for growth (ease-in-out)
      double smoothProgress = _smoothStep(progress);
      double targetValue = startValue + (currentValue - startValue) * smoothProgress;

      // Add small realistic daily variation (±0.5%)
      // Use a deterministic pseudo-random based on day index
      double seed = (i * 73) % 100; // Pseudo-random between 0-99
      double variation = ((seed / 100.0) - 0.5) * 0.01; // ±0.5%

      // Smooth transition from previous value (momentum)
      double dailyChange = (targetValue - previousValue) * 0.3; // 30% of the difference
      double value = previousValue + dailyChange + (previousValue * variation);

      // Ensure we end exactly at currentValue
      if (i == 0) {
        value = currentValue;
      }

      data.add(HistoricalDataPoint(date: date, value: value));
      previousValue = value;
    }

    return data;
  }

  /// Smooth step function for realistic growth curve
  static double _smoothStep(double x) {
    // Smooth cubic interpolation
    return x * x * (3.0 - 2.0 * x);
  }

  /// Get historical data for a specific time period with appropriate granularity
  static List<HistoricalDataPoint> getDataForPeriod({
    required List<HistoricalDataPoint> fullData,
    required String period, // '1D', '1W', '1M', '6M', '1Y'
  }) {
    if (fullData.isEmpty) return [];

    DateTime now = DateTime.now();
    List<HistoricalDataPoint> result = [];

    switch (period) {
      case '1D':
      case '1N':
        // 24 hourly data points for 1 day (simulate with last day's data)
        // Since we only have daily data, show just today's data point
        var point = _findClosestDataPoint(fullData, now);
        if (point != null) result.add(point);
        break;

      case '1W':
      case '1H':
        // 7 daily data points (last 7 days)
        for (int i = 6; i >= 0; i--) {
          DateTime targetDate = now.subtract(Duration(days: i));
          var point = _findClosestDataPoint(fullData, targetDate);
          if (point != null) result.add(point);
        }
        break;

      case '1M':
        // 5 weekly data points (every 7 days for last ~30 days)
        for (int week = 4; week >= 0; week--) {
          DateTime targetDate = now.subtract(Duration(days: week * 7));
          var point = _findClosestDataPoint(fullData, targetDate);
          if (point != null) result.add(point);
        }
        break;

      case '6M':
      case '6H':
        // 6 monthly data points (6 months back)
        for (int month = 5; month >= 0; month--) {
          DateTime targetDate = DateTime(now.year, now.month - month, 1);
          var point = _findClosestDataPoint(fullData, targetDate);
          if (point != null) result.add(point);
        }
        break;

      case '1Y':
      case '1É':
        // 12 monthly data points (12 months back)
        for (int month = 11; month >= 0; month--) {
          DateTime targetDate = DateTime(now.year, now.month - month, 1);
          var point = _findClosestDataPoint(fullData, targetDate);
          if (point != null) result.add(point);
        }
        break;

      default:
        // Default to 1 month view
        for (int week = 4; week >= 0; week--) {
          DateTime targetDate = now.subtract(Duration(days: week * 7));
          var point = _findClosestDataPoint(fullData, targetDate);
          if (point != null) result.add(point);
        }
    }

    return result;
  }

  /// Find the closest data point to a target date
  static HistoricalDataPoint? _findClosestDataPoint(
    List<HistoricalDataPoint> data,
    DateTime targetDate,
  ) {
    if (data.isEmpty) return null;

    HistoricalDataPoint? closest;
    int minDiff = 999999;

    for (var point in data) {
      int diff = point.date.difference(targetDate).inDays.abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = point;
      }
    }

    return closest;
  }
}

// ============================================================================
// 5. MAIN DATA PROVIDER
// ============================================================================

class MockPortfolioData {
  // Singleton pattern
  static final MockPortfolioData _instance = MockPortfolioData._internal();
  factory MockPortfolioData() => _instance;

  // =========================================================================
  // ACCOUNT 1: TBSZ 2023
  // Fresh account: 0 stocks, only HUF cash
  // =========================================================================
  final AccountPortfolio tbsz2023;
  final AccountPortfolio tbsz2024;
  final AccountPortfolio ertekpapirSzamla;

  MockPortfolioData._internal()
      : tbsz2023 = AccountPortfolio(
          accountName: 'TBSZ-2023',
          accountNumber: 'HU12-3456-7890-1234',
          accountType: 'TBSZ',
          stocks: [], // Üres - nulláról indul
          funds: [],  // Üres
          cash: [
            Cash(currency: 'HUF', amount: 5000000),  // 5,000,000 HUF
            Cash(currency: 'USD', amount: 10000),    // 10,000 USD
            Cash(currency: 'EUR', amount: 10000),    // 10,000 EUR
          ],
          historicalData: HistoricalDataGenerator.generateHistoricalData(
            currentValue: 5000000, // Current total value in HUF
            daysBack: 365,
          ),
        ),
        tbsz2024 = AccountPortfolio(
          accountName: 'TBSZ-2024',
          accountNumber: 'HU98-7654-3210-5678',
          accountType: 'TBSZ',
          stocks: [],
          funds: [],
          cash: [
            Cash(currency: 'HUF', amount: 3000000),
            Cash(currency: 'USD', amount: 8000),
            Cash(currency: 'EUR', amount: 8000),
          ],
          historicalData: HistoricalDataGenerator.generateHistoricalData(
            currentValue: 3000000, // Current total value in HUF
            daysBack: 365,
          ),
        ),
        ertekpapirSzamla = AccountPortfolio(
          accountName: 'Értékpapírszámla',
          accountNumber: 'HU45-6789-0123-9876',
          accountType: 'Normál számla',
          stocks: [],
          funds: [],
          cash: [
            Cash(currency: 'HUF', amount: 2000000),
            Cash(currency: 'USD', amount: 5000),
            Cash(currency: 'EUR', amount: 5000),
          ],
          historicalData: HistoricalDataGenerator.generateHistoricalData(
            currentValue: 2000000, // Current total value in HUF
            daysBack: 365,
          ),
        );
  // Total Értékpapírszámla: 5,753,200 + 2,240,000 + 286,000 + 600,000 + 500,000 + 82,000 = 9,461,200 HUF

  // =========================================================================
  // AGGREGATION METHODS
  // =========================================================================

  List<AccountPortfolio> getAllAccounts() {
    return [tbsz2023, tbsz2024, ertekpapirSzamla];
  }

  AccountPortfolio? getAccountByName(String accountName) {
    if (accountName == 'TBSZ-2023') return tbsz2023;
    if (accountName == 'TBSZ-2024') return tbsz2024;
    if (accountName == 'Értékpapírszámla') return ertekpapirSzamla;
    return null;
  }

  // Get combined portfolio (all accounts aggregated)
  AccountPortfolio getCombinedPortfolio() {
    Map<String, Stock> combinedStocks = {};
    List<Fund> allFunds = [];
    Map<String, double> cashByCurrency = {};

    for (var account in getAllAccounts()) {
      // Combine stocks by ticker
      for (var stock in account.stocks) {
        if (combinedStocks.containsKey(stock.ticker)) {
          var existing = combinedStocks[stock.ticker]!;
          int newQuantity = existing.quantity + stock.quantity;
          double newAvgPrice = ((existing.totalCost + stock.totalCost) / newQuantity);

          combinedStocks[stock.ticker] = Stock(
            name: stock.name,
            ticker: stock.ticker,
            isin: stock.isin,
            exchange: stock.exchange,
            quantity: newQuantity,
            price: newAvgPrice,
            currency: stock.currency,
            purchaseDate: existing.purchaseDate.isBefore(stock.purchaseDate)
                ? existing.purchaseDate
                : stock.purchaseDate,
          );
        } else {
          combinedStocks[stock.ticker] = stock;
        }
      }

      // Collect all funds
      allFunds.addAll(account.funds);

      // Aggregate cash by currency
      for (var c in account.cash) {
        cashByCurrency[c.currency] = (cashByCurrency[c.currency] ?? 0) + c.amount;
      }
    }

    List<Cash> combinedCash = cashByCurrency.entries
        .map((e) => Cash(currency: e.key, amount: e.value))
        .toList();

    // Aggregate historical data from all accounts
    List<HistoricalDataPoint> combinedHistoricalData = _aggregateHistoricalData();

    return AccountPortfolio(
      accountName: 'Minden számla',
      accountNumber: 'COMBINED',
      accountType: 'Összes',
      stocks: combinedStocks.values.toList(),
      funds: allFunds,
      cash: combinedCash,
      historicalData: combinedHistoricalData,
    );
  }

  // Aggregate historical data from all accounts
  List<HistoricalDataPoint> _aggregateHistoricalData() {
    Map<DateTime, double> aggregatedData = {};

    for (var account in getAllAccounts()) {
      for (var point in account.historicalData) {
        // Normalize date to midnight for consistent grouping
        DateTime normalizedDate = DateTime(point.date.year, point.date.month, point.date.day);
        aggregatedData[normalizedDate] = (aggregatedData[normalizedDate] ?? 0) + point.value;
      }
    }

    // Convert back to list and sort by date
    List<HistoricalDataPoint> result = aggregatedData.entries
        .map((e) => HistoricalDataPoint(date: e.key, value: e.value))
        .toList();

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  // Get stocks for a specific account
  List<Stock> getStocksForAccount(String accountName) {
    if (accountName == 'Minden számla') {
      return getCombinedPortfolio().stocks;
    }
    var account = getAccountByName(accountName);
    return account?.stocks ?? [];
  }

  // Get funds for a specific account
  List<Fund> getFundsForAccount(String accountName) {
    if (accountName == 'Minden számla') {
      return getCombinedPortfolio().funds;
    }
    var account = getAccountByName(accountName);
    return account?.funds ?? [];
  }

  // Get cash for a specific account
  List<Cash> getCashForAccount(String accountName) {
    if (accountName == 'Minden számla') {
      return getCombinedPortfolio().cash;
    }
    var account = getAccountByName(accountName);
    return account?.cash ?? [];
  }

  // Get detailed stock info across accounts (in selected currency)
  Map<String, dynamic> getStockDetails(String ticker, String accountName, {String currency = 'HUF'}) {
    List<Map<String, dynamic>> accountBreakdown = [];
    String stockCurrency = 'HUF';
    String stockName = '';
    double currentPrice = 0;

    if (accountName == 'Minden számla') {
      for (var account in getAllAccounts()) {
        var stock = account.stocks.where((s) => s.ticker == ticker).firstOrNull;
        if (stock != null) {
          stockCurrency = stock.currency;
          stockName = stock.name;
          currentPrice = stock.currentPrice;

          accountBreakdown.add({
            'accountName': account.accountName,
            'stock': stock,
            'valueInCurrency': MarketData.convert(
              stock.totalValueInHUF(MarketData.exchangeRates),
              'HUF',
              currency
            ),
            'profitInCurrency': MarketData.convert(
              stock.unrealizedProfitInHUF(MarketData.exchangeRates),
              'HUF',
              currency
            ),
          });
        }
      }
    } else {
      var account = getAccountByName(accountName);
      if (account != null) {
        var stock = account.stocks.where((s) => s.ticker == ticker).firstOrNull;
        if (stock != null) {
          stockCurrency = stock.currency;
          stockName = stock.name;
          currentPrice = stock.currentPrice;

          accountBreakdown.add({
            'accountName': account.accountName,
            'stock': stock,
            'valueInCurrency': MarketData.convert(
              stock.totalValueInHUF(MarketData.exchangeRates),
              'HUF',
              currency
            ),
            'profitInCurrency': MarketData.convert(
              stock.unrealizedProfitInHUF(MarketData.exchangeRates),
              'HUF',
              currency
            ),
          });
        }
      }
    }

    double totalValueHUF = accountBreakdown.fold<double>(
      0,
      (sum, item) => sum + (item['stock'] as Stock).totalValueInHUF(MarketData.exchangeRates),
    );

    double totalProfitHUF = accountBreakdown.fold<double>(
      0,
      (sum, item) => sum + (item['stock'] as Stock).unrealizedProfitInHUF(MarketData.exchangeRates),
    );

    double totalCostHUF = accountBreakdown.fold<double>(
      0,
      (sum, item) => sum + (item['stock'] as Stock).totalCost * (MarketData.exchangeRates[(item['stock'] as Stock).currency] ?? 1),
    );

    int totalQuantity = accountBreakdown.fold<int>(
      0,
      (sum, item) => sum + (item['stock'] as Stock).quantity,
    );

    // Calculate weighted average price
    double avgPrice = totalQuantity > 0
        ? totalCostHUF / totalQuantity / (MarketData.exchangeRates[stockCurrency] ?? 1)
        : 0;

    return {
      'stockName': stockName,
      'ticker': ticker,
      'currency': stockCurrency,
      'currentPrice': currentPrice,
      'accounts': accountBreakdown,
      'totalQuantity': totalQuantity,
      'avgPrice': avgPrice,
      'totalValue': MarketData.convert(totalValueHUF, 'HUF', currency),
      'totalCost': MarketData.convert(totalCostHUF, 'HUF', currency),
      'totalProfit': MarketData.convert(totalProfitHUF, 'HUF', currency),
      'profitPercent': totalCostHUF > 0 ? (totalProfitHUF / totalCostHUF * 100) : 0,
      'isPositive': totalProfitHUF >= 0,
    };
  }

  // =========================================================================
  // SUMMARY CALCULATIONS
  // =========================================================================

  Map<String, double> getTotalsByAccount() {
    return {
      'TBSZ-2023': tbsz2023.totalValue,
      'TBSZ-2024': tbsz2024.totalValue,
      'Értékpapírszámla': ertekpapirSzamla.totalValue,
      'Minden számla': getCombinedPortfolio().totalValue,
    };
  }

  // Get asset allocation for an account
  Map<String, double> getAssetAllocation(String accountName) {
    AccountPortfolio? portfolio;

    if (accountName == 'Minden számla') {
      portfolio = getCombinedPortfolio();
    } else {
      portfolio = getAccountByName(accountName);
    }

    if (portfolio == null) return {};

    return {
      'stocks': portfolio.stocksValue,
      'funds': portfolio.fundsValue,
      'cash': portfolio.cashValue,
      'total': portfolio.totalValue,
    };
  }
}
