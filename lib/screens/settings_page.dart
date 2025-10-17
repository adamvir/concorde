import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'display_settings_page.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

// Settings Page - "Több" tab content
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            _buildHeader(context, colors),

            // Settings list
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSettingsItem(
                      colors: colors,
                      title: 'Megjelenítés',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DisplaySettingsPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      colors: colors,
                      title: 'PIN-kód beállítása',
                      onTap: () {
                        // TODO: Navigate to PIN setup
                      },
                    ),
                    _buildSettingsItem(
                      colors: colors,
                      title: 'Biometrikus azonosítás',
                      onTap: () {
                        // TODO: Navigate to biometric settings
                      },
                    ),
                    _buildSettingsItem(
                      colors: colors,
                      title: 'Árszintfigyelés',
                      onTap: () {
                        // TODO: Navigate to price alerts
                      },
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

  // Build header with logo, title, search and notification icons
  Widget _buildHeader(BuildContext context, AppColors colors) {
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
          // Concorde Logo
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: SvgPicture.asset(
              'lib/assets/images/concorde.svg',
              width: 40,
              height: 40,
            ),
          ),
          // Title
          Expanded(
            child: Text(
              'Beállítások',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.27,
              ),
            ),
          ),
          // Search icon
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(TablerIcons.search, size: 24, color: colors.textSecondary),
              onPressed: () {
                // TODO: Show search
              },
            ),
          ),
          // Notification icon
          SizedBox(
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

  // Build settings item row
  Widget _buildSettingsItem({
    required AppColors colors,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ),
              // Right arrow icon
              Icon(
                TablerIcons.chevron_right,
                size: 24,
                color: colors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
