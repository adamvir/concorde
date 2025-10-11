enum OrderStatus {
  open,        // Nyitott
  completed,   // Teljesült
  cancelled,   // Visszavont
  expired,     // Lejárt
}

enum OrderAction {
  buy,   // Vétel
  sell,  // Eladás
}

class Order {
  final String id;
  final String ticker;
  final String stockName;
  final OrderAction action;
  final int orderedQuantity;
  final int fulfilledQuantity;
  final double? limitPrice; // null if market order
  final String currency;
  final String accountName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  OrderStatus status;
  bool isViewed;

  Order({
    required this.id,
    required this.ticker,
    required this.stockName,
    required this.action,
    required this.orderedQuantity,
    this.fulfilledQuantity = 0,
    this.limitPrice,
    required this.currency,
    required this.accountName,
    required this.createdAt,
    this.expiresAt,
    this.status = OrderStatus.open,
    this.isViewed = false,
  });

  bool get isMarketOrder => limitPrice == null;

  bool get isPartiallyFulfilled => fulfilledQuantity > 0 && fulfilledQuantity < orderedQuantity;

  bool get isFullyFulfilled => fulfilledQuantity == orderedQuantity;

  int get remainingQuantity => orderedQuantity - fulfilledQuantity;

  double get orderedValue => limitPrice != null ? orderedQuantity * limitPrice! : 0.0;

  double get fulfilledValue => limitPrice != null ? fulfilledQuantity * limitPrice! : 0.0;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Helper to get status display text
  String getStatusLabel() {
    if (isPartiallyFulfilled && status == OrderStatus.open) {
      return 'Nyitott megbízás';
    }
    if (isPartiallyFulfilled && status == OrderStatus.cancelled) {
      return 'Részlegjesen törölt';
    }

    switch (status) {
      case OrderStatus.open:
        return 'Nyitott megbízás';
      case OrderStatus.completed:
        return 'Teljesült';
      case OrderStatus.cancelled:
        return 'Törölt';
      case OrderStatus.expired:
        return 'Törölt';
    }
  }
}
