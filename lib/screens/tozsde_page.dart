import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';
import '../widgets/stock_list_selector_bottom_sheet.dart';
import '../widgets/product_filter_bottom_sheet.dart';
import '../widgets/stock_list_menu_bottom_sheet.dart';

class TozsdePage extends StatelessWidget {
  const TozsdePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: app_theme.ThemeState().isDark);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: TozsdeContent(),
      ),
    );
  }
}

class TozsdeContent extends StatefulWidget {
  const TozsdeContent({super.key});

  @override
  State<TozsdeContent> createState() => _TozsdeContentState();
}

class _TozsdeContentState extends State<TozsdeContent> {
  final app_theme.ThemeState _themeState = app_theme.ThemeState();
  String _selectedList = 'Top nyerők';
  Map<String, dynamic> _activeFilters = {};

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
    if (mounted) setState(() {});
  }

  void _showStockListSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StockListSelectorBottomSheet(
        selectedList: _selectedList,
        onListSelected: (listName) {
          setState(() {
            _selectedList = listName;
          });
        },
      ),
    );
  }

  void _showProductFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProductFilterBottomSheet(
          initialFilters: _activeFilters,
          onApply: (filters) {
            setState(() {
              _activeFilters = filters;
            });
          },
        ),
      ),
    );
  }

  void _showListMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StockListMenuBottomSheet(
        onMenuItemSelected: (action) {
          // Handle menu actions
          switch (action) {
            case 'save_filter':
              // TODO: Implement save filter
              break;
            case 'save_filter_as':
              // TODO: Implement save filter as
              break;
            case 'export_products':
              // TODO: Implement export
              break;
            case 'rename_view':
              // TODO: Implement rename view
              break;
            case 'delete_view':
              // TODO: Implement delete view
              break;
            case 'reset':
              setState(() {
                _activeFilters = {};
                _selectedList = 'Top nyerők';
              });
              break;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: colors.background),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Stack(
              children: [
                // Logo
                Container(
                  width: 48,
                  height: 48,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 40,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/concorde_logo.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Title
                Positioned(
                  left: 56,
                  top: 18,
                  child: Container(
                    width: 248,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 248,
                          child: Text(
                            'Tőzsde',
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
                  ),
                ),
                // Action icons
                Positioned(
                  right: 4,
                  top: 0,
                  child: Container(
                    height: 48,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Search icon
                        Container(
                          width: 48,
                          height: 48,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // TODO: Open search functionality
                                  },
                                  child: Icon(
                                    TablerIcons.search,
                                    size: 24,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification icon
                        Container(
                          width: 48,
                          height: 48,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 40,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // TODO: Open notifications
                                      },
                                      child: Icon(
                                        TablerIcons.bell,
                                        size: 24,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  // Notification badge
                                  Positioned(
                                    left: 24,
                                    top: 0,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 16, maxWidth: 34),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFBA1A1A),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 8,
                                              child: Text(
                                                '2',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.45,
                                                  letterSpacing: 0.10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stock list selector and filters
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Stock list selector
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: colors.border,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: InkWell(
                              onTap: _showStockListSelector,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 4, left: 16, bottom: 4),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 164,
                                                    child: Text(
                                                      'Top nyerők',
                                                      style: TextStyle(
                                                        color: colors.textPrimary,
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                        letterSpacing: 0.10,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 48,
                                      height: 48,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            TablerIcons.chevron_down,
                                            size: 24,
                                            color: colors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter icon
                InkWell(
                  onTap: _showProductFilter,
                  child: Container(
                    width: 48,
                    height: 48,
                    child: Icon(
                      TablerIcons.adjustments_horizontal,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Menu icon
                InkWell(
                  onTap: _showListMenu,
                  child: Container(
                    width: 48,
                    height: 48,
                    child: Icon(
                      TablerIcons.dots_vertical,
                      size: 24,
                      color: colors.textSecondary,
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
              color: colors.surfaceElevated,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 151,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  'Termék',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    height: 1.33,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Akt. ár',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                                letterSpacing: 0.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 37,
                          children: [
                            Container(
                              width: 150,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    'Tőzsde',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.33,
                                      letterSpacing: 0.50,
                                    ),
                                  ),
                                  Text(
                                    'Típus',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.33,
                                      letterSpacing: 0.50,
                                    ),
                                  ),
                                  Text(
                                    'FX',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.33,
                                      letterSpacing: 0.50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 66,
                                    child: Text(
                                      ' Vált. %',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: colors.textSecondary,
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
                                      ' Napi vált.',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: colors.textSecondary,
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stock list
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // NVIDIA
                  _buildStockRow(
                    colors: colors,
                    name: 'NVIDIA Corp.',
                    exchange: 'NDAQ',
                    type: 'Részv.',
                    currency: 'USD',
                    price: '147,13',
                    changePercent: '4,43%',
                    changeAmount: '6,24',
                    isPositive: true,
                    hasFavorite: true,
                    onTap: () {
                      // Navigate to product detail page
                      // TODO: Pass stock data
                    },
                  ),
                  // Tesla
                  _buildStockRow(
                    colors: colors,
                    name: 'Tesla Inc.',
                    exchange: 'DAX',
                    type: 'Részv.',
                    currency: 'EUR',
                    price: '415,25',
                    changePercent: '-2,11%',
                    changeAmount: '-8,96',
                    isPositive: false,
                    onTap: () {
                      // Navigate to product detail page
                      // TODO: Pass stock data
                    },
                  ),
                  // Apple
                  _buildStockRow(
                    colors: colors,
                    name: 'Apple Inc.',
                    exchange: 'NDAQ',
                    type: 'Részv.',
                    currency: 'USD',
                    price: '247,04',
                    changePercent: '4,43%',
                    changeAmount: '6,24',
                    isPositive: true,
                    hasBuyBadge: true,
                    onTap: () {
                      // Navigate to product detail page
                      // TODO: Pass stock data
                    },
                  ),
                  // Intel
                  _buildStockRow(
                    colors: colors,
                    name: 'Intel',
                    exchange: 'NDAQ',
                    type: 'Részv.',
                    currency: 'USD',
                    price: '22,99',
                    changePercent: '−4.68%',
                    changeAmount: '-3,11',
                    isPositive: false,
                    onTap: () {
                      // Navigate to product detail page
                      // TODO: Pass stock data
                    },
                  ),
                  // MOL
                  _buildStockRow(
                    colors: colors,
                    name: 'MOL',
                    exchange: 'BUX',
                    type: 'Részv.',
                    currency: 'HUF',
                    price: '2.984',
                    changePercent: '4,05%',
                    changeAmount: '125',
                    isPositive: true,
                    hasFavorite: true,
                    hasSellBadge: true,
                    onTap: () {
                      // Navigate to product detail page
                      // TODO: Pass stock data
                    },
                  ),
                  // OTP
                  _buildStockRow(
                    colors: colors,
                    name: 'OTP',
                    exchange: 'BUX',
                    type: 'Részv.',
                    currency: 'HUF',
                    price: '24.420',
                    changePercent: '-0.33%',
                    changeAmount: '-80',
                    isPositive: false,
                    onTap: () {
                      // Navigate to product detail page
                      // TODO: Pass stock data
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow({
    required AppColors colors,
    required String name,
    required String exchange,
    required String type,
    required String currency,
    required String price,
    required String changePercent,
    required String changeAmount,
    required bool isPositive,
    bool hasFavorite = false,
    bool hasBuyBadge = false,
    bool hasSellBadge = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: colors.border,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 151,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                                letterSpacing: 0.10,
                              ),
                            ),
                            if (hasFavorite)
                              Icon(
                                TablerIcons.star_filled,
                                size: 20,
                                color: const Color(0xFFFF9500),
                              ),
                            if (hasBuyBadge)
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFD0FAE5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Text(
                                            'V',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: colors.success,
                                              fontSize: 11,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              height: 1.45,
                                              letterSpacing: 0.50,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (hasSellBadge)
                              Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Text(
                                            'E',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: const Color(0xFFC70036),
                                              fontSize: 11,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              height: 1.45,
                                              letterSpacing: 0.50,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Text(
                          price,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 37,
                      children: [
                        Container(
                          width: 150,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                exchange,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                              Text(
                                type,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                              Text(
                                currency,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 66,
                                child: Text(
                                  changePercent,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: isPositive ? colors.success : colors.error,
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
                                  changeAmount,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: isPositive ? colors.success : colors.error,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
