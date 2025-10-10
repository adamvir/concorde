import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../state/currency_state.dart';
import '../data/mock_portfolio_data.dart';

class SzamlaDetailPage extends StatefulWidget {
  final String accountName;

  const SzamlaDetailPage({
    super.key,
    required this.accountName,
  });

  @override
  State<SzamlaDetailPage> createState() => _SzamlaDetailPageState();
}

class _SzamlaDetailPageState extends State<SzamlaDetailPage> {
  final CurrencyState _currencyState = CurrencyState();
  final MockPortfolioData _portfolioData = MockPortfolioData();

  @override
  void initState() {
    super.initState();
    _currencyState.addListener(_onCurrencyChanged);
  }

  @override
  void dispose() {
    _currencyState.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  void _onCurrencyChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  AccountPortfolio _getAccount() {
    return _portfolioData.getAccountByName(widget.accountName) ??
        _portfolioData.getCombinedPortfolio();
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showCurrencySelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: CurrencyState.availableCurrencies.map((currency) {
            return ListTile(
              title: Text(currency),
              selected: currency == _currencyState.selectedCurrency,
              onTap: () {
                _currencyState.setSelectedCurrency(currency);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AccountPortfolio account = _getAccount();
    double totalValue = account.totalValueIn(_currencyState.selectedCurrency);
    double unrealizedProfit = account.unrealizedProfitIn(_currencyState.selectedCurrency);
    double totalCost = totalValue - unrealizedProfit;
    double profitPercent = totalCost > 0 ? (unrealizedProfit / totalCost) * 100 : 0;
    bool isPositive = unrealizedProfit >= 0;
    Color profitColor = isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(TablerIcons.arrow_left, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  // Account name
                  Expanded(
                    child: Text(
                      widget.accountName,
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left side - values
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Total value
                                Text(
                                  '${_formatCurrency(totalValue)} ${_currencyState.selectedCurrency}',
                                  style: TextStyle(
                                    color: const Color(0xFF1D293D),
                                    fontSize: 28,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Label
                                Text(
                                  'Nem realizált eredmény',
                                  style: TextStyle(
                                    color: const Color(0xFF45556C),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                // Profit amount
                                Text(
                                  '${isPositive ? '+' : ''}${_formatCurrency(unrealizedProfit.abs())} ${_currencyState.selectedCurrency}',
                                  style: TextStyle(
                                    color: profitColor,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Profit percent
                                Text(
                                  '${isPositive ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: profitColor,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right side - currency selector
                          GestureDetector(
                            onTap: _showCurrencySelectorBottomSheet,
                            child: Container(
                              width: 111,
                              height: 56,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFCAD5E2),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Currency text
                                  Center(
                                    child: Text(
                                      _currencyState.selectedCurrency,
                                      style: TextStyle(
                                        color: const Color(0xFF1D293D),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  // Label
                                  Positioned(
                                    left: 12,
                                    top: -8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC)),
                                      child: Text(
                                        'Összesítés',
                                        style: TextStyle(
                                          color: const Color(0xFF45556C),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Dropdown icon
                                  Positioned(
                                    right: 8,
                                    top: 16,
                                    child: Icon(
                                      TablerIcons.chevron_down,
                                      size: 20,
                                      color: const Color(0xFF45556C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border(
                          top: BorderSide(width: 1, color: const Color(0xFFE2E8F0)),
                          bottom: BorderSide(width: 1, color: const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Column(
                        children: [
                          // First row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Termék',
                                style: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.50,
                                ),
                              ),
                              Text(
                                'Teljes érték',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: const Color(0xFF45556C),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.50,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          // Second row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text(
                                  'Össz. darab @ átl. ár',
                                  style: TextStyle(
                                    color: const Color(0xFF45556C),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Eredm. %',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: const Color(0xFF45556C),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.50,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      'Eredmény',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: const Color(0xFF45556C),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stock list
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: account.stocks.map((stock) {
                          double stockValue = stock.quantity * stock.currentPrice;
                          double stockValueConverted = MarketData.convert(
                            stockValue,
                            stock.currency,
                            _currencyState.selectedCurrency,
                          );
                          double stockProfit = stockValue - stock.totalCost;
                          double stockProfitConverted = MarketData.convert(
                            stockProfit,
                            stock.currency,
                            _currencyState.selectedCurrency,
                          );
                          double stockProfitPercent = stock.totalCost > 0
                              ? (stockProfit / stock.totalCost) * 100
                              : 0;
                          bool stockIsPositive = stockProfit >= 0;
                          Color stockColor = stockIsPositive
                              ? const Color(0xFF007A55)
                              : const Color(0xFFEC003F);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First row: Name and Value
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stock.name,
                                      style: TextStyle(
                                        color: const Color(0xFF1D293D),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${_formatCurrency(stockValueConverted)} ${_currencyState.selectedCurrency}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: const Color(0xFF1D293D),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                // Second row: Quantity, Profit
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        '${stock.quantity}db @ ${_formatCurrency(stock.avgPrice)} ${stock.currency}',
                                        style: TextStyle(
                                          color: const Color(0xFF45556C),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            '${stockIsPositive ? '+' : ''}${stockProfitPercent.toStringAsFixed(2)}%',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: stockColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            '${stockIsPositive ? '+' : ''}${_formatCurrency(stockProfitConverted.abs())} ${_currencyState.selectedCurrency}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: stockColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
