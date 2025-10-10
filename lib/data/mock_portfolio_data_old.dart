class Stock {
  final String name;
  final String ticker;
  final int quantity;
  final double avgPrice;
  final double currentPrice;
  final String currency;

  Stock({
    required this.name,
    required this.ticker,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
    required this.currency,
  });

  double get totalValue => quantity * currentPrice;
  double get totalCost => quantity * avgPrice;
  double get unrealizedProfit => totalValue - totalCost;
  double get profitPercent => ((currentPrice - avgPrice) / avgPrice) * 100;
  bool get isPositive => unrealizedProfit >= 0;
}

class Fund {
  final String name;
  final double value;
  final String currency;

  Fund({
    required this.name,
    required this.value,
    required this.currency,
  });
}

class Cash {
  final String currency;
  final double amount;

  Cash({
    required this.currency,
    required this.amount,
  });
}

class AccountPortfolio {
  final String accountName;
  final List<Stock> stocks;
  final List<Fund> funds;
  final List<Cash> cash;

  AccountPortfolio({
    required this.accountName,
    required this.stocks,
    List<Fund>? funds,
    List<Cash>? cash,
  }) : funds = funds ?? [],
       cash = cash ?? [];

  double _convertToHUF(double value, String currency) {
    if (currency == 'HUF') return value;
    if (currency == 'USD') return value * 380;
    if (currency == 'EUR') return value * 410;
    return value;
  }

  double get totalValue {
    double hufTotal = 0;

    // Add stocks
    for (var stock in stocks) {
      hufTotal += _convertToHUF(stock.totalValue, stock.currency);
    }

    // Add funds
    for (var fund in funds) {
      hufTotal += _convertToHUF(fund.value, fund.currency);
    }

    // Add cash
    for (var c in cash) {
      hufTotal += _convertToHUF(c.amount, c.currency);
    }

    return hufTotal;
  }

  double get stocksValue {
    double hufTotal = 0;
    for (var stock in stocks) {
      hufTotal += _convertToHUF(stock.totalValue, stock.currency);
    }
    return hufTotal;
  }

  double get fundsValue {
    double hufTotal = 0;
    for (var fund in funds) {
      hufTotal += _convertToHUF(fund.value, fund.currency);
    }
    return hufTotal;
  }

  double get cashValue {
    double hufTotal = 0;
    for (var c in cash) {
      hufTotal += _convertToHUF(c.amount, c.currency);
    }
    return hufTotal;
  }

  double get totalUnrealizedProfit {
    double hufTotal = 0;
    for (var stock in stocks) {
      if (stock.currency == 'HUF') {
        hufTotal += stock.unrealizedProfit;
      } else if (stock.currency == 'USD') {
        hufTotal += stock.unrealizedProfit * 380;
      } else if (stock.currency == 'EUR') {
        hufTotal += stock.unrealizedProfit * 410;
      }
    }
    return hufTotal;
  }

  double get totalProfitPercent {
    double totalCost = 0;
    for (var stock in stocks) {
      if (stock.currency == 'HUF') {
        totalCost += stock.totalCost;
      } else if (stock.currency == 'USD') {
        totalCost += stock.totalCost * 380;
      } else if (stock.currency == 'EUR') {
        totalCost += stock.totalCost * 410;
      }
    }
    return totalCost > 0 ? (totalUnrealizedProfit / totalCost) * 100 : 0;
  }
}

class MockPortfolioData {
  static final MockPortfolioData _instance = MockPortfolioData._internal();

  factory MockPortfolioData() {
    return _instance;
  }

  MockPortfolioData._internal();

  // TBSZ 2023 portfolio - Total: ~7,950,000 HUF
  final AccountPortfolio tbsz2023 = AccountPortfolio(
    accountName: 'TBSZ 2023',
    stocks: [
      Stock(
        name: 'NVIDIA Corp.',
        ticker: 'NVDA',
        quantity: 50,
        avgPrice: 140.00,
        currentPrice: 172.41,
        currency: 'USD',
      ), // 50 * 172.41 * 380 = 3,275,790 HUF
      Stock(
        name: 'Apple Inc.',
        ticker: 'AAPL',
        quantity: 80,
        avgPrice: 150.00,
        currentPrice: 175.50,
        currency: 'USD',
      ), // 80 * 175.50 * 380 = 5,328,000 HUF
      Stock(
        name: 'OTP Bank',
        ticker: 'OTP',
        quantity: 100,
        avgPrice: 18500,
        currentPrice: 21300,
        currency: 'HUF',
      ), // 100 * 21300 = 2,130,000 HUF
    ],
    funds: [
      Fund(name: 'Concorde Alap', value: 500000, currency: 'HUF'),
    ], // 500,000 HUF
    cash: [
      Cash(currency: 'HUF', amount: 400000), // 400,000 HUF
      Cash(currency: 'USD', amount: 100), // 100 * 380 = 38,000 HUF
    ],
  ); // Total: 3,275,790 + 5,328,000 + 2,130,000 + 500,000 + 400,000 + 38,000 = 11,671,790 HUF

  // TBSZ 2024 portfolio - Total: ~8,200,000 HUF
  final AccountPortfolio tbsz2024 = AccountPortfolio(
    accountName: 'TBSZ 2024',
    stocks: [
      Stock(
        name: 'NVIDIA Corp.',
        ticker: 'NVDA',
        quantity: 50,
        avgPrice: 140.00,
        currentPrice: 172.41,
        currency: 'USD',
      ), // 50 * 172.41 * 380 = 3,275,790 HUF
      Stock(
        name: 'Vodafone Group',
        ticker: 'VOD',
        quantity: 2220,
        avgPrice: 340,
        currentPrice: 286,
        currency: 'HUF',
      ), // 2220 * 286 = 634,920 HUF
      Stock(
        name: 'Tesla Inc.',
        ticker: 'TSLA',
        quantity: 30,
        avgPrice: 220.00,
        currentPrice: 245.80,
        currency: 'USD',
      ), // 30 * 245.80 * 380 = 2,802,120 HUF
    ],
    funds: [
      Fund(name: 'Befektetési Alap', value: 800000, currency: 'HUF'),
    ], // 800,000 HUF
    cash: [
      Cash(currency: 'HUF', amount: 600000), // 600,000 HUF
      Cash(currency: 'USD', amount: 200), // 200 * 380 = 76,000 HUF
    ],
  ); // Total: 3,275,790 + 634,920 + 2,802,120 + 800,000 + 600,000 + 76,000 = 8,188,830 HUF

  // Értékpapírszámla portfolio - Total: ~9,500,000 HUF
  final AccountPortfolio ertekpapirSzamla = AccountPortfolio(
    accountName: 'Értékpapírszámla',
    stocks: [
      Stock(
        name: 'Vodafone Group',
        ticker: 'VOD',
        quantity: 2220,
        avgPrice: 340,
        currentPrice: 286,
        currency: 'HUF',
      ), // 2220 * 286 = 634,920 HUF
      Stock(
        name: 'Microsoft Corp.',
        ticker: 'MSFT',
        quantity: 40,
        avgPrice: 320.00,
        currentPrice: 378.50,
        currency: 'USD',
      ), // 40 * 378.50 * 380 = 5,751,400 HUF
      Stock(
        name: 'Richter Gedeon',
        ticker: 'RICHTER',
        quantity: 200,
        avgPrice: 9800,
        currentPrice: 11200,
        currency: 'HUF',
      ), // 200 * 11200 = 2,240,000 HUF
    ],
    funds: [
      Fund(name: 'Pénzpiaci Alap', value: 300000, currency: 'HUF'),
    ], // 300,000 HUF
    cash: [
      Cash(currency: 'HUF', amount: 500000), // 500,000 HUF
      Cash(currency: 'EUR', amount: 200), // 200 * 410 = 82,000 HUF
    ],
  ); // Total: 634,920 + 5,751,400 + 2,240,000 + 300,000 + 500,000 + 82,000 = 9,508,320 HUF

  // Get all accounts
  List<AccountPortfolio> getAllAccounts() {
    return [tbsz2023, tbsz2024, ertekpapirSzamla];
  }

  // Get account by name
  AccountPortfolio? getAccountByName(String accountName) {
    if (accountName == 'TBSZ 2023') return tbsz2023;
    if (accountName == 'TBSZ 2024') return tbsz2024;
    if (accountName == 'Értékpapírszámla') return ertekpapirSzamla;
    return null;
  }

  // Get combined portfolio (all accounts)
  AccountPortfolio getCombinedPortfolio() {
    Map<String, Stock> combinedStocks = {};
    List<Fund> allFunds = [];
    Map<String, double> cashByCurrency = {};

    for (var account in getAllAccounts()) {
      // Combine stocks
      for (var stock in account.stocks) {
        if (combinedStocks.containsKey(stock.ticker)) {
          // Combine quantities and recalculate average price
          var existing = combinedStocks[stock.ticker]!;
          int newQuantity = existing.quantity + stock.quantity;
          double newAvgPrice = ((existing.totalCost + stock.totalCost) / newQuantity);

          combinedStocks[stock.ticker] = Stock(
            name: stock.name,
            ticker: stock.ticker,
            quantity: newQuantity,
            avgPrice: newAvgPrice,
            currentPrice: stock.currentPrice,
            currency: stock.currency,
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

    // Convert cash map to list
    List<Cash> combinedCash = cashByCurrency.entries
        .map((e) => Cash(currency: e.key, amount: e.value))
        .toList();

    return AccountPortfolio(
      accountName: 'Minden számla',
      stocks: combinedStocks.values.toList(),
      funds: allFunds,
      cash: combinedCash,
    );
  }

  // Get stocks for a specific account or all accounts
  List<Stock> getStocksForAccount(String accountName) {
    if (accountName == 'Minden számla') {
      return getCombinedPortfolio().stocks;
    }
    var account = getAccountByName(accountName);
    return account?.stocks ?? [];
  }

  // Get stock details across all accounts
  Map<String, dynamic> getStockDetails(String ticker, String accountName) {
    List<Map<String, dynamic>> accountBreakdown = [];

    if (accountName == 'Minden számla') {
      // Get stock from all accounts
      for (var account in getAllAccounts()) {
        var stock = account.stocks.where((s) => s.ticker == ticker).firstOrNull;
        if (stock != null) {
          accountBreakdown.add({
            'accountName': account.accountName,
            'stock': stock,
          });
        }
      }
    } else {
      // Get stock from specific account
      var account = getAccountByName(accountName);
      if (account != null) {
        var stock = account.stocks.where((s) => s.ticker == ticker).firstOrNull;
        if (stock != null) {
          accountBreakdown.add({
            'accountName': account.accountName,
            'stock': stock,
          });
        }
      }
    }

    return {
      'accounts': accountBreakdown,
      'totalQuantity': accountBreakdown.fold<int>(0, (sum, item) => sum + (item['stock'] as Stock).quantity),
      'totalValue': accountBreakdown.fold<double>(0, (sum, item) => sum + (item['stock'] as Stock).totalValue),
      'totalProfit': accountBreakdown.fold<double>(0, (sum, item) => sum + (item['stock'] as Stock).unrealizedProfit),
    };
  }
}
