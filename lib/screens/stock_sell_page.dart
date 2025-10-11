import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../services/transaction_service.dart';
import '../data/mock_portfolio_data.dart';

class StockSellPage extends StatefulWidget {
  final String stockName;
  final String ticker;
  final double currentPrice;
  final String currency;

  const StockSellPage({
    Key? key,
    required this.stockName,
    required this.ticker,
    required this.currentPrice,
    required this.currency,
  }) : super(key: key);

  @override
  State<StockSellPage> createState() => _StockSellPageState();
}

class _StockSellPageState extends State<StockSellPage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stopPriceController = TextEditingController();
  final TextEditingController _icebergQuantityController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  final MockPortfolioData _portfolioData = MockPortfolioData();

  OrderType _orderType = OrderType.limit;
  String _selectedAccount = 'TBSZ-2023';
  String _selectedOrderDirection = 'Eladás';
  String _selectedValidity = 'Visszavonásig';
  String _selectedFIFO = 'FIFO - First In, First Out';
  bool _advancedSettingsExpanded = false;
  bool _premarketTrading = false;
  bool _stopOrder = true; // Checked by default on screenshot
  bool _icebergOrder = true; // Checked by default on screenshot

  @override
  void initState() {
    super.initState();
    _priceController.text = '150,00';
    _quantityController.text = '30';
    _stopPriceController.text = '106,00';
    _icebergQuantityController.text = '10';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _stopPriceController.dispose();
    _icebergQuantityController.dispose();
    super.dispose();
  }

  double _calculateTotalValue() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
    return quantity * price;
  }

  double _getPriceChangePercent() {
    double enteredPrice = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? widget.currentPrice;
    return ((enteredPrice - widget.currentPrice) / widget.currentPrice) * 100;
  }

  int _getAvailableQuantity() {
    return _transactionService.getAvailableQuantity(widget.ticker, _selectedAccount);
  }

  double _getAvailableValue() {
    int quantity = _getAvailableQuantity();
    return quantity * widget.currentPrice;
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

    bool success = _transactionService.executeSell(
      ticker: widget.ticker,
      quantity: quantity,
      price: price,
      accountName: _selectedAccount,
      orderType: _orderType,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_orderType == OrderType.market
              ? 'Eladás sikeresen teljesült!'
              : 'Limit megbízás rögzítve!'),
          backgroundColor: Color(0xFF009966),
        ),
      );
    } else {
      _showError('Nincs elég részvény az eladáshoz!');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(TablerIcons.arrow_left, size: 24, color: Color(0xFF1D293D)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Eladás - ${widget.stockName}',
              style: TextStyle(
                color: Color(0xFF1D293D),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
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
                      color: Color(0xFF1D293D),
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
                      color: Color(0xFFFF637E),
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
                      color: Color(0xFFF59E0B),
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
                  color: Color(0xFF45556C),
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
                  color: Color(0xFF007A55),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'E 1.045 db @ 147,08',
                style: TextStyle(
                  color: Color(0xFF45556C),
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
                  onChanged: (value) {
                    setState(() {
                      _orderType = value == 'Limit' ? OrderType.limit : OrderType.market;
                      // Update price when switching to market
                      if (_orderType == OrderType.market) {
                        _priceController.text = widget.currentPrice.toStringAsFixed(2).replaceAll('.', ',');
                      }
                    });
                  },
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
                  helperText: _orderType == OrderType.limit ? '+${_getPriceChangePercent().toStringAsFixed(1)}%' : '15 perccel késleltet...',
                  helperColor: _getPriceChangePercent() > 0 ? null : Color(0xFF45556C),
                  enabled: _orderType == OrderType.limit,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildLabeledTextField(
                  label: 'Mennyiség',
                  controller: _quantityController,
                  suffix: 'db',
                  helperText: '${_calculateTotalValue().toStringAsFixed(0)} ${widget.currency}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    int availableQuantity = _getAvailableQuantity();
    double availableValue = _getAvailableValue();
    double totalValue = _calculateTotalValue();
    int quantity = int.tryParse(_quantityController.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Szabad készlet', '$availableQuantity db', hasIcon: false),
          SizedBox(height: 12),
          _buildSummaryRow('Szabad készlet érték', '${availableValue.toStringAsFixed(0)} ${widget.currency}', hasIcon: true),
          SizedBox(height: 12),
          _buildSummaryRow('Jutalék', '3,5 ${widget.currency}', hasIcon: true),
          SizedBox(height: 12),
          _buildSummaryRow('Eladási érték', '${totalValue.toStringAsFixed(0)} ${widget.currency}'),
          SizedBox(height: 12),
          _buildSummaryRow('Eladási mennyiség', '$quantity db'),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsSection() {
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
                    color: Color(0xFF1D293D),
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _advancedSettingsExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                  color: Color(0xFF1D293D),
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
                _buildLabeledDropdown(
                  label: 'Kész letrehozási alv',
                  value: _selectedFIFO,
                  items: ['FIFO - First In, First Out', 'LIFO - Last In, First Out'],
                  onChanged: (value) => setState(() => _selectedFIFO = value!),
                ),
                SizedBox(height: 24),
                _buildCheckbox('Premarket kereskedés', _premarketTrading, (value) {
                  setState(() => _premarketTrading = value ?? false);
                }),
                SizedBox(height: 16),
                _buildCheckbox('Stop ajánlat', _stopOrder, (value) {
                  setState(() => _stopOrder = value ?? false);
                }),
                // Stop order input field
                if (_stopOrder)
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
                            Icon(TablerIcons.alert_circle, size: 16, color: Color(0xFFEC003F)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '-33,02% - Túl alacsony ár',
                                style: TextStyle(
                                  color: Color(0xFFEC003F),
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
                if (_stopOrder) SizedBox(height: 16),
                _buildCheckbox('Iceberg ajánlat', _icebergOrder, (value) {
                  setState(() => _icebergOrder = value ?? false);
                }),
                // Iceberg order input field
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _executeSell,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFEC003F), // Red for sell
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
                'Eladás áttekintése',
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
    required Function(String?) onChanged,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFCAD5E2)),
            borderRadius: BorderRadius.circular(4),
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
                          icon: Icon(TablerIcons.refresh, size: 16),
                          style: TextStyle(
                            color: Color(0xFF1D293D),
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
                  color: Colors.white,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFF45556C),
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
                color: Color(0xFF45556C),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFCAD5E2)),
            borderRadius: BorderRadius.circular(4),
            color: enabled ? Colors.white : Color(0xFFF8FAFC),
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
                    color: enabled ? Color(0xFF1D293D) : Color(0xFF94A3B8),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    suffixText: suffix.isNotEmpty ? suffix : null,
                    suffixStyle: TextStyle(
                      color: enabled ? Color(0xFF1D293D) : Color(0xFF94A3B8),
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
                  color: Colors.white,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFF45556C),
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
                color: helperColor ?? Color(0xFF45556C),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF45556C),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            if (hasIcon) SizedBox(width: 8),
            if (hasIcon) Icon(TablerIcons.info_circle, size: 16, color: Color(0xFF45556C)),
          ],
        ),
        Row(
          children: [
            if (hasIcon) Icon(TablerIcons.arrow_down, size: 16, color: Color(0xFF1D293D)),
            if (hasIcon) SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: Color(0xFF1D293D),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          side: BorderSide(width: 2, color: Color(0xFF45556C)),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFF1D293D),
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
