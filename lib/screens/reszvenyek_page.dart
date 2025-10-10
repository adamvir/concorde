import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'reszveny_info_page.dart';
import 'main_navigation.dart';
import '../widgets/account_selector_bottom_sheet.dart';
import '../state/account_state.dart';
import '../state/currency_state.dart';
import '../data/mock_portfolio_data.dart';

class ReszvenyekPage extends StatelessWidget {
  const ReszvenyekPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ReszvenyekContent(),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(context, 0, TablerIcons.chart_pie, 'Portfólió'),
                _buildBottomNavItem(context, 1, TablerIcons.heart, 'Kedvencek'),
                _buildBottomNavItem(context, 2, TablerIcons.news, 'Hírek'),
                _buildBottomNavItem(context, 3, TablerIcons.trending_up, 'Tőzsde'),
                _buildBottomNavItem(context, 4, TablerIcons.dots, 'Több'),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 24,
            color: Colors.white,
            child: Center(
              child: Container(
                width: 108,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D293D),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, int index, IconData icon, String label) {
    bool isSelected = index == 0; // Portfolio is always selected since we're viewing stocks from there

    return Expanded(
      child: InkWell(
        onTap: () {
          // Navigate to MainNavigation with selected page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(initialPage: index),
            ),
            (route) => false,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFEF3C6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? const Color(0xFFFD9A00) : const Color(0xFF45556C),
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1D293D) : const Color(0xFF45556C),
                  fontSize: 12,
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
}

class ReszvenyekContent extends StatefulWidget {
  final VoidCallback? onBack;

  const ReszvenyekContent({Key? key, this.onBack}) : super(key: key);

  @override
  State<ReszvenyekContent> createState() => _ReszvenyekContentState();
}

class _ReszvenyekContentState extends State<ReszvenyekContent> {
  final CurrencyState _currencyState = CurrencyState();
  final AccountState _accountState = AccountState();
  final MockPortfolioData _portfolioData = MockPortfolioData();

  @override
  void initState() {
    super.initState();
    _accountState.addListener(_onAccountChanged);
    _currencyState.addListener(_onCurrencyChanged);
  }

  @override
  void dispose() {
    _accountState.removeListener(_onAccountChanged);
    _currencyState.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onCurrencyChanged() {
    print('Reszvenyek: Currency changed to ${_currencyState.selectedCurrency}');
    if (mounted) {
      setState(() {});
    }
  }

  String _formatCurrency(double value) {
    String valueStr = value.toStringAsFixed(0);
    valueStr = valueStr.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} '
    );
    return valueStr;
  }

  void _showAccountSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AccountSelectorBottomSheet(
        selectedAccount: _accountState.selectedAccount,
        onAccountSelected: (account) {
          _accountState.setSelectedAccount(account);
        },
      ),
    );
  }

  void _showCurrencySelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CurrencySelectorBottomSheet(
        selectedCurrency: _currencyState.selectedCurrency,
        onCurrencySelected: (currency) {
          _currencyState.setSelectedCurrency(currency);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: Icon(TablerIcons.arrow_left, size: 24),
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Részvények',
                        style: TextStyle(
                          color: const Color(0xFF1D293D),
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.27,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _accountState.selectedAccount,
                        style: TextStyle(
                          color: const Color(0xFF45556C),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Circle chevron down button
                IconButton(
                  icon: Icon(TablerIcons.circle_chevron_down, size: 24),
                  onPressed: _showAccountSelectorBottomSheet,
                ),
              ],
            ),
          ),

          // Summary section with currency selector
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final stocks = _portfolioData.getStocksForAccount(_accountState.selectedAccount);

                      // Calculate total value and unrealized profit for stocks only (in HUF first)
                      double totalValueInHUF = 0;
                      double totalUnrealizedProfitInHUF = 0;
                      double totalCostInHUF = 0;

                      for (var stock in stocks) {
                        totalValueInHUF += stock.totalValueInHUF(MarketData.exchangeRates);
                        totalUnrealizedProfitInHUF += stock.unrealizedProfitInHUF(MarketData.exchangeRates);
                        totalCostInHUF += stock.totalCost * (MarketData.exchangeRates[stock.currency] ?? 1);
                      }

                      // Convert to selected currency
                      final totalValue = MarketData.convert(totalValueInHUF, 'HUF', _currencyState.selectedCurrency);
                      final totalUnrealizedProfit = MarketData.convert(totalUnrealizedProfitInHUF, 'HUF', _currencyState.selectedCurrency);

                      final profitPercent = totalCostInHUF > 0 ? (totalUnrealizedProfitInHUF / totalCostInHUF * 100) : 0;
                      final isPositive = totalUnrealizedProfit >= 0;
                      final profitColor = isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatCurrency(totalValue)} ${_currencyState.selectedCurrency}',
                            style: TextStyle(
                              color: const Color(0xFF1D293D),
                              fontSize: 28,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.29,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Nem realizált eredmény',
                            style: TextStyle(
                              color: const Color(0xFF45556C),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.33,
                              letterSpacing: 0.10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${_formatCurrency(totalUnrealizedProfit.abs())} ${_currencyState.selectedCurrency}',
                            style: TextStyle(
                              color: profitColor,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                              letterSpacing: 0.10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${profitPercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: profitColor,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                              letterSpacing: 0.10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Currency selector
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: _showCurrencySelectorBottomSheet,
                      child: Container(
                        width: 111,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFFCAD5E2),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.only(top: 4, left: 16, bottom: 4, right: 4),
                        child: Row(
                          children: [
                            Expanded(
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
                            Icon(TablerIcons.chevron_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        color: const Color(0xFFF8FAFC),
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
                  ],
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
                top: BorderSide(
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                ),
                bottom: BorderSide(
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        height: 1.33,
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
                        height: 1.33,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ],
                ),
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
                          height: 1.33,
                          letterSpacing: 0.50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 66,
                            child: Text(
                              'Eredm. %',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                                letterSpacing: 0.50,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 112,
                            child: Text(
                              'Eredmény',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                                letterSpacing: 0.50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stock list
          Expanded(
            child: Builder(
              builder: (context) {
                final stocks = _portfolioData.getStocksForAccount(_accountState.selectedAccount);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    final profitPercent = stock.profitPercent;
                    final isPositive = stock.isPositive;

                    return _buildStockRow(
                      stock.name,
                      stock.ticker,
                      '${_formatCurrency(stock.totalValue)} ${stock.currency}',
                      '${stock.quantity}db @ ${_formatCurrency(stock.avgPrice)} ${stock.currency}',
                      '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                      _formatCurrency(stock.unrealizedProfit.abs()),
                      isPositive,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow(
    String name,
    String ticker,
    String totalValue,
    String quantity,
    String percentChange,
    String valueChange,
    bool isPositive,
  ) {
    Color changeColor = isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReszvenyInfoPage(
              stockName: name,
              ticker: ticker,
            ),
          ),
        );
      },
      child: Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
              ),
              Text(
                totalValue,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  quantity,
                  style: TextStyle(
                    color: const Color(0xFF45556C),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    letterSpacing: 0.10,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 66,
                      child: Text(
                        percentChange,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: changeColor,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 112,
                      child: Text(
                        valueChange,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: changeColor,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ],
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

// Currency Selector Bottom Sheet
class CurrencySelectorBottomSheet extends StatefulWidget {
  final String selectedCurrency;
  final Function(String) onCurrencySelected;

  const CurrencySelectorBottomSheet({
    Key? key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  }) : super(key: key);

  @override
  State<CurrencySelectorBottomSheet> createState() => _CurrencySelectorBottomSheetState();
}

class _CurrencySelectorBottomSheetState extends State<CurrencySelectorBottomSheet> {
  late String _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 12,
              left: 24,
              right: 12,
              bottom: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Összesítés devizaneme',
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.27,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: Icon(TablerIcons.x, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          // Currency options
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildCurrencyOption(context, 'HUF'),
                _buildCurrencyOption(context, 'EUR'),
                _buildCurrencyOption(context, 'USD'),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(BuildContext context, String currency) {
    final bool isSelected = currency == _currentSelection;

    return InkWell(
      onTap: () {
        setState(() {
          _currentSelection = currency;
        });
        widget.onCurrencySelected(currency);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF3C6) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          currency,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1D293D) : const Color(0xFF45556C),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            height: 1.43,
            letterSpacing: 0.10,
          ),
        ),
      ),
    );
  }
}
