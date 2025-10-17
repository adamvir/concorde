import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

// Display Settings Page - Theme mode selection
class DisplaySettingsPage extends StatefulWidget {
  const DisplaySettingsPage({super.key});

  @override
  State<DisplaySettingsPage> createState() => _DisplaySettingsPageState();
}

class _DisplaySettingsPageState extends State<DisplaySettingsPage> {
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(colors),

            // Theme mode options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildThemeOption(
                      colors: colors,
                      icon: TablerIcons.sun,
                      title: 'Világos',
                      subtitle: 'Világos téma használata',
                      mode: app_theme.ThemeMode.light,
                    ),
                    _buildThemeOption(
                      colors: colors,
                      icon: TablerIcons.moon,
                      title: 'Sötét',
                      subtitle: 'Sötét téma használata',
                      mode: app_theme.ThemeMode.dark,
                    ),
                    _buildThemeOption(
                      colors: colors,
                      icon: TablerIcons.device_mobile,
                      title: 'Automatikus',
                      subtitle: 'Rendszer beállítás követése',
                      mode: app_theme.ThemeMode.system,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build header with back button and title
  Widget _buildHeader(AppColors colors) {
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
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(TablerIcons.arrow_left, size: 24, color: colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Megjelenítés',
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
        ],
      ),
    );
  }

  // Build theme mode option
  Widget _buildThemeOption({
    required AppColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required app_theme.ThemeMode mode,
  }) {
    final isSelected = _themeState.mode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _themeState.setThemeMode(mode);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? colors.accent : colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark
              if (isSelected)
                Icon(
                  TablerIcons.check,
                  size: 24,
                  color: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
