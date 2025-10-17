import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../services/transaction_service.dart';
import '../data/market_stocks_data.dart';
import '../data/mock_portfolio_data.dart';
import 'order_confirmation_page.dart';
import '../widgets/order_success_snackbar.dart';
import '../models/order_model.dart';
import '../state/theme_state.dart';
import '../theme/app_colors.dart';

class StockBuyPage extends StatefulWidget {
  final String stockName;
  final String ticker;
  final double currentPrice;
  final String currency;
  final String initialTradeType; // 'Vétel' or 'Eladás'
  final Order? existingOrder; // For edit mode

  const StockBuyPage({
    Key? key,
    required this.stockName,
    required this.ticker,
    required this.currentPrice,
    required this.currency,
    this.initialTradeType = 'Vétel',
    this.existingOrder,
  }) : super(key: key);

  @override
  State<StockBuyPage> createState() => _StockBuyPageState();
}

class _StockBuyPageState extends State<StockBuyPage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stopPriceController = TextEditingController();
  final TextEditingController _icebergQuantityController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  final MockPortfolioData _portfolioData = MockPortfolioData();
  final ThemeState _themeState = ThemeState();

  OrderType _orderType = OrderType.limit;
  String _selectedAccount = 'TBSZ-2023';
  String _selectedOrderDirection = 'Vétel';
  String _selectedValidity = 'Visszavonásig';
  String _selectedFIFO = 'FIFO - First In, First Out';
  bool _advancedSettingsExpanded = false;
  bool _premarketTrading = false;
  bool _stopOrder = false;
  bool _icebergOrder = false;

  @override
  void initState() {
    super.initState();
    _selectedOrderDirection = widget.initialTradeType; // Set from navigation
    _themeState.addListener(_onThemeChanged);

    // Check if editing an existing order
    if (widget.existingOrder != null) {
      final order = widget.existingOrder!;
      // Pre-fill with existing order data
      _quantityController.text = order.orderedQuantity.toString();
      _selectedAccount = order.accountName;

      // Set order type based on existing order (CANNOT BE CHANGED IN EDIT MODE)
      if (order.isMarketOrder) {
        _orderType = OrderType.market;
        _priceController.text = widget.currentPrice.toStringAsFixed(2).replaceAll('.', ',');
      } else {
        _orderType = OrderType.limit;
        _priceController.text = order.limitPrice!.toStringAsFixed(2).replaceAll('.', ',');
      }
    } else {
      // New order defaults
      _priceController.text = widget.currentPrice.toStringAsFixed(2).replaceAll('.', ',');
      _quantityController.text = '30';
      _orderType = OrderType.market;
    }

    _stopPriceController.text = '106,00';
    _icebergQuantityController.text = '10';
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    _quantityController.dispose();
    _priceController.dispose();
    _stopPriceController.dispose();
    _icebergQuantityController.dispose();
    super.dispose();
  }

  double _calculateTotalCost() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
    return quantity * price;
  }

  double _getPriceChangePercent() {
    double enteredPrice = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? widget.currentPrice;
    return ((enteredPrice - widget.currentPrice) / widget.currentPrice) * 100;
  }

  double _getAvailableCash() {
    AccountPortfolio? account = _portfolioData.getAccountByName(_selectedAccount);
    if (account == null) return 0;

    int cashIndex = account.cash.indexWhere((c) => c.currency == widget.currency);
    return cashIndex >= 0 ? account.cash[cashIndex].amount : 0;
  }

  void _executeBuy() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;

    if (quantity <= 0) {
      _showError('Adj meg érvényes mennyiséget');
      return;
    }

    if (price <= 0) {
      _showError('Adj meg érvényes árat');
      return;
    }

    bool isEditMode = widget.existingOrder != null;

    // Navigate to confirmation page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          stockName: widget.stockName,
          ticker: widget.ticker,
          orderDirection: isEditMode ? 'Módosítás' : 'Vétel',
          orderType: _orderType == OrderType.market ? 'Piaci' : 'Limit',
          quantity: quantity,
          price: price,
          currency: widget.currency,
          accountName: _selectedAccount,
          expectedValue: _calculateTotalCost(),
          isEditMode: isEditMode,
          onConfirm: () {
            if (isEditMode) {
              // Update existing order
              _transactionService.updateOrder(
                orderId: widget.existingOrder!.id,
                quantity: quantity,
                limitPrice: _orderType == OrderType.limit ? price : null,
              );
              OrderSuccessSnackbar.show(
                context: context,
                orderDirection: 'Módosítás',
                stockName: widget.stockName,
                quantity: quantity,
                price: price,
                currency: widget.currency,
              );
            } else {
              // Execute the actual transaction
              bool success = _transactionService.executeBuy(
                ticker: widget.ticker,
                stockName: widget.stockName,
                quantity: quantity,
                price: price,
                accountName: _selectedAccount,
                orderType: _orderType,
              );

              if (success) {
                OrderSuccessSnackbar.show(
                  context: context,
                  orderDirection: 'Vétel',
                  stockName: widget.stockName,
                  quantity: quantity,
                  price: price,
                  currency: widget.currency,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nincs elég készpénz! (${_calculateTotalCost().toStringAsFixed(0)} ${widget.currency} szükséges)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _executeSell() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;

    if (quantity <= 0) {
      _showError('Adj meg érvényes mennyiséget');
      return;
    }

    if (price <= 0) {
      _showError('Adj meg érvényes árat');
      return;
    }

    bool isEditMode = widget.existingOrder != null;

    // Navigate to confirmation page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          stockName: widget.stockName,
          ticker: widget.ticker,
          orderDirection: isEditMode ? 'Módosítás' : 'Eladás',
          orderType: _orderType == OrderType.market ? 'Piaci' : 'Limit',
          quantity: quantity,
          price: price,
          currency: widget.currency,
          accountName: _selectedAccount,
          expectedValue: _calculateTotalCost(),
          isEditMode: isEditMode,
          onConfirm: () {
            if (isEditMode) {
              // Update existing order
              _transactionService.updateOrder(
                orderId: widget.existingOrder!.id,
                quantity: quantity,
                limitPrice: _orderType == OrderType.limit ? price : null,
              );
              OrderSuccessSnackbar.show(
                context: context,
                orderDirection: 'Módosítás',
                stockName: widget.stockName,
                quantity: quantity,
                price: price,
                currency: widget.currency,
              );
            } else {
              // Execute the actual transaction
              bool success = _transactionService.executeSell(
                ticker: widget.ticker,
                quantity: quantity,
                price: price,
                accountName: _selectedAccount,
                orderType: _orderType,
              );

              if (success) {
                OrderSuccessSnackbar.show(
                  context: context,
                  orderDirection: 'Eladás',
                  stockName: widget.stockName,
                  quantity: quantity,
                  price: price,
                  currency: widget.currency,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nincs elég részvény az eladáshoz!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPriceSection(),
                    _buildFormSection(),
                    _buildSummarySection(),
                    _buildAdvancedSettingsSection(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildHeader() {
    final colors = AppColors(isDark: _themeState.isDark);

    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(TablerIcons.x, size: 24, color: colors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              '$_selectedOrderDirection - ${widget.stockName}',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.27,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final colors = AppColors(isDark: _themeState.isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${widget.currentPrice.toStringAsFixed(2)} ${widget.currency}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  SizedBox(width: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.delayBadge,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '15p',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.preMarketBadge,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Pre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'V 450 db @ 146,90',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '+4,43% (6,24)',
                style: TextStyle(
                  color: colors.success,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'E 1.045 db @ 147,08',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLabeledDropdown(
            label: 'Számla',
            value: _selectedAccount,
            items: ['TBSZ-2023', 'TBSZ-2024', 'Értékpapírszámla'],
            onChanged: (value) => setState(() => _selectedAccount = value!),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildLabeledDropdown(
                  label: 'Megbízás',
                  value: _selectedOrderDirection,
                  items: ['Vétel', 'Eladás'],
                  onChanged: (value) => setState(() => _selectedOrderDirection = value!),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildLabeledDropdown(
                  label: 'Ár típus',
                  value: _orderType == OrderType.limit ? 'Limit' : 'Piaci',
                  items: ['Limit', 'Piaci'],
                  onChanged: widget.existingOrder != null ? null : (value) {
                    setState(() {
                      _orderType = value == 'Limit' ? OrderType.limit : OrderType.market;
                      // Update price when switching to market
                      if (_orderType == OrderType.market) {
                        _priceController.text = widget.currentPrice.toStringAsFixed(2).replaceAll('.', ',');
                      }
                    });
                  },
                  isDisabled: widget.existingOrder != null, // Disable in edit mode
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLabeledTextField(
                  label: _orderType == OrderType.market ? 'Piaci ár' : 'Limit ár',
                  controller: _priceController,
                  suffix: widget.currency,
                  helperText: _orderType == OrderType.limit ? '${_getPriceChangePercent().toStringAsFixed(1)}%' : '15 perccel késleltet...',
                  helperColor: _getPriceChangePercent() < 0 ? Color(0xFF45556C) : null,
                  enabled: _orderType == OrderType.limit,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildLabeledTextField(
                  label: 'Mennyiség',
                  controller: _quantityController,
                  suffix: 'db',
                  helperText: '${_calculateTotalCost().toStringAsFixed(0)} ${widget.currency}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final colors = AppColors(isDark: _themeState.isDark);
    double availableCash = _getAvailableCash();
    double totalCost = _calculateTotalCost();
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    int availableQuantity = _transactionService.getAvailableQuantity(widget.ticker, _selectedAccount);
    double availableValue = availableQuantity * widget.currentPrice;

    bool isSell = _selectedOrderDirection == 'Eladás';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.border),
        ),
      ),
      child: Column(
        children: [
          if (!isSell) ...[
            // Buy mode
            _buildSummaryRow('Szabad ${widget.currency} váltással', '15.092 ${widget.currency}', hasIcon: true),
            SizedBox(height: 12),
            _buildSummaryRow('Szabad ${widget.currency}', '${availableCash.toStringAsFixed(0)} ${widget.currency}', hasIcon: true),
            SizedBox(height: 12),
            _buildSummaryRow('Jutalék', '3,5 ${widget.currency}', hasIcon: true),
            SizedBox(height: 12),
            _buildSummaryRow('Vételi érték', '${totalCost.toStringAsFixed(0)} ${widget.currency}'),
            SizedBox(height: 12),
            _buildSummaryRow('Vételi mennyiség', '$quantity db'),
          ] else ...[
            // Sell mode
            _buildSummaryRow('Szabad készlet', '$availableQuantity db', hasIcon: false),
            SizedBox(height: 12),
            _buildSummaryRow('Szabad készlet érték', '${availableValue.toStringAsFixed(0)} ${widget.currency}', hasIcon: true),
            SizedBox(height: 12),
            _buildSummaryRow('Jutalék', '3,5 ${widget.currency}', hasIcon: true),
            SizedBox(height: 12),
            _buildSummaryRow('Eladási érték', '${totalCost.toStringAsFixed(0)} ${widget.currency}'),
            SizedBox(height: 12),
            _buildSummaryRow('Eladási mennyiség', '$quantity db'),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsSection() {
    final colors = AppColors(isDark: _themeState.isDark);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _advancedSettingsExpanded = !_advancedSettingsExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Haladó beállítások',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _advancedSettingsExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                  color: colors.textPrimary,
                ),
              ],
            ),
          ),
        ),
        if (_advancedSettingsExpanded)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLabeledDropdown(
                  label: 'Érvényesség',
                  value: _selectedValidity,
                  items: ['Visszavonásig', 'Nap végéig', 'Egy hétig'],
                  onChanged: (value) => setState(() => _selectedValidity = value!),
                  helperText: 'Max. 2026. jún. 30.',
                ),
                SizedBox(height: 24),
                // FIFO selector only for sell
                if (_selectedOrderDirection == 'Eladás') ...[
                  _buildLabeledDropdown(
                    label: 'Készletkezelési alv',
                    value: _selectedFIFO,
                    items: ['FIFO - First In, First Out', 'LIFO - Last In, First Out'],
                    onChanged: (value) => setState(() => _selectedFIFO = value!),
                  ),
                  SizedBox(height: 24),
                ],
                _buildCheckbox('Premarket kereskedés', _premarketTrading, (value) {
                  setState(() => _premarketTrading = value ?? false);
                }),
                SizedBox(height: 16),
                _buildCheckbox('Stop ajánlat', _stopOrder, (value) {
                  setState(() => _stopOrder = value ?? false);
                }),
                // Stop price input when checked and selling
                if (_stopOrder && _selectedOrderDirection == 'Eladás')
                  Padding(
                    padding: const EdgeInsets.only(left: 48, top: 8),
                    child: Column(
                      children: [
                        _buildLabeledTextField(
                          label: 'Aktiválási ár (${widget.currency})',
                          controller: _stopPriceController,
                          suffix: '',
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(TablerIcons.alert_circle, size: 16, color: colors.error),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '-33,02% - Túl alacsony ár',
                                style: TextStyle(
                                  color: colors.error,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (_stopOrder && _selectedOrderDirection == 'Eladás') SizedBox(height: 16),
                SizedBox(height: 16),
                _buildCheckbox('Iceberg ajánlat', _icebergOrder, (value) {
                  setState(() => _icebergOrder = value ?? false);
                }),
                // Iceberg quantity input when checked
                if (_icebergOrder)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, top: 8),
                    child: _buildLabeledTextField(
                      label: 'Látható mennyiség (db)',
                      controller: _icebergQuantityController,
                      suffix: '',
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final colors = AppColors(isDark: _themeState.isDark);
    bool isSell = _selectedOrderDirection == 'Eladás';
    bool isEditMode = widget.existingOrder != null;

    // Dynamic colors: Módosítás = dark grey, Vétel = green, Eladás = red
    Color buttonColor;
    if (isEditMode) {
      buttonColor = colors.textPrimary; // Use theme-aware text primary for edit
    } else if (isSell) {
      buttonColor = colors.error; // Red for sell
    } else {
      buttonColor = colors.success; // Green for buy
    }

    String buttonText = isEditMode
        ? 'Módosítás áttekintése'
        : (isSell ? 'Eladás áttekintése' : 'Vétel áttekintése');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isSell ? _executeSell : _executeBuy,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(TablerIcons.arrow_right, size: 20),
              SizedBox(width: 8),
              Text(
                buttonText,
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
    );
  }

  Widget _buildLabeledDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
    String? helperText,
    bool isDisabled = false,
  }) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: isDisabled ? colors.border : colors.inputBorder),
            borderRadius: BorderRadius.circular(4),
            color: isDisabled ? colors.surfaceElevated : colors.inputBackground,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: value,
                          isExpanded: true,
                          icon: Icon(TablerIcons.refresh, size: 16, color: isDisabled ? colors.border : colors.textSecondary),
                          dropdownColor: colors.surface,
                          style: TextStyle(
                            color: isDisabled ? colors.textTertiary : colors.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                          items: items.map((item) {
                            return DropdownMenuItem(value: item, child: Text(item));
                          }).toList(),
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 12,
                top: -8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  color: isDisabled ? colors.surfaceElevated : colors.inputBackground,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              helperText,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    String? helperText,
    Color? helperColor,
    bool enabled = true,
  }) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: colors.inputBorder),
            borderRadius: BorderRadius.circular(4),
            color: enabled ? colors.inputBackground : colors.surfaceElevated,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: enabled ? colors.textPrimary : colors.textTertiary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    suffixText: suffix,
                    suffixStyle: TextStyle(
                      color: enabled ? colors.textPrimary : colors.textTertiary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              Positioned(
                left: 12,
                top: -8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  color: enabled ? colors.inputBackground : colors.surfaceElevated,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              helperText,
              style: TextStyle(
                color: helperColor ?? colors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool hasIcon = false}) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
            if (hasIcon) SizedBox(width: 8),
            if (hasIcon) Icon(TablerIcons.info_circle, size: 16, color: colors.textSecondary),
          ],
        ),
        Row(
          children: [
            if (hasIcon) Icon(TablerIcons.arrow_up, size: 16, color: colors.textPrimary),
            if (hasIcon) SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                decoration: hasIcon ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          side: BorderSide(width: 2, color: colors.textSecondary),
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.textPrimary;
            }
            return colors.inputBackground;
          }),
          checkColor: Colors.white,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
