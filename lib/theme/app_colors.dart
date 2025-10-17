import 'package:flutter/material.dart';

// App Colors - Dynamic color palette that changes based on theme
class AppColors {
  final bool isDark;

  AppColors({required this.isDark});

  // Background colors
  Color get background => isDark ? const Color(0xFF0F1419) : Colors.white;
  Color get surface => isDark ? const Color(0xFF1A1F26) : Colors.white;
  Color get surfaceElevated => isDark ? const Color(0xFF252A31) : const Color(0xFFF8FAFC);

  // Text colors
  Color get textPrimary => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1D293D);
  Color get textSecondary => isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B);
  Color get textTertiary => isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8);

  // Border colors
  Color get border => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get divider => isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

  // Primary colors (brand - don't change with theme)
  Color get primary => const Color(0xFFE17100);
  Color get primaryLight => const Color(0xFFFF9500);
  Color get accent => const Color(0xFFFEF3C6);
  Color get accentDark => const Color(0xFF3D3420);

  // Semantic colors
  Color get success => isDark ? const Color(0xFF10B981) : const Color(0xFF009966);
  Color get error => const Color(0xFFEC003F);
  Color get warning => const Color(0xFFFF9500);
  Color get info => const Color(0xFF3B82F6);

  // Chart colors
  Color get chartLine => const Color(0xFFFF9500);
  Color get chartAreaStart => const Color(0xFFFF9500).withValues(alpha: 0.3);
  Color get chartAreaEnd => const Color(0xFFFF9500).withValues(alpha: 0.0);
  Color get chartGrid => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get chartLabel => isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8);

  // Status bar colors
  Color get statusBarBackground => isDark ? const Color(0xFF0F1419) : Colors.white;

  // Tab bar colors
  Color get tabBarBackground => isDark ? const Color(0xFF1A1F26) : Colors.white;
  Color get tabBarSelected => isDark ? const Color(0xFF3D3420) : const Color(0xFFFEF3C6);
  Color get tabBarIconSelected => const Color(0xFFFF9500);
  Color get tabBarIconUnselected => isDark ? const Color(0xFF94A3B8) : const Color(0xFF45556C);
  Color get tabBarLabelSelected => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1D293D);
  Color get tabBarLabelUnselected => isDark ? const Color(0xFF94A3B8) : const Color(0xFF45556C);

  // Card colors
  Color get cardBackground => isDark ? const Color(0xFF1A1F26) : Colors.white;
  Color get cardBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  // Button colors
  Color get buttonPrimary => const Color(0xFFE17100);
  Color get buttonSecondary => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get buttonDanger => const Color(0xFFEC003F);
  Color get buttonSuccess => isDark ? const Color(0xFF10B981) : const Color(0xFF009966);

  // Input colors
  Color get inputBackground => isDark ? const Color(0xFF1A1F26) : Colors.white;
  Color get inputBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get inputFocusBorder => const Color(0xFFFF9500);

  // Badge colors
  Color get badgeBackground => isDark ? const Color(0xFF3D3420) : const Color(0xFFFEF3C6);
  Color get badgeText => isDark ? const Color(0xFFFEF3C6) : const Color(0xFF1D293D);

  // Delayed data banner
  Color get delayedBannerBackground => isDark ? const Color(0xFF374151) : const Color(0xFF5B6B8C);
  Color get delayedBannerText => Colors.white;

  // Pre-market badge
  Color get preMarketBadge => const Color(0xFFE17100);
  Color get delayBadge => const Color(0xFFEC003F);
}
