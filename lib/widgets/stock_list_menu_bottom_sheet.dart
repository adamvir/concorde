import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

class StockListMenuBottomSheet extends StatefulWidget {
  final Function(String) onMenuItemSelected;

  const StockListMenuBottomSheet({
    super.key,
    required this.onMenuItemSelected,
  });

  @override
  State<StockListMenuBottomSheet> createState() => _StockListMenuBottomSheetState();
}

class _StockListMenuBottomSheetState extends State<StockListMenuBottomSheet> {
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
    if (mounted) {
      setState(() {});
    }
  }

  void _handleMenuItemTap(String action) {
    Navigator.pop(context);
    widget.onMenuItemSelected(action);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildMenuItem(
                  colors: colors,
                  icon: TablerIcons.device_floppy,
                  label: 'Szűrőnézet mentés',
                  action: 'save_filter',
                ),
                _buildMenuItem(
                  colors: colors,
                  icon: TablerIcons.copy,
                  label: 'Szűrőnézet mentés másként',
                  action: 'save_filter_as',
                ),
                _buildMenuItem(
                  colors: colors,
                  icon: TablerIcons.file_export,
                  label: 'Termékek exportálása...',
                  action: 'export_products',
                ),
                _buildMenuItem(
                  colors: colors,
                  icon: TablerIcons.edit,
                  label: 'Nézet átnevezése',
                  action: 'rename_view',
                ),
                _buildMenuItem(
                  colors: colors,
                  icon: TablerIcons.trash,
                  label: 'Nézet törlése',
                  action: 'delete_view',
                ),
                _buildMenuItem(
                  colors: colors,
                  icon: TablerIcons.refresh,
                  label: 'Visszaállítás',
                  action: 'reset',
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required AppColors colors,
    required IconData icon,
    required String label,
    required String action,
  }) {
    return InkWell(
      onTap: () => _handleMenuItemTap(action),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 24,
          bottom: 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: colors.textSecondary,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
