import 'package:flutter/material.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;
  final Map<String, dynamic>? initialFilters;

  const ProductFilterBottomSheet({
    super.key,
    required this.onApply,
    this.initialFilters,
  });

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  final app_theme.ThemeState _themeState = app_theme.ThemeState();

  // Controllers for text inputs
  final TextEditingController _priceMinController = TextEditingController();
  final TextEditingController _priceMaxController = TextEditingController();
  final TextEditingController _dividendMinController = TextEditingController();
  final TextEditingController _dividendMaxController = TextEditingController();
  final TextEditingController _marketCapMinController = TextEditingController();
  final TextEditingController _marketCapMaxController = TextEditingController();
  final TextEditingController _rsiMinController = TextEditingController();
  final TextEditingController _rsiMaxController = TextEditingController();

  // Filter state
  String _sortBy = 'Népszerűség szerint';
  Set<String> _selectedExchanges = {};
  String _priceChangeTimeframe = 'Időtáv';
  bool _isExchangeSectionExpanded = false;
  bool _isPriceChangeSectionExpanded = false;
  bool _isDividendSectionExpanded = false;
  bool _isMarketCapSectionExpanded = false;
  bool _isRsiSectionExpanded = false;

  // Available options
  final List<String> _sortOptions = [
    'Népszerűség szerint',
    'Név szerint',
    'Ár szerint (növekvő)',
    'Ár szerint (csökkenő)',
  ];

  final List<String> _exchanges = [
    'BÉT',
    'NASDAQ',
    'Tokyo',
    'Shanghai',
    'London',
  ];

  final List<String> _timeframes = [
    '1 nap',
    '1 hét',
    '1 hónap',
    '3 hónap',
    '1 év',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;
      _sortBy = filters['sortBy'] ?? _sortBy;
      _selectedExchanges = Set<String>.from(filters['exchanges'] ?? []);
      _priceChangeTimeframe = filters['priceChangeTimeframe'] ?? _priceChangeTimeframe;
      _priceMinController.text = filters['priceMin']?.toString() ?? '';
      _priceMaxController.text = filters['priceMax']?.toString() ?? '';
      _dividendMinController.text = filters['dividendMin']?.toString() ?? '';
      _dividendMaxController.text = filters['dividendMax']?.toString() ?? '';
      _marketCapMinController.text = filters['marketCapMin']?.toString() ?? '';
      _marketCapMaxController.text = filters['marketCapMax']?.toString() ?? '';
      _rsiMinController.text = filters['rsiMin']?.toString() ?? '';
      _rsiMaxController.text = filters['rsiMax']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _dividendMinController.dispose();
    _dividendMaxController.dispose();
    _marketCapMinController.dispose();
    _marketCapMaxController.dispose();
    _rsiMinController.dispose();
    _rsiMaxController.dispose();
    super.dispose();
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedExchanges.isNotEmpty) count++;
    if (_priceChangeTimeframe != 'Időtáv') count++;
    if (_priceMinController.text.isNotEmpty || _priceMaxController.text.isNotEmpty) count++;
    if (_dividendMinController.text.isNotEmpty || _dividendMaxController.text.isNotEmpty) count++;
    if (_marketCapMinController.text.isNotEmpty || _marketCapMaxController.text.isNotEmpty) count++;
    if (_rsiMinController.text.isNotEmpty || _rsiMaxController.text.isNotEmpty) count++;
    return count;
  }

  Map<String, dynamic> _buildFilters() {
    return {
      'sortBy': _sortBy,
      'exchanges': _selectedExchanges.toList(),
      'priceChangeTimeframe': _priceChangeTimeframe,
      'priceMin': _priceMinController.text.isNotEmpty ? double.tryParse(_priceMinController.text) : null,
      'priceMax': _priceMaxController.text.isNotEmpty ? double.tryParse(_priceMaxController.text) : null,
      'dividendMin': _dividendMinController.text.isNotEmpty ? double.tryParse(_dividendMinController.text) : null,
      'dividendMax': _dividendMaxController.text.isNotEmpty ? double.tryParse(_dividendMaxController.text) : null,
      'marketCapMin': _marketCapMinController.text.isNotEmpty ? double.tryParse(_marketCapMinController.text) : null,
      'marketCapMax': _marketCapMaxController.text.isNotEmpty ? double.tryParse(_marketCapMaxController.text) : null,
      'rsiMin': _rsiMinController.text.isNotEmpty ? double.tryParse(_rsiMinController.text) : null,
      'rsiMax': _rsiMaxController.text.isNotEmpty ? double.tryParse(_rsiMaxController.text) : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(colors),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildDropdownField(
                          colors: colors,
                          label: 'Rendezés',
                          value: _sortBy,
                          items: _sortOptions,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _sortBy = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Search field (placeholder)
                        _buildSearchField(colors),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Stock Exchange Section
                  _buildFilterSection(
                    colors: colors,
                    title: 'Tőzsde',
                    isExpanded: _isExchangeSectionExpanded,
                    hasActiveFilter: _selectedExchanges.isNotEmpty,
                    onToggle: () {
                      setState(() {
                        _isExchangeSectionExpanded = !_isExchangeSectionExpanded;
                      });
                    },
                    child: _buildExchangeFilter(colors),
                  ),

                  // Price Change Section
                  _buildFilterSection(
                    colors: colors,
                    title: 'Árváltozás',
                    isExpanded: _isPriceChangeSectionExpanded,
                    hasActiveFilter: _priceChangeTimeframe != 'Időtáv' ||
                                     _priceMinController.text.isNotEmpty ||
                                     _priceMaxController.text.isNotEmpty,
                    onToggle: () {
                      setState(() {
                        _isPriceChangeSectionExpanded = !_isPriceChangeSectionExpanded;
                      });
                    },
                    child: _buildPriceChangeFilter(colors),
                  ),

                  // Dividend Section
                  _buildFilterSection(
                    colors: colors,
                    title: 'Osztalék',
                    isExpanded: _isDividendSectionExpanded,
                    hasActiveFilter: _dividendMinController.text.isNotEmpty ||
                                     _dividendMaxController.text.isNotEmpty,
                    onToggle: () {
                      setState(() {
                        _isDividendSectionExpanded = !_isDividendSectionExpanded;
                      });
                    },
                    child: _buildDividendFilter(colors),
                  ),

                  // Market Cap Section
                  _buildFilterSection(
                    colors: colors,
                    title: 'Piaci érték (millió USD)',
                    isExpanded: _isMarketCapSectionExpanded,
                    hasActiveFilter: _marketCapMinController.text.isNotEmpty ||
                                     _marketCapMaxController.text.isNotEmpty,
                    onToggle: () {
                      setState(() {
                        _isMarketCapSectionExpanded = !_isMarketCapSectionExpanded;
                      });
                    },
                    child: _buildMarketCapFilter(colors),
                  ),

                  // RSI Section
                  _buildFilterSection(
                    colors: colors,
                    title: 'RSI',
                    isExpanded: _isRsiSectionExpanded,
                    hasActiveFilter: _rsiMinController.text.isNotEmpty ||
                                     _rsiMaxController.text.isNotEmpty,
                    onToggle: () {
                      setState(() {
                        _isRsiSectionExpanded = !_isRsiSectionExpanded;
                      });
                    },
                    child: _buildRsiFilter(colors),
                  ),

                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Apply Button
          _buildApplyButton(colors),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    final filterCount = _getActiveFilterCount();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Empty space for symmetry
          const SizedBox(width: 48),

          // Title
          Expanded(
            child: Center(
              child: Text(
                'Termék szűrő${filterCount > 0 ? ' ($filterCount)' : ''}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Close button
          IconButton(
            icon: Icon(Icons.close, color: colors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required AppColors colors,
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      dropdownColor: colors.surface,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
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
              padding: const EdgeInsets.symmetric(horizontal: 4),
              color: colors.surface,
              child: Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppColors colors) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
              decoration: InputDecoration(
                hintText: 'Keresés',
                hintStyle: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required AppColors colors,
    required String title,
    required bool isExpanded,
    required bool hasActiveFilter,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (hasActiveFilter)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA1A1A),
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: colors.textPrimary,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: child,
          ),
      ],
    );
  }

  Widget _buildExchangeFilter(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _exchanges.map((exchange) {
              final isSelected = _selectedExchanges.contains(exchange);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedExchanges.remove(exchange);
                    } else {
                      _selectedExchanges.add(exchange);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: isSelected ? colors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        exchange,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedExchanges.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _selectedExchanges.join(', '),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceChangeFilter(AppColors colors) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildDropdownField(
          colors: colors,
          label: 'Időtáv',
          value: _priceChangeTimeframe,
          items: ['Időtáv', ..._timeframes],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _priceChangeTimeframe = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                colors: colors,
                label: 'Min',
                controller: _priceMinController,
                suffix: '%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                colors: colors,
                label: 'Max',
                controller: _priceMaxController,
                suffix: '%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDividendFilter(AppColors colors) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextFieldWithClear(
                colors: colors,
                label: 'Min',
                controller: _dividendMinController,
                suffix: '%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFieldWithClear(
                colors: colors,
                label: 'Max',
                controller: _dividendMaxController,
                suffix: '%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketCapFilter(AppColors colors) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                colors: colors,
                label: 'Min',
                controller: _marketCapMinController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                colors: colors,
                label: 'Max',
                controller: _marketCapMaxController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRsiFilter(AppColors colors) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                colors: colors,
                label: 'Min',
                controller: _rsiMinController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                colors: colors,
                label: 'Max',
                controller: _rsiMaxController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required AppColors colors,
    required String label,
    required TextEditingController controller,
    String? suffix,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Center(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixText: suffix,
                  suffixStyle: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              color: colors.surface,
              child: Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithClear({
    required AppColors colors,
    required String label,
    required TextEditingController controller,
    String? suffix,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixText: suffix,
                      suffixStyle: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: colors.textSecondary),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              color: colors.surface,
              child: Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              final filters = _buildFilters();
              widget.onApply(filters);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.buttonPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Mutasd (1092)',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
