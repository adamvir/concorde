import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../widgets/account_selector_bottom_sheet.dart';
import '../state/account_state.dart';
import '../state/currency_state.dart';
import '../data/mock_portfolio_data.dart';
import '../data/market_stocks_data.dart';
import '../services/transaction_service.dart';
import 'stock_buy_page.dart';

class ReszvenyInfoPage extends StatelessWidget {
  final String stockName;
  final String ticker;

  const ReszvenyInfoPage({
    Key? key,
    required this.stockName,
    required this.ticker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ReszvenyInfoContent(stockName: stockName, ticker: ticker),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    // Get stock data from market
    MarketStock? marketStock = MarketStocksData.getByTicker(ticker);
    double currentPrice = marketStock?.currentPrice ?? 0;
    String currency = marketStock?.currency ?? 'USD';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockBuyPage(
                            stockName: stockName,
                            ticker: ticker,
                            currentPrice: currentPrice,
                            currency: currency,
                            initialTradeType: 'Vétel',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009966),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.circle_plus, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Vétel',
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
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockBuyPage(
                            stockName: stockName,
                            ticker: ticker,
                            currentPrice: currentPrice,
                            currency: currency,
                            initialTradeType: 'Eladás',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC003F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.circle_minus, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Eladás',
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
                SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    icon: Icon(TablerIcons.dots_vertical, size: 24, color: Color(0xFF1D293D)),
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                  ),
                ),
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
}

class ReszvenyInfoContent extends StatefulWidget {
  final String stockName;
  final String ticker;

  const ReszvenyInfoContent({
    Key? key,
    required this.stockName,
    required this.ticker,
  }) : super(key: key);

  @override
  State<ReszvenyInfoContent> createState() => _ReszvenyInfoContentState();
}

class _ReszvenyInfoContentState extends State<ReszvenyInfoContent> {
  final AccountState _accountState = AccountState();
  final MockPortfolioData _portfolioData = MockPortfolioData();
  final CurrencyState _currencyState = CurrencyState();
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _accountState.addListener(_onAccountChanged);
    _currencyState.addListener(_onCurrencyChanged);
    _transactionService.addListener(_onTransactionChanged);
  }

  @override
  void dispose() {
    _accountState.removeListener(_onAccountChanged);
    _currencyState.removeListener(_onCurrencyChanged);
    _transactionService.removeListener(_onTransactionChanged);
    super.dispose();
  }

  void _onTransactionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onAccountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onCurrencyChanged() {
    print('ReszvenyInfo: Currency changed to ${_currencyState.selectedCurrency}');
    if (mounted) {
      setState(() {});
    }
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

  String _formatCurrency(double value) {
    String valueStr = value.toStringAsFixed(2);
    valueStr = valueStr.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} '
    );
    return valueStr;
  }

  // Get stock details from MockPortfolioData
  Map<String, dynamic> _getStockData() {
    return _portfolioData.getStockDetails(
      widget.ticker,
      _accountState.selectedAccount,
      currency: _currencyState.selectedCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _getStockData();
    final Color profitColor = data['isPositive']
        ? const Color(0xFF007A55)
        : const Color(0xFFEC003F);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.stockName,
                        style: TextStyle(
                          color: const Color(0xFF1D293D),
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _accountState.selectedAccount,
                        style: TextStyle(
                          color: const Color(0xFF45556C),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(TablerIcons.circle_chevron_down, color: Color(0xFF1D293D)),
                  onPressed: _showAccountSelectorBottomSheet,
                ),
                IconButton(
                  icon: Icon(TablerIcons.info_square_rounded, color: Color(0xFF1D293D)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Summary section
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Trigger a rebuild to refresh data
                setState(() {});
                // Small delay for visual feedback
                await Future.delayed(Duration(milliseconds: 300));
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                '${_formatCurrency(data['totalValue'])} ${_currencyState.selectedCurrency}',
                                style: TextStyle(
                                  color: const Color(0xFF1D293D),
                                  fontSize: 28,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${data['totalQuantity']} db',
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Átlag bekerülés',
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${_formatCurrency(data['totalCost'])} ${_currencyState.selectedCurrency}',
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nem realizált eredmény',
                                    style: TextStyle(
                                      color: const Color(0xFF45556C),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${_formatCurrency(data['totalProfit'].abs())} ${_currencyState.selectedCurrency}',
                                    style: TextStyle(
                                      color: profitColor,
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${data['profitPercent'].toStringAsFixed(2)}%',
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Piaci / Átlag beker. ár',
                                    style: TextStyle(
                                      color: const Color(0xFF45556C),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${_formatCurrency(data['currentPrice'])} ${data['currency']}',
                                    style: TextStyle(
                                      color: const Color(0xFF45556C),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${_formatCurrency(data['avgPrice'])} ${data['currency']}',
                                    style: TextStyle(
                                      color: const Color(0xFF45556C),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Számla',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Össz. darab @ átl. ár',
                              style: TextStyle(
                                color: const Color(0xFF45556C),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.50,
                              ),
                            ),
                            Row(
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
                                      letterSpacing: 0.50,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(
                                  width: 96,
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
                  // Account rows
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: (data['accounts'] as List).map<Widget>((accountData) {
                        final stock = accountData['stock'] as Stock;
                        final accountValue = accountData['valueInCurrency'];
                        final accountProfit = accountData['profitInCurrency'];
                        final accountProfitPercent = stock.profitPercent;
                        final isPositive = accountProfit >= 0;

                        Color accountProfitColor = isPositive
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
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    accountData['accountName'],
                                    style: TextStyle(
                                      color: const Color(0xFF1D293D),
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${_formatCurrency(accountValue)} ${_currencyState.selectedCurrency}',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${stock.quantity}db @ ${_formatCurrency(stock.avgPrice)} ${stock.currency}',
                                    style: TextStyle(
                                      color: const Color(0xFF45556C),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 66,
                                        child: Text(
                                          '${accountProfitPercent >= 0 ? '+' : ''}${accountProfitPercent.toStringAsFixed(2)}%',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: accountProfitColor,
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      SizedBox(
                                        width: 96,
                                        child: Text(
                                          '${_formatCurrency(accountProfit.abs())}',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: accountProfitColor,
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
          ),
        ],
      ),
    );
  }
}
