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
  final double avgPrice;
  final double currentPrice;
  final String currency;
  final DateTime purchaseDate;

  Stock({
    required this.name,
    required this.ticker,
    required this.isin,
    required this.exchange,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
    required this.currency,
    required this.purchaseDate,
  });

  // Calculated values
  double get totalValue => quantity * currentPrice;
  double get totalCost => quantity * avgPrice;
  double get unrealizedProfit => totalValue - totalCost;
  double get profitPercent => totalCost > 0 ? ((currentPrice - avgPrice) / avgPrice) * 100 : 0;
  bool get isPositive => unrealizedProfit >= 0;

  // Convert to HUF
  double totalValueInHUF(Map<String, double> rates) {
    return totalValue * (rates[currency] ?? 1);
  }

  double unrealizedProfitInHUF(Map<String, double> rates) {
    return unrealizedProfit * (rates[currency] ?? 1);
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
    'NVDA': StockPrice(currentPrice: 172.41, currency: 'USD'),
    'AAPL': StockPrice(currentPrice: 175.50, currency: 'USD'),
    'TSLA': StockPrice(currentPrice: 245.80, currency: 'USD'),
    'MSFT': StockPrice(currentPrice: 378.50, currency: 'USD'),
    'OTP': StockPrice(currentPrice: 21300, currency: 'HUF'),
    'VOD': StockPrice(currentPrice: 286, currency: 'HUF'),
    'RICHTER': StockPrice(currentPrice: 11200, currency: 'HUF'),
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
  // =========================================================================
  // ACCOUNT 1: TBSZ 2023
  // Target Total: ~11,671,790 HUF
  // =========================================================================
  final AccountPortfolio tbsz2023 = AccountPortfolio(
    accountName: 'TBSZ 2023',
    accountNumber: 'HU12-3456-7890-1234',
    accountType: 'TBSZ',
    stocks: [
      // NVIDIA: 50 × $172.41 = $8,620.50 × 380 = 3,275,790 HUF
      Stock(
        name: 'NVIDIA Corp.',
        ticker: 'NVDA',
        isin: 'US67066G1040',
        exchange: 'NASDAQ',
        quantity: 50,
        avgPrice: 140.00,
        currentPrice: 172.41,
        currency: 'USD',
        purchaseDate: DateTime(2023, 5, 15),
      ),
      // Apple: 80 × $175.50 = $14,040 × 380 = 5,335,200 HUF
      Stock(
        name: 'Apple Inc.',
        ticker: 'AAPL',
        isin: 'US0378331005',
        exchange: 'NASDAQ',
        quantity: 80,
        avgPrice: 150.00,
        currentPrice: 175.50,
        currency: 'USD',
        purchaseDate: DateTime(2023, 6, 20),
      ),
      // OTP: 100 × 21,300 = 2,130,000 HUF
      Stock(
        name: 'OTP Bank',
        ticker: 'OTP',
        isin: 'HU0000061726',
        exchange: 'BSE',
        quantity: 100,
        avgPrice: 18500,
        currentPrice: 21300,
        currency: 'HUF',
        purchaseDate: DateTime(2023, 4, 10),
      ),
    ],
    funds: [
      // Concorde Alap: 500,000 HUF
      Fund(
        name: 'Concorde Alap',
        isin: 'HU0000123456',
        units: 50,
        unitPrice: 10000,
        purchasePrice: 9500,
        currency: 'HUF',
        purchaseDate: DateTime(2023, 3, 1),
      ),
    ],
    cash: [
      Cash(currency: 'HUF', amount: 400000),  // 400,000 HUF
      Cash(currency: 'USD', amount: 100),     // 100 × 380 = 38,000 HUF
    ],
    historicalData: HistoricalDataGenerator.generateHistoricalData(
      currentValue: 11678990, // Current total value in HUF
      daysBack: 365,
    ),
  );
  // Total TBSZ 2023: 3,275,790 + 5,335,200 + 2,130,000 + 500,000 + 400,000 + 38,000 = 11,678,990 HUF

  // =========================================================================
  // ACCOUNT 2: TBSZ 2024
  // Target Total: ~8,188,830 HUF
  // =========================================================================
  final AccountPortfolio tbsz2024 = AccountPortfolio(
    accountName: 'TBSZ 2024',
    accountNumber: 'HU98-7654-3210-5678',
    accountType: 'TBSZ',
    stocks: [
      // NVIDIA: 30 × $172.41 = $5,172.30 × 380 = 1,965,474 HUF
      Stock(
        name: 'NVIDIA Corp.',
        ticker: 'NVDA',
        isin: 'US67066G1040',
        exchange: 'NASDAQ',
        quantity: 30,
        avgPrice: 145.00,
        currentPrice: 172.41,
        currency: 'USD',
        purchaseDate: DateTime(2024, 1, 15),
      ),
      // Vodafone: 2220 × 286 = 634,920 HUF
      Stock(
        name: 'Vodafone Group',
        ticker: 'VOD',
        isin: 'HU0000071234',
        exchange: 'BSE',
        quantity: 2220,
        avgPrice: 340,
        currentPrice: 286,
        currency: 'HUF',
        purchaseDate: DateTime(2024, 2, 10),
      ),
      // Tesla: 50 × $245.80 = $12,290 × 380 = 4,670,200 HUF
      Stock(
        name: 'Tesla Inc.',
        ticker: 'TSLA',
        isin: 'US88160R1014',
        exchange: 'NASDAQ',
        quantity: 50,
        avgPrice: 220.00,
        currentPrice: 245.80,
        currency: 'USD',
        purchaseDate: DateTime(2024, 3, 5),
      ),
    ],
    funds: [
      // Befektetési Alap: 300,000 HUF
      Fund(
        name: 'Befektetési Alap',
        isin: 'HU0000234567',
        units: 30,
        unitPrice: 10000,
        purchasePrice: 9800,
        currency: 'HUF',
        purchaseDate: DateTime(2024, 1, 5),
      ),
    ],
    cash: [
      Cash(currency: 'HUF', amount: 500000),  // 500,000 HUF
      Cash(currency: 'USD', amount: 150),     // 150 × 380 = 57,000 HUF
    ],
    historicalData: HistoricalDataGenerator.generateHistoricalData(
      currentValue: 8127594, // Current total value in HUF
      daysBack: 365,
    ),
  );
  // Total TBSZ 2024: 1,965,474 + 634,920 + 4,670,200 + 300,000 + 500,000 + 57,000 = 8,127,594 HUF

  // =========================================================================
  // ACCOUNT 3: Értékpapírszámla
  // Target Total: ~9,508,320 HUF
  // =========================================================================
  final AccountPortfolio ertekpapirSzamla = AccountPortfolio(
    accountName: 'Értékpapírszámla',
    accountNumber: 'HU45-6789-0123-9876',
    accountType: 'Normál számla',
    stocks: [
      // Microsoft: 40 × $378.50 = $15,140 × 380 = 5,753,200 HUF
      Stock(
        name: 'Microsoft Corp.',
        ticker: 'MSFT',
        isin: 'US5949181045',
        exchange: 'NASDAQ',
        quantity: 40,
        avgPrice: 320.00,
        currentPrice: 378.50,
        currency: 'USD',
        purchaseDate: DateTime(2023, 8, 12),
      ),
      // Richter: 200 × 11,200 = 2,240,000 HUF
      Stock(
        name: 'Richter Gedeon',
        ticker: 'RICHTER',
        isin: 'HU0000123456',
        exchange: 'BSE',
        quantity: 200,
        avgPrice: 9800,
        currentPrice: 11200,
        currency: 'HUF',
        purchaseDate: DateTime(2023, 9, 5),
      ),
      // Vodafone: 1000 × 286 = 286,000 HUF
      Stock(
        name: 'Vodafone Group',
        ticker: 'VOD',
        isin: 'HU0000071234',
        exchange: 'BSE',
        quantity: 1000,
        avgPrice: 340,
        currentPrice: 286,
        currency: 'HUF',
        purchaseDate: DateTime(2023, 10, 1),
      ),
    ],
    funds: [
      // Pénzpiaci Alap: 600,000 HUF
      Fund(
        name: 'Pénzpiaci Alap',
        isin: 'HU0000345678',
        units: 60,
        unitPrice: 10000,
        purchasePrice: 9700,
        currency: 'HUF',
        purchaseDate: DateTime(2023, 7, 1),
      ),
    ],
    cash: [
      Cash(currency: 'HUF', amount: 500000),  // 500,000 HUF
      Cash(currency: 'EUR', amount: 200),     // 200 × 410 = 82,000 HUF
    ],
    historicalData: HistoricalDataGenerator.generateHistoricalData(
      currentValue: 9461200, // Current total value in HUF
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
    if (accountName == 'TBSZ 2023') return tbsz2023;
    if (accountName == 'TBSZ 2024') return tbsz2024;
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
            avgPrice: newAvgPrice,
            currentPrice: stock.currentPrice,
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
      'TBSZ 2023': tbsz2023.totalValue,
      'TBSZ 2024': tbsz2024.totalValue,
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
