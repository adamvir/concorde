import 'package:flutter/material.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

class StockListSelectorBottomSheet extends StatefulWidget {
  final String selectedList;
  final Function(String) onListSelected;

  const StockListSelectorBottomSheet({
    super.key,
    required this.selectedList,
    required this.onListSelected,
  });

  @override
  State<StockListSelectorBottomSheet> createState() =>
      _StockListSelectorBottomSheetState();
}

class _StockListSelectorBottomSheetState
    extends State<StockListSelectorBottomSheet> {
  final app_theme.ThemeState _themeState = app_theme.ThemeState();

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
    setState(() {});
  }

  // List of stock list options
  final List<String> _listOptions = [
    'Top nyerők',
    'Top vesztesek',
    'Legnépszerűbb',
    'Magas osztalék',
    'Blue chip',
    'Növekedési',
    'Tech',
    'Értékalapú',
  ];

  void _handleListTap(String listName) {
    widget.onListSelected(listName);
    Navigator.pop(context);
  }

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _listOptions.map((listName) {
                final isSelected = listName == widget.selectedList;
                return _buildListItem(
                  listName: listName,
                  isSelected: isSelected,
                  colors: colors,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String listName,
    required bool isSelected,
    required AppColors colors,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleListTap(listName),
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (_themeState.isDark ? colors.accentDark : colors.accent)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    listName,
                    style: TextStyle(
                      color: isSelected
                          ? (_themeState.isDark
                              ? colors.accent
                              : colors.textPrimary)
                          : (_themeState.isDark
                              ? colors.textSecondary
                              : const Color(0xFF45556C)),
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
      ),
    );
  }
}
