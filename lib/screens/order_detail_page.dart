import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/transaction_service.dart';
import '../state/theme_state.dart';
import '../theme/app_colors.dart';
import 'stock_buy_page.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final TransactionService _transactionService = TransactionService();
  final ThemeState _themeState = ThemeState();
  bool _isGeneralExpanded = true;
  bool _isOrderedExpanded = true;
  bool _isFulfilledExpanded = true;
  bool _isPartialFulfillmentsExpanded = true;

  @override
  void initState() {
    super.initState();
    _themeState.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);
    final bool isBuy = widget.order.action == OrderAction.buy;
    final bool isOpen = widget.order.status == OrderStatus.open;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(TablerIcons.arrow_left, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.order.stockName} - ${isBuy ? 'Vétel' : 'Eladás'}',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${widget.order.getStatusLabel()} - ${widget.order.accountName}',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(TablerIcons.info_circle, color: colors.textPrimary),
            onPressed: () {
              // Show info dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildGeneralSection(),
                  _buildOrderedSection(),
                  _buildFulfilledSection(),
                  if (widget.order.isPartiallyFulfilled)
                    _buildPartialFulfillmentsSection(),
                ],
              ),
            ),
          ),
          if (isOpen) _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    final colors = AppColors(isDark: _themeState.isDark);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isGeneralExpanded = !_isGeneralExpanded),
          child: Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
              children: [
                Icon(
                  TablerIcons.info_circle,
                  color: colors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Általános',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isGeneralExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                    color: colors.textPrimary,
                  ),
                  onPressed: () => setState(() => _isGeneralExpanded = !_isGeneralExpanded),
                ),
              ],
            ),
          ),
        ),
        if (_isGeneralExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.border),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow('Értékpapír', widget.order.stockName, isUnderlined: true),
                const SizedBox(height: 4),
                _buildDetailRow('Tranzakció', widget.order.action == OrderAction.buy ? 'Vétel' : 'Eladás'),
                const SizedBox(height: 4),
                _buildDetailRow('Számla', widget.order.accountName),
                const SizedBox(height: 4),
                _buildDetailRow('Státusz', widget.order.getStatusLabel()),
                const SizedBox(height: 4),
                _buildDetailRow('Azonosító', widget.order.id),
                const SizedBox(height: 4),
                _buildDetailRow('Létrehozva', _formatDate(widget.order.createdAt)),
                const SizedBox(height: 4),
                _buildDetailRow('Érvényes', widget.order.expiresAt != null ? _formatDate(widget.order.expiresAt!) : '-'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOrderedSection() {
    final colors = AppColors(isDark: _themeState.isDark);
    final String priceText = widget.order.isMarketOrder
        ? 'Piaci'
        : '${_formatNumber(widget.order.limitPrice!)} ${widget.order.currency}';

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isOrderedExpanded = !_isOrderedExpanded),
          child: Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
              children: [
                Icon(
                  TablerIcons.file_text,
                  color: colors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Beadva',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isOrderedExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                    color: colors.textPrimary,
                  ),
                  onPressed: () => setState(() => _isOrderedExpanded = !_isOrderedExpanded),
                ),
              ],
            ),
          ),
        ),
        if (_isOrderedExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.border),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow('Ár', priceText),
                const SizedBox(height: 4),
                _buildDetailRow('Darab', '${widget.order.orderedQuantity} db'),
                const SizedBox(height: 4),
                _buildDetailRow('Érték', widget.order.isMarketOrder
                    ? 'Piaci ár'
                    : '${_formatNumber(widget.order.orderedValue)} ${widget.order.currency}'),
                const SizedBox(height: 4),
                _buildDetailRow('Aktiválási ár', '-'),
                const SizedBox(height: 4),
                _buildDetailRow('Iceberg ajánlat', '-'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFulfilledSection() {
    final colors = AppColors(isDark: _themeState.isDark);
    final bool hasFulfillment = widget.order.fulfilledQuantity > 0;
    final double avgPrice = hasFulfillment && widget.order.limitPrice != null
        ? widget.order.limitPrice!
        : 0.0;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isFulfilledExpanded = !_isFulfilledExpanded),
          child: Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
              children: [
                Icon(
                  TablerIcons.circle_check,
                  color: colors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Teljesült',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFulfilledExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                    color: colors.textPrimary,
                  ),
                  onPressed: () => setState(() => _isFulfilledExpanded = !_isFulfilledExpanded),
                ),
              ],
            ),
          ),
        ),
        if (_isFulfilledExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.border),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow('Átlag ár', hasFulfillment
                    ? '${_formatNumber(avgPrice)} ${widget.order.currency}'
                    : '-'),
                const SizedBox(height: 4),
                _buildDetailRow('Darab', '${widget.order.fulfilledQuantity} db'),
                const SizedBox(height: 4),
                _buildDetailRow('Érték', hasFulfillment
                    ? '${_formatNumber(widget.order.fulfilledValue)} ${widget.order.currency}'
                    : '-'),
                const SizedBox(height: 4),
                _buildDetailRow('Levont adó', '-'),
                const SizedBox(height: 4),
                _buildDetailRow('Bróker díj', hasFulfillment ? '44,51 ${widget.order.currency}' : '-'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPartialFulfillmentsSection() {
    final colors = AppColors(isDark: _themeState.isDark);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isPartialFulfillmentsExpanded = !_isPartialFulfillmentsExpanded),
          child: Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
              children: [
                Icon(
                  TablerIcons.repeat,
                  color: colors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Részteljesülések',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPartialFulfillmentsExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                    color: colors.textPrimary,
                  ),
                  onPressed: () => setState(() => _isPartialFulfillmentsExpanded = !_isPartialFulfillmentsExpanded),
                ),
              ],
            ),
          ),
        ),
        if (_isPartialFulfillmentsExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Mock partial fulfillments
                _buildPartialFulfillmentItem(
                  DateTime.now(),
                  47,
                  151.98,
                  7143.06,
                ),
                _buildPartialFulfillmentItem(
                  DateTime.now().subtract(const Duration(minutes: 9)),
                  36,
                  152.10,
                  6996.60,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPartialFulfillmentItem(DateTime date, int quantity, double price, double value) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateTime(date),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_formatNumber(value)} ${widget.order.currency}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$quantity db @ ${_formatNumber(price)} ${widget.order.currency}',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isUnderlined = false}) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            decoration: isUnderlined ? TextDecoration.underline : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final colors = AppColors(isDark: _themeState.isDark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleModify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.textPrimary,
                      foregroundColor: colors.background,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(TablerIcons.edit, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Módosít',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.textPrimary,
                      foregroundColor: colors.background,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(TablerIcons.trash, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Visszavon',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Home indicator
          Container(
            width: double.infinity,
            height: 24,
            color: colors.background,
            child: Center(
              child: Container(
                width: 108,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleModify() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockBuyPage(
          stockName: widget.order.stockName,
          ticker: widget.order.ticker,
          currentPrice: widget.order.limitPrice ?? 0.0,
          currency: widget.order.currency,
          initialTradeType: widget.order.action == OrderAction.buy ? 'Vétel' : 'Eladás',
          existingOrder: widget.order,
        ),
      ),
    ).then((_) {
      // Refresh the page after returning from edit
      if (mounted) {
        Navigator.pop(context); // Close detail page and return to list
      }
    });
  }

  void _handleCancel() {
    final colors = AppColors(isDark: _themeState.isDark);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Megbízás visszavonása'),
        content: Text('Biztosan visszavonod a megbízást?\n\n${widget.order.stockName}\n${widget.order.orderedQuantity} db @ ${widget.order.isMarketOrder ? 'Piaci' : '${_formatNumber(widget.order.limitPrice!)} ${widget.order.currency}'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mégsem'),
          ),
          TextButton(
            onPressed: () {
              _transactionService.cancelOrder(widget.order.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to orders list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Megbízás visszavonva'),
                  backgroundColor: colors.error,
                ),
              );
            },
            child: Text(
              'Visszavon',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    final formatter = NumberFormat('#,##0.00', 'hu_HU');
    return formatter.format(value).replaceAll(',', ' ').replaceAll('.', ',');
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd.').format(date);
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Ma ${DateFormat('HH:mm:ss').format(date)}';
    } else {
      return DateFormat('yyyy.MM.dd. HH:mm:ss').format(date);
    }
  }
}
