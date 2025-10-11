import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'eszkozok_page.dart';
import '../widgets/account_selector_bottom_sheet.dart' as account_chooser;
import '../state/account_state.dart';
import '../state/currency_state.dart';
import '../data/mock_portfolio_data.dart';
import '../services/transaction_service.dart';

// Widget a teljes portfolio oldalhoz (ha külön navigáció kellene)
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: PortfolioContent(),
      ),
    );
  }
}

// Portfolio tartalom widget (ezt használjuk a main navigation-ben)
class PortfolioContent extends StatefulWidget {
  const PortfolioContent({Key? key}) : super(key: key);

  @override
  _PortfolioContentState createState() => _PortfolioContentState();
}

class _PortfolioContentState extends State<PortfolioContent> {
  int _chartViewIndex = 0; // 0 = Érték vált., 1 = Eszközosztályok, 2 = Devizakitettség, 3 = Termék, 4 = Számla
  int _previousChartViewIndex = 0; // Track previous index for slide direction
  bool _isExpanded = true; // Track expansion state for accordion animation
  String _selectedPeriod = '1M'; // Selected time period for value change chart
  final AccountState _accountState = AccountState();
  final CurrencyState _currencyState = CurrencyState();
  final MockPortfolioData _portfolioData = MockPortfolioData();
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _accountState.addListener(_onAccountChanged);
    _currencyState.addListener(_onCurrencyChanged);
    _transactionService.addListener(_onTransactionChanged);
  }

  void _onTransactionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _accountState.removeListener(_onAccountChanged);
    _currencyState.removeListener(_onCurrencyChanged);
    _transactionService.removeListener(_onTransactionChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    print('Portfolio: Account changed to ${_accountState.selectedAccount}');
    if (mounted) {
      setState(() {
        // Force rebuild when account changes
      });
    }
  }

  void _onCurrencyChanged() {
    print('Portfolio: Currency changed to ${_currencyState.selectedCurrency}');
    if (mounted) {
      setState(() {
        // Force rebuild when currency changes
      });
    }
  }

  AccountPortfolio _getCurrentPortfolio() {
    if (_accountState.selectedAccount == 'Minden számla') {
      return _portfolioData.getCombinedPortfolio();
    }
    return _portfolioData.getAccountByName(_accountState.selectedAccount) ??
           _portfolioData.getCombinedPortfolio();
  }

  List<HistoricalDataPoint> _getChartData() {
    AccountPortfolio portfolio = _getCurrentPortfolio();
    return HistoricalDataGenerator.getDataForPeriod(
      fullData: portfolio.historicalData,
      period: _selectedPeriod,
    );
  }

  String _formatCurrency(double value, {bool compact = false}) {
    String valueStr = value.toStringAsFixed(0);
    valueStr = valueStr.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} '
    );
    return valueStr;
  }

  void _showAccountChooserBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => account_chooser.AccountSelectorBottomSheet(
        selectedAccount: _accountState.selectedAccount,
        onAccountSelected: (account) {
          _accountState.setSelectedAccount(account);
        },
      ),
    );
  }

  void _showAccountSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AccountSelectorBottomSheet(
        selectedView: _getViewTypeFromIndex(_chartViewIndex),
        onViewSelected: (viewType) {
          setState(() {
            _previousChartViewIndex = _chartViewIndex;
            _chartViewIndex = _getIndexFromViewType(viewType);
          });
          Navigator.pop(context);
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

  String _getViewTypeFromIndex(int index) {
    switch (index) {
      case 0: return 'Értékváltozás';
      case 1: return 'Eszközosztály';
      case 2: return 'Devizakitettség';
      case 3: return 'Termék';
      case 4: return 'Számla';
      default: return 'Értékváltozás';
    }
  }

  int _getIndexFromViewType(String viewType) {
    if (viewType == 'Értékváltozás') return 0;
    if (viewType == 'Eszközosztály') return 1;
    if (viewType == 'Devizakitettség') return 2;
    if (viewType == 'Termék') return 3;
    if (viewType == 'Számla') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Concorde logo
              SvgPicture.asset(
                'lib/assets/images/concorde.svg',
                width: 40,
                height: 40,
              ),
              SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Portfólió',
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ListenableBuilder(
                      listenable: _accountState,
                      builder: (context, child) {
                        return Text(
                          _accountState.selectedAccount,
                          style: TextStyle(
                            color: const Color(0xFF45556C),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Action buttons
              IconButton(
                icon: Icon(TablerIcons.circle_chevron_down, color: Color(0xFF1D293D)),
                onPressed: _showAccountChooserBottomSheet,
              ),
              IconButton(
                icon: Icon(TablerIcons.search, color: Color(0xFF1D293D)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(TablerIcons.speakerphone, color: Color(0xFF1D293D)),
                onPressed: () {},
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
                    color: const Color(0xFFF8FAFC),
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
                                  ),
                                ),
                                SizedBox(height: 4),
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

                // Chart section with fixed header and animated content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fixed header with title and controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Animated title
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: Offset(_chartViewIndex > _previousChartViewIndex ? 0.3 : -0.3, 0.0),
                                  end: Offset.zero,
                                ).animate(animation);

                                return ClipRect(
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 250,
                                child: Text(
                                  _getChartTitle(),
                                  key: ValueKey(_chartViewIndex),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xFF1D293D),
                                    fontSize: 22,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Fixed control buttons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(TablerIcons.circle_chevron_down, size: 24),
                                onPressed: _showAccountSelectorBottomSheet,
                              ),
                              IconButton(
                                icon: Icon(TablerIcons.chevron_left, size: 24),
                                onPressed: () async {
                                  setState(() {
                                    _isExpanded = false;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 200));
                                  setState(() {
                                    _previousChartViewIndex = _chartViewIndex;
                                    _chartViewIndex = (_chartViewIndex - 1) % 5;
                                    if (_chartViewIndex < 0) _chartViewIndex = 4;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 50));
                                  setState(() {
                                    _isExpanded = true;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(TablerIcons.chevron_right, size: 24),
                                onPressed: () async {
                                  setState(() {
                                    _isExpanded = false;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 200));
                                  setState(() {
                                    _previousChartViewIndex = _chartViewIndex;
                                    _chartViewIndex = (_chartViewIndex + 1) % 5;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 50));
                                  setState(() {
                                    _isExpanded = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14),
                      // Animated accordion content
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: _isExpanded
                            ? (_chartViewIndex == 0
                              ? _buildValueChangeContent()
                              : _chartViewIndex == 1
                                ? _buildAssetClassContent()
                                : _chartViewIndex == 2
                                  ? _buildCurrencyExposureContent()
                                  : _chartViewIndex == 3
                                    ? _buildProductContent()
                                    : _buildAccountContent())
                            : SizedBox(
                                key: const ValueKey('collapsed'),
                                width: double.infinity,
                                height: 0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation List
                Column(
                  children: [
                    _buildNavigationItem(
                      icon: TablerIcons.chart_pie,
                      title: 'Eszközök',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EszkozokPage()),
                        );
                      },
                    ),
                    _buildNavigationItem(
                      icon: TablerIcons.circle_check,
                      title: 'Teljesülések',
                      badge: '3',
                      onTap: () {},
                    ),
                    _buildNavigationItem(
                      icon: TablerIcons.file_text,
                      title: 'Megbízások: Nyitott',
                      badge: '1',
                      onTap: () {},
                    ),
                  ],
                ),

                SizedBox(height: 104), // Space for bottom nav
              ],
            ),
          ),
        ),
        ),
      ],
    );
  }

  String _getChartTitle() {
    switch (_chartViewIndex) {
      case 0:
        return 'Értékváltozás';
      case 1:
        return 'Eszközosztályok';
      case 2:
        return 'Devizakitettség';
      case 3:
        return 'Termék';
      case 4:
        return 'Számla';
      default:
        return '';
    }
  }

  Widget _buildValueChangeContent() {
    List<HistoricalDataPoint> chartData = _getChartData();
    print('Portfolio Chart: Data points: ${chartData.length}');

    // Calculate change
    double startValue = chartData.isNotEmpty ? chartData.first.value : 0;
    double endValue = chartData.isNotEmpty ? chartData.last.value : 0;
    double change = endValue - startValue;
    double changePercent = startValue > 0 ? (change / startValue) * 100 : 0;
    bool isPositive = change >= 0;
    Color changeColor = isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);

    // Convert change to selected currency
    double changeInCurrency = MarketData.convert(change, 'HUF', _currencyState.selectedCurrency);

    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value and percent change
        Text(
          '${isPositive ? '+' : ''}${_formatCurrency(changeInCurrency)} ${_currencyState.selectedCurrency}',
          style: TextStyle(
            color: changeColor,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
          style: TextStyle(
            color: changeColor,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16),
        // Period selector buttons
        Row(
          children: [
            _buildPeriodButton('1H'),
            SizedBox(width: 8),
            _buildPeriodButton('1M'),
            SizedBox(width: 8),
            _buildPeriodButton('6M'),
            SizedBox(width: 8),
            _buildPeriodButton('1É'),
          ],
        ),
        SizedBox(height: 16),
        // Line chart
        SizedBox(
          width: double.infinity,
          height: 180,
          child: _buildLineChart(chartData),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String period) {
    bool isSelected = _selectedPeriod == period;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFEF3C6) : Colors.transparent,
            border: Border.all(
              color: isSelected ? const Color(0xFFE5C643) : const Color(0xFFCAD5E2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1D293D) : const Color(0xFF45556C),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<HistoricalDataPoint> chartData) {
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'Nincs adat',
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    // Find min and max values for scaling
    double minValue = chartData.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double maxValue = chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Add padding to min/max
    double range = maxValue - minValue;
    double padding = range * 0.1;
    minValue -= padding;
    maxValue += padding;

    // Orange color like Apple Stocks
    Color lineColor = const Color(0xFFFF9500);

    // Format value for Y axis (compact format)
    String formatCompactValue(double value) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(0)}K';
      } else {
        return value.toStringAsFixed(0);
      }
    }

    return LineChart(
      LineChartData(
        minY: minValue,
        maxY: maxValue,
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: lineColor,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: lineColor,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.3),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: (maxValue - minValue) / 2, // Only show middle value
              getTitlesWidget: (value, meta) {
                // Only show middle value, skip min and max
                if (value == minValue || value == maxValue) {
                  return SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    formatCompactValue(value),
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxValue - minValue) / 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE2E8F0),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  Widget _buildAssetClassContent() {
    AccountPortfolio portfolio = _getCurrentPortfolio();

    // Calculate values in selected currency
    double stocksValue = portfolio.stocksValueIn(_currencyState.selectedCurrency);
    double fundsValue = portfolio.fundsValueIn(_currencyState.selectedCurrency);
    double cashValue = portfolio.cashValueIn(_currencyState.selectedCurrency);
    double totalValue = portfolio.totalValueIn(_currencyState.selectedCurrency);

    // Calculate percentages
    double stocksPercent = totalValue > 0 ? (stocksValue / totalValue) * 100 : 0;
    double fundsPercent = totalValue > 0 ? (fundsValue / totalValue) * 100 : 0;
    double cashPercent = totalValue > 0 ? (cashValue / totalValue) * 100 : 0;

    // Calculate profit percentages for stocks and funds
    double stocksCost = 0;
    double stocksProfit = 0;
    for (var stock in portfolio.stocks) {
      stocksCost += stock.totalCost * (MarketData.exchangeRates[stock.currency] ?? 1);
      stocksProfit += stock.unrealizedProfit * (MarketData.exchangeRates[stock.currency] ?? 1);
    }
    double stocksProfitPercent = stocksCost > 0 ? (stocksProfit / stocksCost) * 100 : 0;

    double fundsCost = 0;
    double fundsProfit = 0;
    for (var fund in portfolio.funds) {
      fundsCost += fund.cost * (MarketData.exchangeRates[fund.currency] ?? 1);
      fundsProfit += fund.unrealizedProfit * (MarketData.exchangeRates[fund.currency] ?? 1);
    }
    double fundsProfitPercent = fundsCost > 0 ? (fundsProfit / fundsCost) * 100 : 0;

    // Get cash by currency
    Map<String, double> cashByCurrency = portfolio.getCashByCurrency();
    Map<String, double> cashByCurrencyInHUF = portfolio.getCashByCurrencyInHUF();

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
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
                  child: Container(
                    color: const Color(0xFFE17100),
                  ),
                ),
              if (fundsPercent > 0)
                Expanded(
                  flex: fundsPercent.round(),
                  child: Container(
                    color: const Color(0xFFFFBA00),
                  ),
                ),
              if (cashPercent > 0)
                Expanded(
                  flex: cashPercent.round(),
                  child: Container(
                    color: const Color(0xFFFEE685),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 14),
        // Asset list
        Column(
          children: [
            _buildAssetRow(
              'Részvények',
              '${_formatCurrency(stocksValue)} ${_currencyState.selectedCurrency}',
              '${stocksPercent.toStringAsFixed(1)}%',
              '${stocksProfitPercent >= 0 ? '+' : ''}${stocksProfitPercent.toStringAsFixed(2)}%',
              '${stocksProfit >= 0 ? '+' : ''}${_formatCurrency(MarketData.convert(stocksProfit, 'HUF', _currencyState.selectedCurrency))}',
              stocksProfit >= 0,
              iconColor: Color(0xFFE17100),
            ),
            _buildAssetRow(
              'Alapok',
              '${_formatCurrency(fundsValue)} ${_currencyState.selectedCurrency}',
              '${fundsPercent.toStringAsFixed(1)}%',
              '${fundsProfitPercent >= 0 ? '+' : ''}${fundsProfitPercent.toStringAsFixed(2)}%',
              '${fundsProfit >= 0 ? '+' : ''}${_formatCurrency(MarketData.convert(fundsProfit, 'HUF', _currencyState.selectedCurrency))}',
              fundsProfit >= 0,
              iconColor: Color(0xFFFFBA00),
            ),
            _buildAssetRow(
              'Szabad pénz',
              '${_formatCurrency(cashValue)} ${_currencyState.selectedCurrency}',
              '${cashPercent.toStringAsFixed(1)}%',
              '0,00%',
              '0',
              null,
              iconColor: Color(0xFFFEE685),
            ),
            // Cash breakdown by currency
            ...cashByCurrency.entries.map((entry) {
              String currency = entry.key;
              double amount = entry.value;
              double valueInHUF = cashByCurrencyInHUF[currency] ?? 0;
              double valueInSelected = MarketData.convert(valueInHUF, 'HUF', _currencyState.selectedCurrency);
              double percentOfTotal = totalValue > 0 ? (valueInHUF / portfolio.totalValue) * 100 : 0;

              return _buildAssetRow(
                '$currency: ${_formatCurrency(amount)}',
                '${_formatCurrency(valueInSelected)} ${_currencyState.selectedCurrency}',
                '${percentOfTotal.toStringAsFixed(1)}%',
                '0,00%',
                '0',
                null,
                isSubItem: true,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyExposureContent() {
    AccountPortfolio portfolio = _getCurrentPortfolio();
    String displayCurrency = _currencyState.selectedCurrency;

    // Calculate currency exposure
    Map<String, double> currencyValues = {};
    Map<String, double> currencyProfits = {};

    // Add stocks by currency
    for (var stock in portfolio.stocks) {
      currencyValues[stock.currency] = (currencyValues[stock.currency] ?? 0) + stock.totalValue;
      currencyProfits[stock.currency] = (currencyProfits[stock.currency] ?? 0) + stock.unrealizedProfit;
    }

    // Add funds by currency
    for (var fund in portfolio.funds) {
      currencyValues[fund.currency] = (currencyValues[fund.currency] ?? 0) + fund.value;
      currencyProfits[fund.currency] = (currencyProfits[fund.currency] ?? 0) + fund.unrealizedProfit;
    }

    // Add cash by currency
    for (var cash in portfolio.cash) {
      currencyValues[cash.currency] = (currencyValues[cash.currency] ?? 0) + cash.amount;
      currencyProfits[cash.currency] = (currencyProfits[cash.currency] ?? 0) + 0;
    }

    // Sort by value (descending)
    List<MapEntry<String, double>> sortedCurrencies = currencyValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate total value in display currency
    double totalValue = 0;
    for (var entry in sortedCurrencies) {
      totalValue += MarketData.convert(entry.value, entry.key, displayCurrency);
    }

    // Calculate total profit in display currency
    double totalProfit = 0;
    for (var entry in currencyProfits.entries) {
      totalProfit += MarketData.convert(entry.value, entry.key, displayCurrency);
    }

    // Generate colors
    List<Color> colors = [
      const Color(0xFFE17100),
      const Color(0xFFFFBA00),
      const Color(0xFFFFD230),
      const Color(0xFFFEE685),
      const Color(0xFF00A3FF),
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
    ];

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        if (sortedCurrencies.isNotEmpty)
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
              children: sortedCurrencies.asMap().entries.map((entry) {
                int index = entry.key;
                var currencyEntry = entry.value;
                double valueInDisplay = MarketData.convert(currencyEntry.value, currencyEntry.key, displayCurrency);
                double percentage = totalValue > 0 ? (valueInDisplay / totalValue) * 100 : 0;

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
        // Currency list
        if (sortedCurrencies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nincs deviza kitettség',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          )
        else
          Column(
            children: sortedCurrencies.asMap().entries.map((entry) {
              int index = entry.key;
              String currency = entry.value.key;
              double valueInOriginal = entry.value.value;
              double valueInDisplay = MarketData.convert(valueInOriginal, currency, displayCurrency);
              double profitInOriginal = currencyProfits[currency] ?? 0;
              double profitInDisplay = MarketData.convert(profitInOriginal, currency, displayCurrency);

              double percentage = totalValue > 0 ? (valueInDisplay / totalValue) * 100 : 0;
              double profitPercent = totalValue > 0 ? (profitInDisplay / totalValue) * 100 : 0;
              bool isPositive = profitInDisplay >= 0;

              // Format the currency label
              String currencyLabel = currency;
              if (currency != displayCurrency) {
                // Show amount in original currency
                currencyLabel = '$currency: ${_formatCurrency(valueInOriginal)}';
              }

              return _buildCurrencyRow(
                currencyLabel,
                '${_formatCurrency(valueInDisplay)} $displayCurrency',
                '${percentage.toStringAsFixed(1)}%',
                '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                '${profitInDisplay >= 0 ? '+' : ''}${_formatCurrency(profitInDisplay.abs())}',
                isPositive,
                iconColor: colors[index % colors.length],
                isLast: index == sortedCurrencies.length - 1,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProductContent() {
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

    // Add cash
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
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nincs termék',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
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

              return _buildProductRow(
                product['name'],
                '${_formatCurrency(product['value'])} $currency',
                '${percentage.toStringAsFixed(1)}%',
                product['type'] != 'cash' ? '${product['profitPercent'] >= 0 ? '+' : ''}${product['profitPercent'].toStringAsFixed(2)}%' : '-',
                product['type'] != 'cash' ? '${product['profit'] >= 0 ? '+' : ''}${_formatCurrency(product['profit'].abs())}' : '-',
                isPositive,
                iconColor: colors[index % colors.length],
                isLast: index == products.length - 1,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildAccountContent() {
    String displayCurrency = _currencyState.selectedCurrency;

    // Get all accounts
    List<AccountPortfolio> accounts = [
      _portfolioData.tbsz2023,
      _portfolioData.tbsz2024,
      _portfolioData.ertekpapirSzamla,
    ];

    // Calculate values for each account
    List<Map<String, dynamic>> accountData = [];
    for (var account in accounts) {
      double valueInDisplay = account.totalValueIn(displayCurrency);
      double profitInDisplay = account.unrealizedProfitIn(displayCurrency);

      accountData.add({
        'name': account.accountName,
        'value': valueInDisplay,
        'profit': profitInDisplay,
      });
    }

    // Sort by value (descending)
    accountData.sort((a, b) => b['value'].compareTo(a['value']));

    // Calculate total value
    double totalValue = accountData.fold(0.0, (sum, item) => sum + item['value']);

    // Generate colors
    List<Color> colors = [
      const Color(0xFFE17100),
      const Color(0xFFFFBA00),
      const Color(0xFF00A3FF),
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
    ];

    // Only show accounts breakdown if "Minden számla" is selected
    bool showAllAccounts = _accountState.selectedAccount == 'Minden számla';

    // If specific account is selected, show only that one
    if (!showAllAccounts) {
      // Find the selected account
      AccountPortfolio? selectedAccount = accounts.firstWhere(
        (acc) => acc.accountName == _accountState.selectedAccount,
        orElse: () => accounts[0],
      );

      double valueInDisplay = selectedAccount.totalValueIn(displayCurrency);
      double profitInDisplay = selectedAccount.unrealizedProfitIn(displayCurrency);
      double profitPercent = valueInDisplay > 0 ? (profitInDisplay / valueInDisplay) * 100 : 0;
      bool isPositive = profitInDisplay >= 0;

      return Column(
        key: const ValueKey(4),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single color progress bar
          Container(
            width: double.infinity,
            height: 12,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: colors[0],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SizedBox(height: 14),
          // Single account
          _buildAccountRow(
            selectedAccount.accountName,
            '${_formatCurrency(valueInDisplay)} $displayCurrency',
            '100,0%',
            '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
            '${profitInDisplay >= 0 ? '+' : ''}${_formatCurrency(profitInDisplay.abs())}',
            isPositive,
            iconColor: colors[0],
            isLast: true,
          ),
        ],
      );
    }

    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        if (accountData.isNotEmpty)
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
              children: accountData.asMap().entries.map((entry) {
                int index = entry.key;
                var account = entry.value;
                double percentage = totalValue > 0 ? (account['value'] / totalValue) * 100 : 0;

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
        // Account list
        if (accountData.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nincsenek számlák',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          )
        else
          Column(
            children: accountData.asMap().entries.map((entry) {
              int index = entry.key;
              var account = entry.value;
              double percentage = totalValue > 0 ? (account['value'] / totalValue) * 100 : 0;
              double profitPercent = account['value'] > 0 ? (account['profit'] / account['value']) * 100 : 0;
              bool isPositive = account['profit'] >= 0;

              return _buildAccountRow(
                account['name'],
                '${_formatCurrency(account['value'])} $displayCurrency',
                '${percentage.toStringAsFixed(1)}%',
                '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                '${account['profit'] >= 0 ? '+' : ''}${_formatCurrency(account['profit'].abs())}',
                isPositive,
                iconColor: colors[index % colors.length],
                isLast: index == accountData.length - 1,
              );
            }).toList(),
          ),
      ],
    );
  }


  Widget _buildCurrencyRow(
    String title,
    String amount,
    String percentage,
    String changePercent,
    String changeAmount,
    bool? isPositive, {
    required Color iconColor,
    bool isLast = false,
  }) {
    // Determine color based on isPositive (null = neutral gray)
    Color getChangeColor() {
      if (isPositive == null) return const Color(0xFF45556C);
      return isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: isLast ? 0 : 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              TablerIcons.circle_filled,
              size: 16,
              color: iconColor,
            ),
          ),
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
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      amount,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      percentage,
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
                          width: 70,
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
                        SizedBox(
                          width: 70,
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
  }

  Widget _buildProductChart() {
    return Container(
      key: const ValueKey(3),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Termék',
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(TablerIcons.circle_chevron_down, size: 24),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(TablerIcons.chevron_left, size: 24),
                    onPressed: () {
                      setState(() {
                        _chartViewIndex = (_chartViewIndex - 1) % 5;
                        if (_chartViewIndex < 0) _chartViewIndex = 4;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(TablerIcons.chevron_right, size: 24),
                    onPressed: () {
                      setState(() {
                        _chartViewIndex = (_chartViewIndex + 1) % 5;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          // Progress bar with 2 segments
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
                Expanded(
                  flex: 228,
                  child: Container(
                    color: const Color(0xFFE17100),
                  ),
                ),
                Expanded(
                  flex: 100,
                  child: Container(
                    color: const Color(0xFFFFBA00),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          // Product list
          Column(
            children: [
              _buildProductRow('NVIDIA Corp.', '6.000.000 HUF', '70,0%', '24,43%', '424.123', true, iconColor: Color(0xFFE17100)),
              _buildProductRow('Vodafone Group', '1.513.393 HUF', '30,0%', '-5,41%', '-86.628', false, iconColor: Color(0xFFFFBA00), isLast: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(
    String title,
    String amount,
    String percentage,
    String changePercent,
    String changeAmount,
    bool? isPositive, {
    required Color iconColor,
    bool isLast = false,
  }) {
    Color getChangeColor() {
      if (isPositive == null) return const Color(0xFF45556C);
      return isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: isLast ? 0 : 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              TablerIcons.circle_filled,
              size: 16,
              color: iconColor,
            ),
          ),
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
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      amount,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      percentage,
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
                          width: 70,
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
                        SizedBox(
                          width: 70,
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
  }

  Widget _buildAccountChart() {
    return Container(
      key: const ValueKey(4),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Számla',
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(TablerIcons.circle_chevron_down, size: 24),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(TablerIcons.chevron_left, size: 24),
                    onPressed: () {
                      setState(() {
                        _chartViewIndex = (_chartViewIndex - 1) % 5;
                        if (_chartViewIndex < 0) _chartViewIndex = 4;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(TablerIcons.chevron_right, size: 24),
                    onPressed: () {
                      setState(() {
                        _chartViewIndex = (_chartViewIndex + 1) % 5;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          // Progress bar with 2 segments
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
                Expanded(
                  flex: 177,
                  child: Container(
                    color: const Color(0xFFE17100),
                  ),
                ),
                Expanded(
                  flex: 151,
                  child: Container(
                    color: const Color(0xFFFFBA00),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          // Account list
          Column(
            children: [
              _buildAccountRow('TBSZ-2024', '5.500.000 HUF', '55,0%', '34,43%', '1.424.123', true, iconColor: Color(0xFFE17100)),
              _buildAccountRow('TBSZ-2023', '4.500.000 HUF', '45,0%', '-10,43%', '-233.924', false, iconColor: Color(0xFFFFBA00), isLast: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow(
    String title,
    String amount,
    String percentage,
    String changePercent,
    String changeAmount,
    bool? isPositive, {
    required Color iconColor,
    bool isLast = false,
  }) {
    Color getChangeColor() {
      if (isPositive == null) return const Color(0xFF45556C);
      return isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: isLast ? 0 : 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              TablerIcons.circle_filled,
              size: 16,
              color: iconColor,
            ),
          ),
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
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      amount,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      percentage,
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
                          width: 70,
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
                        SizedBox(
                          width: 70,
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
  }

  Widget _buildAssetRow(
    String title,
    String amount,
    String percentage,
    String changePercent,
    String changeAmount,
    bool? isPositive, {
    bool isSubItem = false,
    Color? iconColor,
  }) {
    // Determine color based on isPositive (null = neutral gray)
    Color getChangeColor() {
      if (isPositive == null) return const Color(0xFF45556C);
      return isPositive ? const Color(0xFF007A55) : const Color(0xFFEC003F);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: isSubItem ? 0 : 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon or spacing
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
            SizedBox(width: 52), // Same spacing for items without icon
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
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      amount,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      percentage,
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
                          width: 70,
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
                        SizedBox(width: 20),
                        SizedBox(
                          width: 70,
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
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFFD9A00), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: const Color(0xFF1D293D),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.chevron_right, color: Color(0xFF45556C)),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

// Account Selector Bottom Sheet
class AccountSelectorBottomSheet extends StatefulWidget {
  final String selectedView;
  final Function(String) onViewSelected;

  const AccountSelectorBottomSheet({
    Key? key,
    required this.selectedView,
    required this.onViewSelected,
  }) : super(key: key);

  @override
  State<AccountSelectorBottomSheet> createState() => _AccountSelectorBottomSheetState();
}

class _AccountSelectorBottomSheetState extends State<AccountSelectorBottomSheet> {
  late String _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedView;
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
                      'Portfólió',
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
          // Options list
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildOptionItem(
                  context,
                  'Értékváltozás',
                ),
                _buildOptionItem(
                  context,
                  'Eszközosztály',
                ),
                _buildOptionItem(
                  context,
                  'Termék',
                ),
                _buildOptionItem(
                  context,
                  'Számla',
                ),
                _buildOptionItem(
                  context,
                  'Devizakitettség',
                ),
                _buildOptionItem(
                  context,
                  'Szolgáltatás',
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
  ) {
    final bool isSelected = title == _currentSelection;

    return InkWell(
      onTap: () {
        setState(() {
          _currentSelection = title;
        });
        widget.onViewSelected(title);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF3C6) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SizedBox(width: 24), // Space for icon
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF1D293D)
                        : const Color(0xFF45556C),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.43,
                    letterSpacing: 0.10,
                  ),
                ),
              ),
            ],
          ),
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
