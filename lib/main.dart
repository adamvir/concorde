import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';
import 'state/theme_state.dart' as app_theme;
import 'theme/app_colors.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatefulWidget {
  const FigmaToCodeApp({super.key});

  @override
  State<FigmaToCodeApp> createState() => _FigmaToCodeAppState();
}

class _FigmaToCodeAppState extends State<FigmaToCodeApp> {
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: colors.background,
        brightness: _themeState.isDark ? Brightness.dark : Brightness.light,
        // Primary color - dark blue
        primaryColor: colors.textPrimary,
        colorScheme: ColorScheme(
          brightness: _themeState.isDark ? Brightness.dark : Brightness.light,
          primary: colors.primary,
          onPrimary: Colors.white,
          secondary: colors.primaryLight,
          onSecondary: Colors.white,
          error: colors.error,
          onError: Colors.white,
          surface: colors.surface,
          onSurface: colors.textPrimary,
        ),
        // Checkbox theme
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.primary;
            }
            return colors.inputBackground;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
        ),
        // Text theme
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: colors.textPrimary),
          bodyMedium: TextStyle(color: colors.textPrimary),
          bodySmall: TextStyle(color: colors.textSecondary),
        ),
        // Icon theme
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      // TODO: TEMPORARY - Change back to LoginEmailPw() for production
      home: const MainNavigation(initialPage: 0), // 0 = Portfolio tab
      // home: LoginEmailPw(),
    );
  }
}
