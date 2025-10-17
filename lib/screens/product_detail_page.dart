import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/market_stocks_data.dart';
import '../data/mock_portfolio_data.dart';
import '../state/watchlist_state.dart';
import '../state/currency_state.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';
import '../services/transaction_service.dart';
import '../services/news_service.dart';
import '../models/news_article.dart';
import '../models/order_model.dart';
import '../widgets/chart_period_selector_bottom_sheet.dart';
import 'product_page_customize.dart';
import 'stock_buy_page.dart';
import 'order_detail_page.dart';

// Product Detail Page - Stock information page WITHOUT portfolio positions
// This is used when navigating from Kedvencek (Favorites)
class ProductDetailPage extends StatefulWidget {
  final String stockName;
  final String ticker;

  const ProductDetailPage({
    super.key,
    required this.stockName,
    required this.ticker,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Accordion expansion states
  bool _grafikonExpanded = false;
  bool _forgalomExpanded = false;
  bool _hirekExpanded = false;
  bool _eszkozokExpanded = false;
  bool _megbizasokExpanded = false;
  bool _arszintfigyeExpanded = false;
  bool _ajanlatiKonyvExpanded = false;
  bool _napiKotesExpanded = false;
  bool _termekleirasExpanded = false;

  // Chart time period selection
  String _selectedChartPeriod = '1 hónap';

  // Widget order list
  late List<ProductWidget> _widgetOrder;

  // Backend data services
  final MockPortfolioData _portfolioData = MockPortfolioData();
  final CurrencyState _currencyState = CurrencyState();
  final TransactionService _transactionService = TransactionService();
  final app_theme.ThemeState _themeState = app_theme.ThemeState();

  @override
  void initState() {
    super.initState();
    _themeState.addListener(_onThemeChanged);
    // Initialize widget order without badges (will be set dynamically in build)
    _widgetOrder = [
      ProductWidget(id: 'grafikon', icon: TablerIcons.chart_line, title: 'Grafikon'),
      ProductWidget(id: 'forgalom', icon: TablerIcons.chart_bar, title: 'Piaci adatok'),
      ProductWidget(id: 'hirek', icon: TablerIcons.news, title: 'Hírek'),
      ProductWidget(id: 'eszkozok', icon: TablerIcons.chart_pie, title: 'Eszközök'),
      ProductWidget(id: 'megbizasok', icon: TablerIcons.file_text, title: 'Megbízások: nyitott'),
      ProductWidget(id: 'arszintfigye', icon: TablerIcons.bell, title: 'Árszintfigyelés'),
      ProductWidget(id: 'ajanlati_konyv', icon: TablerIcons.book, title: 'Ajánlati könyv'),
      ProductWidget(id: 'napi_kotes', icon: TablerIcons.heart_handshake, title: 'Napi kötés lista'),
      ProductWidget(id: 'termekleiras', icon: TablerIcons.info_circle, title: 'Termékleírás'),
    ];

    // Add listeners for data changes
    _currencyState.addListener(_onDataChanged);
    _transactionService.addListener(_onDataChanged);
  }

  // Get dynamic badge for a widget
  String? _getWidgetBadge(String widgetId) {
    switch (widgetId) {
      case 'hirek':
        return '2 új';
      case 'eszkozok':
        // Get total value from backend mock data
        final stockData = _portfolioData.getStockDetails(
          widget.ticker,
          'Minden számla',
          currency: _currencyState.selectedCurrency,
        );
        final accounts = stockData['accounts'] as List;
        if (accounts.isEmpty) return null;

        // Calculate total value
        double totalValue = 0;
        for (var accountData in accounts) {
          totalValue += accountData['valueInCurrency'] as double;
        }

        // Use the selected currency from currency state
        return '${_formatCurrency(totalValue)} ${_currencyState.selectedCurrency}';
      case 'megbizasok':
        // Get count of open orders for this stock from backend
        dynamic service = _transactionService;
        List<Order> allOpenOrders = [];
        try {
          allOpenOrders = service.openOrders as List<Order>;
        } catch (e) {
          return null;
        }

        // Filter orders for this stock ticker
        final orders = allOpenOrders.where((order) => order.ticker == widget.ticker).toList();
        if (orders.isEmpty) return null;

        return '${orders.length} db';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    _currencyState.removeListener(_onDataChanged);
    _transactionService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    // Get WatchlistState to check if stock is in favorites
    final watchlistState = WatchlistState();
    final isFavorite = watchlistState.isStockInCurrentWatchlist(widget.ticker);

    // Get stock data
    final marketStock = MarketStocksData.allStocks.firstWhere(
      (stock) => stock.ticker == widget.ticker,
      orElse: () => MarketStocksData.allStocks.first,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(colors, isFavorite, watchlistState),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Delayed data banner
                    _buildDelayedDataBanner(colors),

                    // Price info section
                    _buildPriceInfo(colors, marketStock),

                    // Accordion sections - dynamically generated based on _widgetOrder
                    ..._widgetOrder.map((widget) => _buildAccordionForWidget(colors, widget)).toList(),

                    // Oldal testreszabása button
                    _buildCustomizeButton(colors),

                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Buy/Sell buttons
      bottomNavigationBar: _buildBottomButtons(colors, marketStock),
    );
  }

  // Build header with back button, stock name, favorite and notification icons
  Widget _buildHeader(AppColors colors, bool isFavorite, WatchlistState watchlistState) {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(TablerIcons.arrow_left, size: 24, color: colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Stock name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                widget.stockName,
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
          // Favorite icon
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(
                isFavorite ? TablerIcons.heart_filled : TablerIcons.heart,
                size: 24,
                color: isFavorite ? colors.error : colors.textSecondary,
              ),
              onPressed: () {
                // Toggle favorite in WatchlistState
                if (isFavorite) {
                  watchlistState.removeStockFromCurrentWatchlist(widget.ticker);
                } else {
                  watchlistState.addStockToCurrentWatchlist(widget.ticker);
                }
                setState(() {}); // Refresh UI
              },
            ),
          ),
          // Notification icon
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(TablerIcons.bell, size: 24, color: colors.textSecondary),
              onPressed: () {
                // TODO: Show notifications
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build delayed data banner
  Widget _buildDelayedDataBanner(AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.delayedBannerBackground,
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: colors.delayedBannerText,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.43,
            letterSpacing: 0.10,
          ),
          children: [
            TextSpan(text: '15 perccel késleltetett adatok. '),
            TextSpan(
              text: 'Előfizetés',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build price info section
  Widget _buildPriceInfo(AppColors colors, MarketStock stock) {
    // Mock data for demo
    final isPositive = true;
    final priceChange = 6.24;
    final percentChange = 4.43;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Price info with badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current price with badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${stock.currentPrice.toStringAsFixed(2)} ${stock.currency}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 15p badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.delayBadge,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '15p',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 0.50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Pre badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.preMarketBadge,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Pre',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 0.50,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Price change
                Text(
                  '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}% (${priceChange.toStringAsFixed(2)})',
                  style: TextStyle(
                    color: isPositive ? colors.success : colors.error,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side: V and E data only
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // V (Vétel)
              Text(
                'V 450 db @ 146,90',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
              const SizedBox(height: 4),
              // E (Eladás)
              Text(
                'E 1.045 db @ 147,08',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build accordion for widget based on ID
  Widget _buildAccordionForWidget(AppColors colors, ProductWidget widget) {
    // Get dynamic badge for this widget
    final badge = _getWidgetBadge(widget.id);

    switch (widget.id) {
      case 'grafikon':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _grafikonExpanded,
          onTap: () => setState(() => _grafikonExpanded = !_grafikonExpanded),
          child: _buildGrafikonContent(colors),
        );
      case 'forgalom':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _forgalomExpanded,
          onTap: () => setState(() => _forgalomExpanded = !_forgalomExpanded),
          child: _buildForgalomContent(colors),
        );
      case 'hirek':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _hirekExpanded,
          onTap: () => setState(() => _hirekExpanded = !_hirekExpanded),
          child: _buildHirekContent(colors),
        );
      case 'eszkozok':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _eszkozokExpanded,
          onTap: () => setState(() => _eszkozokExpanded = !_eszkozokExpanded),
          child: _buildEszkozokContent(colors),
          removeContentPadding: true,
        );
      case 'megbizasok':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _megbizasokExpanded,
          onTap: () => setState(() => _megbizasokExpanded = !_megbizasokExpanded),
          child: _buildMegbizasokContent(colors),
        );
      case 'arszintfigye':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _arszintfigyeExpanded,
          onTap: () => setState(() => _arszintfigyeExpanded = !_arszintfigyeExpanded),
          child: _buildArszintfigyeContent(colors),
        );
      case 'ajanlati_konyv':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _ajanlatiKonyvExpanded,
          onTap: () => setState(() => _ajanlatiKonyvExpanded = !_ajanlatiKonyvExpanded),
          child: _buildAjanlatiKonyvContent(colors),
        );
      case 'napi_kotes':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _napiKotesExpanded,
          onTap: () => setState(() => _napiKotesExpanded = !_napiKotesExpanded),
          child: _buildNapiKotesContent(colors),
        );
      case 'termekleiras':
        return _buildAccordionSection(
          colors: colors,
          icon: widget.icon,
          title: widget.title,
          badge: badge,
          isExpanded: _termekleirasExpanded,
          onTap: () => setState(() => _termekleirasExpanded = !_termekleirasExpanded),
          child: _buildTermekleirasContent(colors),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Build accordion section
  Widget _buildAccordionSection({
    required AppColors colors,
    required IconData icon,
    required String title,
    String? badge,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
    bool removeContentPadding = false,
  }) {
    return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(icon, size: 24, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: colors.textPrimary,
                          height: 1.33,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.badgeBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: colors.badgeText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      isExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: removeContentPadding ? EdgeInsets.zero : const EdgeInsets.all(16),
              color: colors.background,
              child: child,
            ),
        ],
    );
  }

  // Placeholder content widgets (will be implemented step by step)
  Widget _buildGrafikonContent(AppColors colors) {
    // Generate mock chart data based on stock ticker
    final chartData = _generateChartData();

    // Get stock data for price info
    final stock = MarketStocksData.allStocks.firstWhere(
      (s) => s.ticker == widget.ticker,
      orElse: () => MarketStocksData.allStocks.first,
    );

    // Calculate price change (mock data)
    final priceChangePercent = 2.1;
    final isPositive = priceChangePercent >= 0;
    final changeColor = isPositive ? colors.success : colors.error;

    // Find min and max values for scaling
    double minValue = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxValue = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    // Add padding to min/max
    double range = maxValue - minValue;
    double padding = range * 0.1;
    minValue -= padding;
    maxValue += padding;

    return Column(
      children: [
        // Top row: Price info (left) and period selector (right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Price and change info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatCurrency(stock.currentPrice * 400)} HUF',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.01,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.01,
                  ),
                ),
              ],
            ),
            // Right: Time period selector
            _buildPeriodSelector(colors),
          ],
        ),
        const SizedBox(height: 16),

        // Chart
        SizedBox(
          width: double.infinity,
          height: 180,
          child: LineChart(
            LineChartData(
              minY: minValue,
              maxY: maxValue,
              lineBarsData: [
                LineChartBarData(
                  spots: chartData,
                  isCurved: true,
                  color: colors.chartLine,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: colors.chartLine,
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
                        colors.chartAreaStart,
                        colors.chartAreaEnd,
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
                    interval: (maxValue - minValue) / 2,
                    getTitlesWidget: (value, meta) {
                      // Only show middle value, skip min and max
                      if (value == minValue || value == maxValue) {
                        return SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          _formatCompactValue(value),
                          style: TextStyle(
                            color: colors.chartLabel,
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
                    color: colors.chartGrid,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _formatCompactValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _buildPeriodSelector(AppColors colors) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => ChartPeriodSelectorBottomSheet(
            currentPeriod: _selectedChartPeriod,
            onPeriodSelected: (period) {
              setState(() {
                _selectedChartPeriod = period;
              });
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(
            color: colors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedChartPeriod,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              TablerIcons.chevron_down,
              size: 18,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    // Generate different data based on stock ticker for variety
    final seed = widget.ticker.codeUnits.reduce((a, b) => a + b);
    final basePrice = 140.0;
    final volatility = 20.0;

    List<FlSpot> spots = [];
    for (int i = 0; i < 30; i++) {
      final variation = (((seed + i * 7) % 100) / 100 - 0.5) * volatility;
      final price = basePrice + variation + (i * 0.5);
      spots.add(FlSpot(i.toDouble(), price));
    }

    return spots;
  }

  Widget _buildForgalomContent(AppColors colors) {
    // Generate dynamic market data based on stock price
    final marketStock = MarketStocksData.allStocks.firstWhere(
      (stock) => stock.ticker == widget.ticker,
      orElse: () => MarketStocksData.allStocks.first,
    );

    final currentPrice = marketStock.currentPrice;

    // Generate seed from ticker for consistent but varied data
    final seed = widget.ticker.codeUnits.reduce((a, b) => a + b);

    // Min/Max (today's range, ±0.5% to ±2%)
    final minPercent = 0.005 + (seed % 15) / 1000; // 0.5% - 2%
    final maxPercent = 0.005 + ((seed * 2) % 15) / 1000; // 0.5% - 2%
    final min = currentPrice * (1 - minPercent);
    final max = currentPrice * (1 + maxPercent);

    // 52 week range (±30% to ±60%)
    final week52LowPercent = 0.30 + ((seed * 3) % 30) / 100; // 30% - 60%
    final week52HighPercent = 0.20 + ((seed * 5) % 40) / 100; // 20% - 60%
    final week52Low = currentPrice * (1 - week52LowPercent);
    final week52High = currentPrice * (1 + week52HighPercent);

    // Averages (slight variations around current price)
    final avg1Day = currentPrice * (1 + (((seed * 7) % 100 - 50) / 10000)); // ±0.5%
    final avg180Day = currentPrice * (1 + (((seed * 11) % 100 - 50) / 1000)); // ±5%
    final avg360Day = currentPrice * (1 + (((seed * 13) % 100 - 50) / 800)); // ±6%

    // Volume (based on price, higher priced stocks = lower volume in millions)
    final volumeMillion = (100000 / currentPrice) * (1 + (seed % 50) / 100);

    // Relative volume (50% - 150%)
    final relVolume = 50 + (seed % 100);

    // P/E ratio (10 - 50)
    final pe = 10 + ((seed * 17) % 40).toDouble() + ((seed % 100) / 100);

    // RSI (20 - 80)
    final rsi = 20 + ((seed * 19) % 60).toDouble() + ((seed % 100) / 100);

    // Performance percentages (more variance for longer periods)
    final perf1Mo = -10 + ((seed * 23) % 30).toDouble() + ((seed % 100) / 100); // -10% to +20%
    final perf6Mo = -15 + ((seed * 29) % 50).toDouble() + ((seed % 100) / 100); // -15% to +35%
    final perf12Mo = -20 + ((seed * 31) % 70).toDouble() + ((seed % 100) / 100); // -20% to +50%

    return Column(
      children: [
        _buildStatRow(colors, 'Min.', _formatCurrency(min)),
        _buildStatRow(colors, 'Max.', _formatCurrency(max)),
        _buildStatRow(colors, 'Elmúlt 52 hét', '${week52Low.toStringAsFixed(2)} - ${week52High.toStringAsFixed(2)}'),
        _buildStatRow(colors, 'Átlag 1 nap', _formatCurrency(avg1Day)),
        _buildStatRow(colors, 'Átlag 180 nap', _formatCurrency(avg180Day)),
        _buildStatRow(colors, 'Átlag 360 nap', _formatCurrency(avg360Day)),
        _buildStatRow(colors, 'Forgalom (m USD)', _formatCurrency(volumeMillion)),
        _buildStatRow(colors, 'Rel. forg.', '${relVolume}%'),
        _buildStatRow(colors, 'P/E', pe.toStringAsFixed(2)),
        _buildStatRow(colors, 'RSI', rsi.toStringAsFixed(2)),
        _buildStatRow(colors, '1 hó', '${perf1Mo >= 0 ? '+' : ''}${perf1Mo.toStringAsFixed(2)}%'),
        _buildStatRow(colors, '6 hó', '${perf6Mo >= 0 ? '+' : ''}${perf6Mo.toStringAsFixed(2)}%'),
        _buildStatRow(colors, '12 hó', '${perf12Mo >= 0 ? '+' : ''}${perf12Mo.toStringAsFixed(2)}%'),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatRow(AppColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHirekContent(AppColors colors) {
    return FutureBuilder<List<NewsArticle>>(
      future: NewsService.fetchNewsForTicker(widget.ticker),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: colors.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nincs elérhető hír',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          );
        }

        final news = snapshot.data!.take(5).toList();

        return Column(
          children: [
            ...news.map((article) => _buildNewsItem(colors, article)).toList(),
            // "Még több hír" button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to full news page
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      TablerIcons.plus,
                      size: 16,
                      color: colors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Még több hír',
                      style: TextStyle(
                        color: colors.primary,
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
        );
      },
    );
  }

  Widget _buildNewsItem(AppColors colors, NewsArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: colors.surfaceElevated,
              child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                  ? Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          TablerIcons.news,
                          size: 32,
                          color: colors.textSecondary,
                        );
                      },
                    )
                  : Icon(
                      TablerIcons.news,
                      size: 32,
                      color: colors.textSecondary,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.source,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  article.getFormattedDate(),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEszkozokContent(AppColors colors) {
    // Get real data from MockPortfolioData for all accounts
    final stockData = _portfolioData.getStockDetails(
      widget.ticker,
      'Minden számla',
      currency: _currencyState.selectedCurrency,
    );

    // Get accounts list from the stock data
    final accounts = stockData['accounts'] as List;

    // If no accounts have this stock, show empty message
    if (accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Nincs pozíció ebben a részvényben',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return Column(
      children: [
        // Table header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border(
              top: BorderSide(width: 1, color: colors.border),
              bottom: BorderSide(width: 1, color: colors.border),
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
                      color: colors.textSecondary,
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
                      color: colors.textSecondary,
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
                      color: colors.textSecondary,
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
                            color: colors.textSecondary,
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
                            color: colors.textSecondary,
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
        // Account rows with padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: accounts.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final accountData = entry.value;
              final stock = accountData['stock'] as Stock;
              final accountValue = accountData['valueInCurrency'];
              final accountProfit = accountData['profitInCurrency'];
              final accountProfitPercent = stock.profitPercent;
              final isLast = index == accounts.length - 1;

              return _buildAccountRow(
                colors: colors,
                accountName: accountData['accountName'],
                quantity: stock.quantity,
                avgPrice: stock.avgPrice,
                currency: stock.currency,
                value: accountValue,
                profitPercent: accountProfitPercent,
                profit: accountProfit,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountRow({
    required AppColors colors,
    required String accountName,
    required int quantity,
    required double avgPrice,
    required String currency,
    required double value,
    required double profitPercent,
    required double profit,
    bool isLast = false,
  }) {
    final isPositive = profit >= 0;
    final profitColor = isPositive ? colors.success : colors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: colors.border,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                accountName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_formatCurrency(value)} ${_currencyState.selectedCurrency}',
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
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quantity}db @ ${_formatCurrency(avgPrice)} ${_currencyState.selectedCurrency}',
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
                    width: 66,
                    child: Text(
                      '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: profitColor,
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
                      _formatCurrency(profit.abs()),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: profitColor,
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
  }

  String _formatCurrency(double value) {
    String valueStr = value.toStringAsFixed(2);
    valueStr = valueStr.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} '
    );
    return valueStr;
  }

  Widget _buildMegbizasokContent(AppColors colors) {
    // Get open orders for this specific stock
    dynamic service = _transactionService;
    List<Order> allOpenOrders = [];
    try {
      allOpenOrders = service.openOrders as List<Order>;
    } catch (e) {
      // Handle error
    }

    // Filter orders for this stock ticker
    final orders = allOpenOrders.where((order) => order.ticker == widget.ticker).toList();

    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Nincs nyitott megbízás',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return Column(
      children: [
        // Table header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border(
              top: BorderSide(width: 1, color: colors.border),
              bottom: BorderSide(width: 1, color: colors.border),
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
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Vétel / Eladás',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Megbízás darab @ ár',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Megbízás érték',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Teljesült darab @ ár',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Teljesült érték',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Számla',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                  Text(
                    'Beadás ideje',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Orders list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: orders.asMap().entries.map<Widget>((entry) {
              final order = entry.value;
              return _buildOrderItem(colors, order);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(AppColors colors, Order order) {
    final isBuy = order.action == OrderAction.buy;
    final formattedOrderValue = _formatCurrency(order.orderedValue);
    final formattedFulfilledValue = _formatCurrency(order.fulfilledValue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to Order Detail Page
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
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Row 1: Stock name and Buy/Sell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.stockName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isBuy ? 'Vétel' : 'Eladás',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isBuy ? colors.success : colors.error,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Row 2: Ordered quantity @ price and Ordered value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(TablerIcons.file_text, size: 20, color: colors.textSecondary),
                  const SizedBox(width: 2),
                  Text(
                    '${order.orderedQuantity} db @ ${order.isMarketOrder ? "Piaci" : order.limitPrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                '$formattedOrderValue USD',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Row 3: Fulfilled quantity @ price and Fulfilled value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(TablerIcons.circle_check, size: 20, color: colors.textSecondary),
                  const SizedBox(width: 2),
                  Text(
                    '${order.fulfilledQuantity} db @ ${order.fulfilledQuantity > 0 ? order.limitPrice!.toStringAsFixed(2) : "0,00"}',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                '$formattedFulfilledValue',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Row 4: Account name and Order time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.accountName,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _formatOrderTime(order.createdAt),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatOrderTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return 'Ma ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}.';
    }
  }

  Widget _buildArszintfigyeContent(AppColors colors) {
    return Text(
      'Árszintfigyelés tartalma - később implementáljuk',
      style: TextStyle(
        color: colors.textSecondary,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildAjanlatiKonyvContent(AppColors colors) {
    return Text(
      'Ajánlati könyv tartalma - később implementáljuk',
      style: TextStyle(
        color: colors.textSecondary,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildNapiKotesContent(AppColors colors) {
    return Text(
      'Napi kötés lista tartalma - később implementáljuk',
      style: TextStyle(
        color: colors.textSecondary,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildTermekleirasContent(AppColors colors) {
    return Text(
      'Termékleiras tartalma - később implementáljuk',
      style: TextStyle(
        color: colors.textSecondary,
        fontFamily: 'Inter',
      ),
    );
  }

  // Build customize button
  Widget _buildCustomizeButton(AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: OutlinedButton(
        onPressed: () async {
          // Navigate to customize page
          final result = await Navigator.push<List<ProductWidget>>(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPageCustomize(
                widgets: _widgetOrder,
              ),
            ),
          );

          // Update widget order if user saved changes
          if (result != null) {
            setState(() {
              _widgetOrder = result;
            });
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(TablerIcons.eye, size: 20, color: colors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Oldal testreszabása',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: colors.textSecondary,
                height: 1.43,
                letterSpacing: 0.10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build bottom buy/sell buttons
  Widget _buildBottomButtons(AppColors colors, MarketStock stock) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vétel button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockBuyPage(
                            stockName: widget.stockName,
                            ticker: widget.ticker,
                            currentPrice: stock.currentPrice,
                            currency: stock.currency,
                            initialTradeType: 'Vétel',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.buttonSuccess,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.circle_plus, size: 20),
                        const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                // Eladás button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockBuyPage(
                            stockName: widget.stockName,
                            ticker: widget.ticker,
                            currentPrice: stock.currentPrice,
                            currency: stock.currency,
                            initialTradeType: 'Eladás',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.buttonDanger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.circle_minus, size: 20),
                        const SizedBox(width: 8),
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
              ],
            ),
          ),
          // Bottom safe area spacer
          Container(
            width: double.infinity,
            height: 24,
            color: colors.surface,
          ),
        ],
      ),
    );
  }
}
