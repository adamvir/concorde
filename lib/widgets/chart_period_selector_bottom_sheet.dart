import 'package:flutter/material.dart';
import '../state/theme_state.dart';
import '../theme/app_colors.dart';

class ChartPeriodSelectorBottomSheet extends StatefulWidget {
  final String currentPeriod;
  final Function(String) onPeriodSelected;

  const ChartPeriodSelectorBottomSheet({
    super.key,
    required this.currentPeriod,
    required this.onPeriodSelected,
  });

  @override
  State<ChartPeriodSelectorBottomSheet> createState() =>
      _ChartPeriodSelectorBottomSheetState();
}

class _ChartPeriodSelectorBottomSheetState
    extends State<ChartPeriodSelectorBottomSheet> {
  late String _selectedPeriod;
  final ThemeState _themeState = ThemeState();

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.currentPeriod;
    _themeState.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  final List<String> _periods = [
    '1 hónap',
    '3 hónap',
    '6 hónap',
    '1 év',
    '3 év',
    '5 év',
    'Max'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Időszak kiválasztása',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: colors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Period list
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _periods.map((period) {
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                    widget.onPeriodSelected(period);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (_themeState.isDark ? colors.accentDark : colors.accent)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontFamily: 'Inter',
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
