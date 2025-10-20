import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'portfolio_page.dart';
import 'kedvencek_page.dart';
import 'news_page.dart';
import 'tozsde_page.dart';
import 'settings_page.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialPage;

  const MainNavigation({super.key, this.initialPage = 0});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  late PageController _pageController;
  final app_theme.ThemeState _themeState = app_theme.ThemeState();

  // Az egyes oldalak listája - Note: removed const to allow state updates
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPage;
    _pageController = PageController(initialPage: _selectedIndex);
    _themeState.addListener(_onThemeChanged);
    _pages = [
      PortfolioContent(),
      KedvencekContent(),
      NewsContent(),
      TozsdeContent(),
      const SettingsPage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(colors),
    );
  }

  Widget _buildBottomNavBar(AppColors colors) {
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
                _buildBottomNavItem(0, TablerIcons.chart_pie, 'Portfólió', colors),
                _buildBottomNavItem(1, TablerIcons.heart, 'Kedvencek', colors),
                _buildBottomNavItem(2, TablerIcons.news, 'Hírek', colors),
                _buildBottomNavItem(3, TablerIcons.trending_up, 'Tőzsde', colors),
                _buildBottomNavItem(4, TablerIcons.dots, 'Több', colors),
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

  Widget _buildBottomNavItem(int index, IconData icon, String label, AppColors colors) {
    bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Haptic feedback for iOS
          HapticFeedback.selectionClick();

          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
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
              const SizedBox(height: 4),
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

// Placeholder widget a még nem elkészült oldalakhoz
class PlaceholderPage extends StatefulWidget {
  final String title;

  const PlaceholderPage({required this.title, super.key});

  @override
  State<PlaceholderPage> createState() => _PlaceholderPageState();
}

class _PlaceholderPageState extends State<PlaceholderPage> {
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: colors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ez az oldal még fejlesztés alatt áll',
            style: TextStyle(
              fontSize: 16,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
