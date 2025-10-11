import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../services/transaction_service.dart';
import '../models/order_model.dart';
import '../state/account_state.dart';
import '../widgets/account_selector_bottom_sheet.dart' as account_chooser;
import 'package:intl/intl.dart';
import 'order_detail_page.dart';

class MegbizasokPage extends StatefulWidget {
  const MegbizasokPage({Key? key}) : super(key: key);

  @override
  State<MegbizasokPage> createState() => _MegbizasokPageState();
}

class _MegbizasokPageState extends State<MegbizasokPage> with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  final AccountState _accountState = AccountState();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _accountState.addListener(_onAccountChanged);

    // Mark all orders as viewed when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        dynamic service = _transactionService;
        service.markAllOrdersAsViewed();
      } catch (e) {
        // Silently handle
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accountState.removeListener(_onAccountChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    setState(() {});
  }

  void _showAccountSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => account_chooser.AccountSelectorBottomSheet(
        selectedAccount: _accountState.selectedAccount,
        onAccountSelected: (account) {
          _accountState.setSelectedAccount(account);
        },
      ),
    );
  }

  List<Order> _getFilteredOrders(OrderStatus status) {
    try {
      dynamic service = _transactionService;
      List<Order> allOrders;

      switch (status) {
        case OrderStatus.open:
          allOrders = service.openOrders as List<Order>;
          break;
        case OrderStatus.completed:
          allOrders = service.completedOrders as List<Order>;
          break;
        case OrderStatus.cancelled:
          allOrders = service.cancelledOrders as List<Order>;
          break;
        case OrderStatus.expired:
          allOrders = service.expiredOrders as List<Order>;
          break;
      }

      if (_accountState.selectedAccount == 'Minden számla') {
        return allOrders;
      }
      return allOrders.where((o) => o.accountName == _accountState.selectedAccount).toList();
    } catch (e) {
      return [];
    }
  }

  String _formatOrderTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return 'Ma ${DateFormat('HH:mm:ss').format(date)}';
    } else {
      return '${DateFormat('yyyy.MM.dd').format(date)}.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: GestureDetector(
          onTap: _showAccountSelector,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Megbízások',
                style: TextStyle(
                  color: Color(0xFF1D293D),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.27,
                ),
              ),
              Text(
                _accountState.selectedAccount,
                style: const TextStyle(
                  color: Color(0xFF45556C),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.chevron_down, color: Color(0xFF1D293D)),
            onPressed: _showAccountSelector,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1D293D),
          indicatorWeight: 3,
          labelColor: const Color(0xFF1D293D),
          unselectedLabelColor: const Color(0xFF45556C),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.10,
          ),
          tabs: const [
            Tab(text: 'Nyitott'),
            Tab(text: 'Teljesült'),
            Tab(text: 'Visszavont'),
            Tab(text: 'Lejárt'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(OrderStatus.open),
          _buildOrderList(OrderStatus.completed),
          _buildOrderList(OrderStatus.cancelled),
          _buildOrderList(OrderStatus.expired),
        ],
      ),
    );
  }

  Future<void> _refreshOrders() async {
    // Simulate refresh - in production this would fetch from API
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Trigger rebuild to refresh the list
    });
  }

  Widget _buildOrderList(OrderStatus status) {
    final orders = _getFilteredOrders(status);

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      color: const Color(0xFF009966),
      child: Column(
        children: [
          // Table header
          Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Termék',
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Vétel / Eladás',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Megbízás darab @ ár',
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Megbízás érték',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Teljesült darab @ ár',
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Teljesült érték',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Számla',
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Beadás ideje',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Orders list
        Expanded(
          child: orders.isEmpty
              ? const Center(
                  child: Text(
                    'Nincs megbízás',
                    style: TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == orders.length) {
                      // Load more button
                      return Container(
                        width: double.infinity,
                        height: 48,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: TextButton(
                          onPressed: () {
                            // TODO: Load more
                          },
                          child: const Text(
                            'További 30 nap betöltése',
                            style: TextStyle(
                              color: Color(0xFF45556C),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.10,
                            ),
                          ),
                        ),
                      );
                    }

                    final order = orders[index];
                    return _buildOrderItem(order);
                  },
                ),
        ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    final isBuy = order.action == OrderAction.buy;
    final formattedOrderValue = NumberFormat('#,##0.00', 'en_US')
        .format(order.orderedValue)
        .replaceAll(',', ' ');
    final formattedFulfilledValue = NumberFormat('#,##0.00', 'en_US')
        .format(order.fulfilledValue)
        .replaceAll(',', ' ');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(order: order),
          ),
        );
      },
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          // Row 1: Stock name and Buy/Sell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.stockName,
                style: const TextStyle(
                  color: Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
              ),
              Text(
                isBuy ? 'Vétel' : 'Eladás',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isBuy ? const Color(0xFF009966) : const Color(0xFFEC003F),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),

          // Row 2: Ordered quantity @ price and Ordered value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(TablerIcons.file_text, size: 20, color: Color(0xFF45556C)),
                  const SizedBox(width: 2),
                  Text(
                    '${order.orderedQuantity} db @ ${order.isMarketOrder ? "Piaci" : order.limitPrice!.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: 0.10,
                    ),
                  ),
                ],
              ),
              Text(
                order.isMarketOrder ? 'Piaci ár' : '$formattedOrderValue ${order.currency}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),

          // Row 3: Fulfilled quantity @ price and Fulfilled value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(TablerIcons.circle_check, size: 20, color: Color(0xFF45556C)),
                  const SizedBox(width: 2),
                  Text(
                    '${order.fulfilledQuantity} db @ ${order.limitPrice != null ? order.limitPrice!.toStringAsFixed(2).replaceAll('.', ',') : "0,00"}',
                    style: const TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: 0.10,
                    ),
                  ),
                ],
              ),
              Text(
                '$formattedFulfilledValue ${order.currency}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),

          // Row 4: Account badge + Status badge (if needed) and Created time
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status badge (left side black button)
                  if (order.status == OrderStatus.open && !order.isPartiallyFulfilled)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D293D),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Nyitott megbízás',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  if (order.isPartiallyFulfilled && order.status == OrderStatus.open)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D293D),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Nyitott megbízás',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  if (order.isPartiallyFulfilled && order.status == OrderStatus.cancelled)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D293D),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Részlegjesen törölt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  if (order.status == OrderStatus.cancelled && !order.isPartiallyFulfilled)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D293D),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Törölt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  if (order.status == OrderStatus.completed)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D293D),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Teljesült',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  if (order.status == OrderStatus.expired)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D293D),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Törölt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Limit price badge (if limit order)
                  if (!order.isMarketOrder)
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF8FF),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(TablerIcons.arrow_badge_up, size: 18, color: Color(0xFF45556C)),
                          const SizedBox(width: 4),
                          Text(
                            '${order.limitPrice!.toStringAsFixed(2).replaceAll('.', ',')} ${order.currency}',
                            style: const TextStyle(
                              color: Color(0xFF45556C),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.10,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Account badge
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8FF),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.accountName,
                      style: const TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ),
                ],
              ),

              // Created time (right side)
              SizedBox(
                height: 32,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatOrderTime(order.createdAt),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF45556C),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: 0.10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
