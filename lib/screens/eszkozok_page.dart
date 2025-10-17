import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'reszvenyek_page.dart';
import 'main_navigation.dart';
import 'szamla_detail_page.dart';
import 'reszveny_info_page.dart';
import '../widgets/account_selector_bottom_sheet.dart';
import '../state/account_state.dart';
import '../state/currency_state.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';
import '../data/mock_portfolio_data.dart';
import '../services/transaction_service.dart';

class EszkozokPage extends StatelessWidget {
  const EszkozokPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeState = app_theme.ThemeState();
    final colors = AppColors(isDark: themeState.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: EszkozokContent(),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final themeState = app_theme.ThemeState();
    final colors = AppColors(isDark: themeState.isDark);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: colors.border,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: colors.tabBarBackground,
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
            color: colors.tabBarBackground,
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

  Widget _buildBottomNavItem(BuildContext context, int index, IconData icon, String label) {
    final themeState = app_theme.ThemeState();
    final colors = AppColors(isDark: themeState.isDark);
    bool isSelected = index == 0; // Portfolio is always selected since we're viewing assets from there

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
                  color: isSelected ? colors.tabBarSelected : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? colors.tabBarIconSelected : colors.tabBarIconUnselected,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? colors.tabBarLabelSelected : colors.tabBarLabelUnselected,
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

class EszkozokContent extends StatefulWidget {
  final VoidCallback? onBack;

  const EszkozokContent({Key? key, this.onBack}) : super(key: key);

  @override
  State<EszkozokContent> createState() => _EszkozokContentState();
}

class _EszkozokContentState extends State<EszkozokContent> {
  String _selectedGrouping = 'Eszközosztály';
  final AccountState _accountState = AccountState();
  final CurrencyState _currencyState = CurrencyState();
  final app_theme.ThemeState _themeState = app_theme.ThemeState();
  final MockPortfolioData _portfolioData = MockPortfolioData();
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _accountState.addListener(_onAccountChanged);
    _currencyState.addListener(_onCurrencyChanged);
    _themeState.addListener(_onThemeChanged);
    _transactionService.addListener(_onTransactionChanged);
  }

  @override
  void dispose() {
    _accountState.removeListener(_onAccountChanged);
    _currencyState.removeListener(_onCurrencyChanged);
    _themeState.removeListener(_onThemeChanged);
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
    print('Eszkozok: Currency changed to ${_currencyState.selectedCurrency}');
    if (mounted) {
      setState(() {});
    }
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  AccountPortfolio _getCurrentPortfolio() {
    if (_accountState.selectedAccount == 'Minden számla') {
      return _portfolioData.getCombinedPortfolio();
    }
    return _portfolioData.getAccountByName(_accountState.selectedAccount) ??
           _portfolioData.getCombinedPortfolio();
  }

  String _formatCurrency(double value) {
    String valueStr = value.toStringAsFixed(0);
    valueStr = valueStr.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} '
    );
    return valueStr;
  }

  List<Map<String, dynamic>> _getCashBreakdown() {
    List<Map<String, dynamic>> cashList = [];

    if (_accountState.selectedAccount == 'Minden számla') {
      // Aggregate cash from all accounts by currency
      Map<String, double> cashByCurrency = {};
      for (var account in _portfolioData.getAllAccounts()) {
        for (var cash in account.cash) {
          cashByCurrency[cash.currency] = (cashByCurrency[cash.currency] ?? 0) + cash.amount;
        }
      }

      cashByCurrency.forEach((currency, amount) {
        cashList.add({
          'currency': currency,
          'amount': amount,
          'amountInHUF': _convertToHUF(amount, currency),
        });
      });
    } else {
      var account = _portfolioData.getAccountByName(_accountState.selectedAccount);
      if (account != null) {
        for (var cash in account.cash) {
          cashList.add({
            'currency': cash.currency,
            'amount': cash.amount,
            'amountInHUF': _convertToHUF(cash.amount, cash.currency),
          });
        }
      }
    }

    return cashList;
  }

  double _convertToHUF(double value, String currency) {
    if (currency == 'HUF') return value;
    if (currency == 'USD') return value * 380;
    if (currency == 'EUR') return value * 410;
    return value;
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

  void _showGroupingSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GroupingSelectorBottomSheet(
        selectedGrouping: _selectedGrouping,
        onGroupingSelected: (grouping) {
          setState(() {
            _selectedGrouping = grouping;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: Icon(TablerIcons.arrow_left, size: 24, color: colors.textPrimary),
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                SizedBox(width: 8),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eszközök',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _accountState.selectedAccount,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circle chevron down button
                IconButton(
                  icon: Icon(TablerIcons.circle_chevron_down, size: 24, color: colors.textPrimary),
                  onPressed: _showAccountSelectorBottomSheet,
                ),
              ],
            ),
          ),

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
                  // Portfolio Summary
                  Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final portfolio = _getCurrentPortfolio();
                            final totalValue = portfolio.totalValueIn(_currencyState.selectedCurrency);
                            final unrealizedProfit = portfolio.unrealizedProfitIn(_currencyState.selectedCurrency);
                            final profitPercent = portfolio.totalProfitPercent;
                            final isPositive = unrealizedProfit >= 0;
                            final profitColor = isPositive ? colors.success : colors.error;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatCurrency(totalValue)} ${_currencyState.selectedCurrency}',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 28,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Nem realizált eredmény',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '${_formatCurrency(unrealizedProfit.abs())} ${_currencyState.selectedCurrency}',
                                  style: TextStyle(
                                    color: profitColor,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${profitPercent.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: profitColor,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Összesítés dropdown
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
                                  color: colors.inputBorder,
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
                                        color: colors.textPrimary,
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Icon(TablerIcons.chevron_down, size: 16, color: colors.textPrimary),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              color: colors.surfaceElevated,
                              child: Text(
                                'Összesítés',
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
                    ],
                  ),
                ),

                // Csoportosítás dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: _showGroupingSelectorBottomSheet,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: colors.inputBorder,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.only(top: 4, left: 16, bottom: 4, right: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedGrouping,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Icon(TablerIcons.chevron_down, size: 16, color: colors.textPrimary),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          color: colors.background,
                          child: Text(
                            'Csoportosítás',
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

                // Progress bar and list (conditional based on grouping)
                _selectedGrouping == 'Eszközosztály'
                    ? _buildAssetClassView()
                    : _selectedGrouping == 'Termék'
                      ? _buildProductView()
                      : _buildAccountView(),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
        ),
      ],
    ),
    );
  }

  // Asset class view (original)
  Widget _buildAssetClassView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Builder(
        builder: (context) {
          final portfolio = _getCurrentPortfolio();
          final totalValue = portfolio.totalValueIn(_currencyState.selectedCurrency);
          final stocksValue = portfolio.stocksValueIn(_currencyState.selectedCurrency);
          final fundsValue = portfolio.fundsValueIn(_currencyState.selectedCurrency);
          final cashValue = portfolio.cashValueIn(_currencyState.selectedCurrency);
          final unrealizedProfit = portfolio.unrealizedProfitIn(_currencyState.selectedCurrency);

          final stocksPercent = totalValue > 0 ? (stocksValue / totalValue * 100) : 0;
          final fundsPercent = totalValue > 0 ? (fundsValue / totalValue * 100) : 0;
          final cashPercent = totalValue > 0 ? (cashValue / totalValue * 100) : 0;

                      return Column(
                        children: [
                          // Dynamic Progress bar
                          Container(
                            width: double.infinity,
                            height: 12,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (stocksPercent > 0)
                                  Expanded(
                                    flex: stocksPercent.round(),
                                    child: Container(color: const Color(0xFFE17100)),
                                  ),
                                if (fundsPercent > 0)
                                  Expanded(
                                    flex: fundsPercent.round(),
                                    child: Container(color: const Color(0xFFFFBA00)),
                                  ),
                                if (cashPercent > 0)
                                  Expanded(
                                    flex: cashPercent.round(),
                                    child: Container(color: const Color(0xFFFEE685)),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14),
                          // Asset list
                          Builder(
                            builder: (innerContext) {
                              final cashBreakdown = _getCashBreakdown();

                              List<Widget> assetWidgets = [
                                _buildAssetRow(
                                  'Részvények',
                                  '${_formatCurrency(stocksValue)} ${_currencyState.selectedCurrency}',
                                  '${stocksPercent.toStringAsFixed(1)}%',
                                  unrealizedProfit >= 0 ? '+${(unrealizedProfit / (totalValue - unrealizedProfit) * 100).toStringAsFixed(2)}%' : '${(unrealizedProfit / (totalValue - unrealizedProfit) * 100).toStringAsFixed(2)}%',
                                  _formatCurrency(unrealizedProfit.abs()),
                                  unrealizedProfit >= 0,
                                  iconColor: Color(0xFFE17100),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ReszvenyekPage()),
                                    );
                                  },
                                ),
                                _buildAssetRow(
                                  'Alapok',
                                  '${_formatCurrency(fundsValue)} ${_currencyState.selectedCurrency}',
                                  '${fundsPercent.toStringAsFixed(1)}%',
                                  '0,00%',
                                  '0',
                                  null,
                                  iconColor: Color(0xFFFFBA00)
                                ),
                                _buildAssetRow(
                                  'Szabad pénz',
                                  '${_formatCurrency(cashValue)} ${_currencyState.selectedCurrency}',
                                  '${cashPercent.toStringAsFixed(1)}%',
                                  '0,00%',
                                  '0',
                                  null,
                                  iconColor: Color(0xFFFEE685)
                                ),
                              ];

                              // Add cash breakdown sub-items
                              for (int i = 0; i < cashBreakdown.length; i++) {
                                final cash = cashBreakdown[i];
                                final isLast = i == cashBreakdown.length - 1;
                                final cashInSelectedCurrency = _convertToHUF(cash['amount'], cash['currency']) / MarketData.getRate(_currencyState.selectedCurrency);
                                final cashPercentOfTotal = totalValue > 0 ? (cashInSelectedCurrency / totalValue * 100) : 0;

                                assetWidgets.add(
                                  _buildAssetRow(
                                    cash['currency'] == 'HUF'
                                      ? '${cash['currency']}:'
                                      : '${cash['currency']}: ${_formatCurrency(cash['amount'])}',
                                    '${_formatCurrency(cashInSelectedCurrency)} ${_currencyState.selectedCurrency}',
                                    '${cashPercentOfTotal.toStringAsFixed(1)}%',
                                    '0,00%',
                                    '0',
                                    null,
                                    isSubItem: true,
                                    isLast: isLast,
                                  ),
                                );
                              }

                              return Column(children: assetWidgets);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
  }

  // Product view (by individual products - stocks, funds, etc.)
  Widget _buildProductView() {
    AccountPortfolio portfolio = _getCurrentPortfolio();
    String currency = _currencyState.selectedCurrency;

    // Create a list of all products (stocks, funds, cash) with their values
    List<Map<String, dynamic>> products = [];

    // Add stocks
    for (var stock in portfolio.stocks) {
      double valueInCurrency = MarketData.convert(stock.totalValue, stock.currency, currency);
      double profitInCurrency = MarketData.convert(stock.unrealizedProfit, stock.currency, currency);
      products.add({
        'name': stock.name,
        'ticker': stock.ticker,
        'value': valueInCurrency,
        'profit': profitInCurrency,
        'profitPercent': stock.profitPercent,
        'type': 'stock',
      });
    }

    // Add funds
    for (var fund in portfolio.funds) {
      double valueInCurrency = MarketData.convert(fund.value, fund.currency, currency);
      double profitInCurrency = MarketData.convert(fund.unrealizedProfit, fund.currency, currency);
      products.add({
        'name': fund.name,
        'value': valueInCurrency,
        'profit': profitInCurrency,
        'profitPercent': fund.profitPercent,
        'type': 'fund',
      });
    }

    // Add cash (each currency as separate item)
    for (var cash in portfolio.cash) {
      double valueInCurrency = MarketData.convert(cash.amount, cash.currency, currency);
      products.add({
        'name': 'Készpénz (${cash.currency})',
        'value': valueInCurrency,
        'profit': 0.0,
        'profitPercent': 0.0,
        'type': 'cash',
      });
    }

    // Sort by value (descending)
    products.sort((a, b) => b['value'].compareTo(a['value']));

    // Calculate total value for percentages
    double totalValue = products.fold(0.0, (sum, item) => sum + item['value']);

    // Generate colors for progress bar
    List<Color> colors = [
      const Color(0xFFE17100),
      const Color(0xFFFFBA00),
      const Color(0xFF00A3FF),
      const Color(0xFF1D293D),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF45556C),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Column(
        children: [
          // Progress bar
          if (products.isNotEmpty)
            Container(
              width: double.infinity,
              height: 12,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                children: products.asMap().entries.map((entry) {
                  int index = entry.key;
                  var product = entry.value;
                  double percentage = totalValue > 0 ? (product['value'] / totalValue) * 100 : 0;

                  return Expanded(
                    flex: (percentage * 10).round().clamp(1, 1000),
                    child: Container(
                      color: colors[index % colors.length],
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 14),
          // Product list
          if (products.isEmpty)
            Builder(
              builder: (context) {
                final colors = AppColors(isDark: _themeState.isDark);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Nincs termék',
                      style: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Column(
              children: products.asMap().entries.map((entry) {
                int index = entry.key;
                var product = entry.value;
                double percentage = totalValue > 0 ? (product['value'] / totalValue) * 100 : 0;
                bool? isPositive;
                if (product['type'] != 'cash') {
                  isPositive = product['profit'] >= 0;
                }

                return _buildAssetRow(
                  product['name'],
                  '${_formatCurrency(product['value'])} $currency',
                  '${percentage.toStringAsFixed(1)}%',
                  product['type'] != 'cash' ? '${product['profitPercent'] >= 0 ? '+' : ''}${product['profitPercent'].toStringAsFixed(2)}%' : '0,00%',
                  product['type'] != 'cash' ? '${product['profit'] >= 0 ? '+' : ''}${_formatCurrency(product['profit'].abs())}' : '0',
                  isPositive,
                  iconColor: colors[index % colors.length],
                  isLast: index == products.length - 1,
                  onTap: product['type'] == 'stock' ? () {
                    // Navigate to ReszvenyInfoPage for stocks only
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReszvenyInfoPage(
                          stockName: product['name'],
                          ticker: product['ticker'],
                        ),
                      ),
                    );
                  } : null,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Account view (new)
  Widget _buildAccountView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Column(
        children: [
          // Dynamic Progress bar showing account distribution
          _buildAccountProgressBar(),
          SizedBox(height: 14),
          // Account list
          _buildAccountList(),
        ],
      ),
    );
  }

  Widget _buildAccountProgressBar() {
    // Calculate each account's value as percentage of total
    List<AccountPortfolio> allAccounts = _portfolioData.getAllAccounts();
    double totalValue = 0;
    Map<String, double> accountValues = {};

    // Calculate total and individual values
    for (var account in allAccounts) {
      double value = account.totalValueIn(_currencyState.selectedCurrency);
      accountValues[account.accountName] = value;
      totalValue += value;
    }

    // Define colors for accounts
    Map<String, Color> accountColors = {
      'TBSZ-2023': Color(0xFFFFBA00),
      'TBSZ-2024': Color(0xFFE17100),
      'Értékpapírszámla': Color(0xFF6B7280),
    };

    return Container(
      width: double.infinity,
      height: 12,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: allAccounts.map((account) {
          double value = accountValues[account.accountName] ?? 0;
          double percent = totalValue > 0 ? (value / totalValue) * 100 : 0;
          Color color = accountColors[account.accountName] ?? Color(0xFF9CA3AF);

          if (percent <= 0) return SizedBox.shrink();

          return Expanded(
            flex: percent.round(),
            child: Container(color: color),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountList() {
    List<AccountPortfolio> allAccounts = _portfolioData.getAllAccounts();
    double combinedTotal = _portfolioData.getCombinedPortfolio().totalValueIn(_currencyState.selectedCurrency);

    // Define colors for account icons
    Map<String, Color> accountColors = {
      'TBSZ-2023': Color(0xFFFFBA00),
      'TBSZ-2024': Color(0xFFE17100),
      'Értékpapírszámla': Color(0xFF6B7280),
    };

    return Column(
      children: allAccounts.map((account) {
        double accountValue = account.totalValueIn(_currencyState.selectedCurrency);
        double accountPercent = combinedTotal > 0 ? (accountValue / combinedTotal) * 100 : 0;
        double accountProfit = account.unrealizedProfitIn(_currencyState.selectedCurrency);
        double accountCost = accountValue - accountProfit;
        double accountProfitPercent = accountCost > 0 ? (accountProfit / accountCost) * 100 : 0;
        bool isPositive = accountProfit >= 0;

        return _buildAssetRow(
          account.accountName,
          '${_formatCurrency(accountValue)} ${_currencyState.selectedCurrency}',
          '${accountPercent.toStringAsFixed(1)}%',
          '${isPositive ? '+' : ''}${accountProfitPercent.toStringAsFixed(2)}%',
          '${isPositive ? '+' : ''}${_formatCurrency(accountProfit.abs())}',
          isPositive,
          iconColor: accountColors[account.accountName] ?? Color(0xFF9CA3AF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SzamlaDetailPage(accountName: account.accountName),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildAssetRow(
    String title,
    String amount,
    String percentage,
    String changePercent,
    String changeAmount,
    bool? isPositive, {
    Color? iconColor,
    bool isSubItem = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    final colors = AppColors(isDark: _themeState.isDark);

    Color getChangeColor() {
      if (isPositive == null) return colors.textSecondary;
      return isPositive ? colors.success : colors.error;
    }

    Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: isLast ? 0 : 1,
            color: colors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          if (iconColor != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                TablerIcons.circle_filled,
                size: 16,
                color: iconColor,
              ),
            )
          else
            SizedBox(width: isSubItem ? 52 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      amount,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      percentage,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            changePercent,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: getChangeColor(),
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
                            changeAmount,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: getChangeColor(),
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
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
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
    final themeState = app_theme.ThemeState();
    final colors = AppColors(isDark: themeState.isDark);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
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
                        color: colors.textPrimary,
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
                    icon: Icon(TablerIcons.x, size: 24, color: colors.textPrimary),
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
    final themeState = app_theme.ThemeState();
    final colors = AppColors(isDark: themeState.isDark);
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
          color: isSelected ? (themeState.isDark ? colors.accentDark : colors.accent) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          currency,
          style: TextStyle(
            color: isSelected ? colors.textPrimary : colors.textSecondary,
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

// Grouping Selector Bottom Sheet
class GroupingSelectorBottomSheet extends StatefulWidget {
  final String selectedGrouping;
  final Function(String) onGroupingSelected;

  const GroupingSelectorBottomSheet({
    Key? key,
    required this.selectedGrouping,
    required this.onGroupingSelected,
  }) : super(key: key);

  @override
  State<GroupingSelectorBottomSheet> createState() => _GroupingSelectorBottomSheetState();
}

class _GroupingSelectorBottomSheetState extends State<GroupingSelectorBottomSheet> {
  late String _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedGrouping;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = app_theme.ThemeState();
    final colors = AppColors(isDark: themeState.isDark);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
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
                      'Csoportosítás',
                      style: TextStyle(
                        color: colors.textPrimary,
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
                    icon: Icon(TablerIcons.x, size: 24, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          // Grouping options
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildGroupingOption(context, 'Eszközosztály'),
                _buildGroupingOption(context, 'Termék'),
                _buildGroupingOption(context, 'Szolgáltatás'),
                _buildGroupingOption(context, 'Számla'),
                _buildGroupingOption(context, 'Devizakitettség'),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGroupingOption(BuildContext context, String grouping) {
    final themeState = app_theme.ThemeState();
    final colors = AppColors(isDark: themeState.isDark);
    final bool isSelected = grouping == _currentSelection;

    return InkWell(
      onTap: () {
        setState(() {
          _currentSelection = grouping;
        });
        widget.onGroupingSelected(grouping);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? (themeState.isDark ? colors.accentDark : colors.accent) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          grouping,
          style: TextStyle(
            color: isSelected ? colors.textPrimary : colors.textSecondary,
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
