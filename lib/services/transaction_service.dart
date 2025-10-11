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
  TransactionService._internal() {
    _initializeMockOrders();
  }

  final MockPortfolioData _portfolioData = MockPortfolioData();
  final List<PendingOrder> _pendingOrders = [];
  final List<CompletedTransaction> _completedTransactions = [];
  final List<Order> _orders = [];

  void _initializeMockOrders() {
    // Add some mock orders for testing
    _orders.addAll([
      // Open order - partially fulfilled
      Order(
        id: 'ORD_001',
        ticker: 'NVDA',
        stockName: 'NVIDIA Corporation',
        action: OrderAction.buy,
        orderedQuantity: 20,
        fulfilledQuantity: 2,
        limitPrice: 138.50,
        currency: 'USD',
        accountName: 'TBSZ-2024',
        createdAt: DateTime.now().subtract(Duration(hours: 5, minutes: 26)),
        expiresAt: DateTime.now().add(Duration(days: 25)),
        status: OrderStatus.open,
        isViewed: false,
      ),
      // Open order - market price (Piaci)
      Order(
        id: 'ORD_002',
        ticker: 'VODAFONE',
        stockName: 'Vodafone',
        action: OrderAction.sell,
        orderedQuantity: 4440,
        fulfilledQuantity: 0,
        limitPrice: null, // Market order
        currency: 'HUF',
        accountName: 'TBSZ-2024',
        createdAt: DateTime(2025, 7, 22),
        expiresAt: DateTime.now().add(Duration(days: 20)),
        status: OrderStatus.open,
        isViewed: false,
      ),
      // Open order with limit price
      Order(
        id: 'ORD_003',
        ticker: 'NVDA',
        stockName: 'NVIDIA Corporation',
        action: OrderAction.buy,
        orderedQuantity: 100,
        fulfilledQuantity: 56,
        limitPrice: 138.50,
        currency: 'USD',
        accountName: 'TBSZ-2024',
        createdAt: DateTime(2025, 7, 22),
        expiresAt: DateTime.now().add(Duration(days: 18)),
        status: OrderStatus.open,
        isViewed: false,
      ),
      // Completed order
      Order(
        id: 'ORD_004',
        ticker: 'NVDA',
        stockName: 'NVIDIA Corporation',
        action: OrderAction.buy,
        orderedQuantity: 20,
        fulfilledQuantity: 20,
        limitPrice: 138.50,
        currency: 'USD',
        accountName: 'TBSZ-2023',
        createdAt: DateTime(2025, 6, 19),
        expiresAt: DateTime.now().add(Duration(days: 10)),
        status: OrderStatus.completed,
        isViewed: true,
      ),
      // Cancelled order - partially filled
      Order(
        id: 'ORD_005',
        ticker: 'NVDA',
        stockName: 'NVIDIA Corporation',
        action: OrderAction.buy,
        orderedQuantity: 100,
        fulfilledQuantity: 0,
        limitPrice: 138.50,
        currency: 'USD',
        accountName: 'TBSZ-2024',
        createdAt: DateTime(2025, 7, 22),
        status: OrderStatus.cancelled,
        isViewed: true,
      ),
      // Cancelled order - partially filled
      Order(
        id: 'ORD_006',
        ticker: 'NVDA',
        stockName: 'NVIDIA Corporation',
        action: OrderAction.buy,
        orderedQuantity: 100,
        fulfilledQuantity: 56,
        limitPrice: 138.50,
        currency: 'USD',
        accountName: 'TBSZ-2024',
        createdAt: DateTime(2025, 7, 22),
        status: OrderStatus.cancelled,
        isViewed: true,
      ),
      // Expired order
      Order(
        id: 'ORD_007',
        ticker: 'NVDA',
        stockName: 'NVIDIA Corporation',
        action: OrderAction.buy,
        orderedQuantity: 100,
        fulfilledQuantity: 0,
        limitPrice: 138.50,
        currency: 'USD',
        accountName: 'TBSZ-2024',
        createdAt: DateTime(2025, 6, 22),
        expiresAt: DateTime(2025, 7, 22),
        status: OrderStatus.expired,
        isViewed: true,
      ),
    ]);
  }

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

  // Update an existing order
  void updateOrder({
    required String orderId,
    required int quantity,
    required double? limitPrice,
  }) {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      final order = _orders[orderIndex];

      // Update the order
      _orders[orderIndex] = Order(
        id: order.id,
        ticker: order.ticker,
        stockName: order.stockName,
        action: order.action,
        orderedQuantity: quantity,
        fulfilledQuantity: order.fulfilledQuantity,
        limitPrice: limitPrice,
        currency: order.currency,
        accountName: order.accountName,
        createdAt: order.createdAt,
        expiresAt: order.expiresAt,
        status: order.status,
        isViewed: false, // Mark as unviewed after modification
      );

      notifyListeners();
    }
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

  // Cancel a pending order (legacy)
  void cancelPendingOrder(PendingOrder order) {
    _pendingOrders.remove(order);
  }
}
