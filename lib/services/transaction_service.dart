import 'package:flutter/foundation.dart';
import '../data/mock_portfolio_data.dart';
import '../data/market_stocks_data.dart';
import '../models/order_model.dart';

enum OrderType { market, limit }
enum TransactionType { buy, sell }

class PendingOrder {
  final String ticker;
  final String stockName;
  final int quantity;
  final double limitPrice;
  final String currency;
  final String accountName;
  final TransactionType type;
  final DateTime createdAt;

  PendingOrder({
    required this.ticker,
    required this.stockName,
    required this.quantity,
    required this.limitPrice,
    required this.currency,
    required this.accountName,
    required this.type,
    required this.createdAt,
  });
}

class CompletedTransaction {
  final String ticker;
  final String stockName;
  final int quantity;
  final double price;
  final double totalValue;
  final String currency;
  final String accountName;
  final TransactionType type;
  final DateTime completedAt;
  bool isViewed;

  CompletedTransaction({
    required this.ticker,
    required this.stockName,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.currency,
    required this.accountName,
    required this.type,
    required this.completedAt,
    this.isViewed = false,
  });
}

class TransactionService extends ChangeNotifier {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final MockPortfolioData _portfolioData = MockPortfolioData();
  final List<PendingOrder> _pendingOrders = [];
  final List<CompletedTransaction> _completedTransactions = [];
  final List<Order> _orders = [];

  List<PendingOrder> get pendingOrders => List.unmodifiable(_pendingOrders);
  List<CompletedTransaction> get completedTransactions => List.unmodifiable(_completedTransactions);
  List<Order> get orders => List.unmodifiable(_orders);

  int get unviewedTransactionCount => _completedTransactions.where((t) => !t.isViewed).length;
  int get unviewedOrderCount => _orders.where((o) => !o.isViewed && o.status == OrderStatus.open).length;

  void markAllTransactionsAsViewed() {
    for (var transaction in _completedTransactions) {
      transaction.isViewed = true;
    }
    notifyListeners();
  }

  void markAllOrdersAsViewed() {
    for (var order in _orders) {
      order.isViewed = true;
    }
    notifyListeners();
  }

  // Add a new order
  String addOrder({
    required String ticker,
    required String stockName,
    required OrderAction action,
    required int quantity,
    double? limitPrice,
    required String currency,
    required String accountName,
    DateTime? expiresAt,
  }) {
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    final order = Order(
      id: orderId,
      ticker: ticker,
      stockName: stockName,
      action: action,
      orderedQuantity: quantity,
      limitPrice: limitPrice,
      currency: currency,
      accountName: accountName,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      status: OrderStatus.open,
      isViewed: false,
    );

    _orders.insert(0, order);
    notifyListeners();
    return orderId;
  }

  // Cancel an order
  void cancelOrder(String orderId) {
    final order = _orders.firstWhere((o) => o.id == orderId);
    order.status = OrderStatus.cancelled;
    order.isViewed = false;
    notifyListeners();
  }

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // Get open orders
  List<Order> get openOrders => getOrdersByStatus(OrderStatus.open);

  // Get completed orders
  List<Order> get completedOrders => getOrdersByStatus(OrderStatus.completed);

  // Get cancelled orders
  List<Order> get cancelledOrders => getOrdersByStatus(OrderStatus.cancelled);

  // Get expired orders
  List<Order> get expiredOrders {
    return _orders.where((o) => o.isExpired).toList();
  }

  // Execute a buy transaction
  bool executeBuy({
    required String ticker,
    required String stockName,
    required int quantity,
    required double price,
    required String accountName,
    required OrderType orderType,
  }) {
    // Get stock details from market
    MarketStock? marketStock = MarketStocksData.getByTicker(ticker);
    if (marketStock == null) return false;

    String currency = marketStock.currency;
    String exchange = marketStock.exchange;
    String isin = 'ISIN_${ticker}'; // Mock ISIN

    if (orderType == OrderType.limit) {
      // Add to pending orders
      _pendingOrders.add(PendingOrder(
        ticker: ticker,
        stockName: stockName,
        quantity: quantity,
        limitPrice: price,
        currency: currency,
        accountName: accountName,
        type: TransactionType.buy,
        createdAt: DateTime.now(),
      ));

      // Also add to new Order system
      addOrder(
        ticker: ticker,
        stockName: stockName,
        action: OrderAction.buy,
        quantity: quantity,
        limitPrice: price,
        currency: currency,
        accountName: accountName,
        expiresAt: DateTime.now().add(Duration(days: 30)), // Default 30 days
      );

      return true;
    }

    // Market order - execute immediately
    AccountPortfolio? account = _portfolioData.getAccountByName(accountName);
    if (account == null) {
      print('❌ Account not found: $accountName');
      return false;
    }

    // Calculate total cost in stock's currency
    double totalCost = quantity * price;

    // Check if account has enough cash in the required currency
    int cashIndex = account.cash.indexWhere((c) => c.currency == currency);

    // DEBUG
    print('🔍 BUY DEBUG:');
    print('  Account requested: $accountName');
    print('  Account found: ${account.accountName}');
    print('  Currency needed: $currency');
    print('  Total cost: $totalCost');
    print('  Cash list length: ${account.cash.length}');
    print('  Cash index: $cashIndex');
    if (cashIndex >= 0) {
      print('  Available: ${account.cash[cashIndex].amount}');
      print('  Is enough? ${account.cash[cashIndex].amount >= totalCost}');
    }
    print('  All cash in account:');
    for (int i = 0; i < account.cash.length; i++) {
      print('    [$i] ${account.cash[i].currency}: ${account.cash[i].amount}');
    }

    if (cashIndex < 0) {
      print('  ❌ FAILED: Currency $currency not found in account');
      return false;
    }

    if (account.cash[cashIndex].amount < totalCost) {
      print('  ❌ FAILED: Not enough cash (have: ${account.cash[cashIndex].amount}, need: $totalCost)');
      return false;
    }

    print('  ✅ Cash check passed - proceeding with purchase');

    // Deduct cash from account using removeAt + insert to ensure mutability
    double newAmount = account.cash[cashIndex].amount - totalCost;
    print('  💰 Deducting $totalCost $currency (new balance: $newAmount)');

    account.cash.removeAt(cashIndex);
    account.cash.insert(cashIndex, Cash(
      currency: currency,
      amount: newAmount,
    ));

    // Check if stock already exists in account
    int existingIndex = account.stocks.indexWhere((s) => s.ticker == ticker);

    if (existingIndex >= 0) {
      // Update existing stock - új átlagár számítás
      Stock existing = account.stocks[existingIndex];
      int newQuantity = existing.quantity + quantity;
      double newAvgPrice = ((existing.quantity * existing.price) + (quantity * price)) / newQuantity;

      print('  📊 Updating existing stock: ${existing.quantity}db -> ${newQuantity}db, avg price: ${existing.price} -> ${newAvgPrice}');

      account.stocks.removeAt(existingIndex);
      account.stocks.insert(existingIndex, Stock(
        name: stockName,
        ticker: ticker,
        isin: isin,
        exchange: exchange,
        quantity: newQuantity,
        price: newAvgPrice,
        currency: currency,
        purchaseDate: existing.purchaseDate,
      ));
    } else {
      // Add new stock
      print('  📊 Adding new stock: ${quantity}db of $ticker at $price $currency');
      account.stocks.add(Stock(
        name: stockName,
        ticker: ticker,
        isin: isin,
        exchange: exchange,
        quantity: quantity,
        price: price,
        currency: currency,
        purchaseDate: DateTime.now(),
      ));
    }

    print('  ✅ Transaction completed successfully!');
    print('  📈 New stock count in account: ${account.stocks.length}');

    // Add to completed transactions
    _completedTransactions.insert(0, CompletedTransaction(
      ticker: ticker,
      stockName: stockName,
      quantity: quantity,
      price: price,
      totalValue: totalCost,
      currency: currency,
      accountName: accountName,
      type: TransactionType.buy,
      completedAt: DateTime.now(),
      isViewed: false,
    ));

    notifyListeners(); // Notify UI of changes
    return true;
  }

  // Execute a sell transaction
  bool executeSell({
    required String ticker,
    required int quantity,
    required double price,
    required String accountName,
    required OrderType orderType,
  }) {
    AccountPortfolio? account = _portfolioData.getAccountByName(accountName);
    if (account == null) return false;

    // Find the stock in account
    int stockIndex = account.stocks.indexWhere((s) => s.ticker == ticker);
    if (stockIndex < 0) return false; // Stock not found

    Stock stock = account.stocks[stockIndex];

    // Check if we have enough quantity
    if (stock.quantity < quantity) return false;

    if (orderType == OrderType.limit) {
      // Add to pending orders
      _pendingOrders.add(PendingOrder(
        ticker: ticker,
        stockName: stock.name,
        quantity: quantity,
        limitPrice: price,
        currency: stock.currency,
        accountName: accountName,
        type: TransactionType.sell,
        createdAt: DateTime.now(),
      ));

      // Also add to new Order system
      addOrder(
        ticker: ticker,
        stockName: stock.name,
        action: OrderAction.sell,
        quantity: quantity,
        limitPrice: price,
        currency: stock.currency,
        accountName: accountName,
        expiresAt: DateTime.now().add(Duration(days: 30)), // Default 30 days
      );

      return true;
    }

    // Market order - execute immediately
    // Calculate proceeds
    double proceeds = quantity * price;

    // Add cash back to account
    int cashIndex = account.cash.indexWhere((c) => c.currency == stock.currency);
    if (cashIndex >= 0) {
      // Update existing cash using removeAt + insert
      double newAmount = account.cash[cashIndex].amount + proceeds;
      account.cash.removeAt(cashIndex);
      account.cash.insert(cashIndex, Cash(
        currency: stock.currency,
        amount: newAmount,
      ));
    } else {
      // Create new cash entry if currency doesn't exist
      account.cash.add(Cash(
        currency: stock.currency,
        amount: proceeds,
      ));
    }

    if (stock.quantity == quantity) {
      // Remove stock completely
      account.stocks.removeAt(stockIndex);
    } else {
      // Reduce quantity - ár változatlan marad, removeAt + insert
      account.stocks.removeAt(stockIndex);
      account.stocks.insert(stockIndex, Stock(
        name: stock.name,
        ticker: stock.ticker,
        isin: stock.isin,
        exchange: stock.exchange,
        quantity: stock.quantity - quantity,
        price: stock.price,
        currency: stock.currency,
        purchaseDate: stock.purchaseDate,
      ));
    }

    // Add to completed transactions
    _completedTransactions.insert(0, CompletedTransaction(
      ticker: ticker,
      stockName: stock.name,
      quantity: quantity,
      price: price,
      totalValue: proceeds,
      currency: stock.currency,
      accountName: accountName,
      type: TransactionType.sell,
      completedAt: DateTime.now(),
      isViewed: false,
    ));

    notifyListeners(); // Notify UI of changes
    return true;
  }

  // Get available quantity for a stock in an account
  int getAvailableQuantity(String ticker, String accountName) {
    AccountPortfolio? account = _portfolioData.getAccountByName(accountName);
    if (account == null) return 0;

    Stock? stock = account.stocks.firstWhere(
      (s) => s.ticker == ticker,
      orElse: () => Stock(
        name: '',
        ticker: '',
        isin: '',
        exchange: '',
        quantity: 0,
        price: 0,
        currency: 'HUF',
        purchaseDate: DateTime.now(),
      ),
    );

    return stock.quantity;
  }

  // Cancel a pending order
  void cancelOrder(PendingOrder order) {
    _pendingOrders.remove(order);
  }
}
