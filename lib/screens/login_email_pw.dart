import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cc_new/screens/login_hiteles_sms.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

class LoginEmailPw extends StatefulWidget {
  const LoginEmailPw({super.key});

  @override
  _LoginEmailPwState createState() => _LoginEmailPwState();
}

class _LoginEmailPwState extends State<LoginEmailPw> {
  final _userCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final app_theme.ThemeState _themeState = app_theme.ThemeState();

  @override
  void initState() {
    super.initState();
    _themeState.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background circle decoration (bottom left) - brand color, always visible
          Positioned(
            left: -300,
            bottom: -620,
            child: Container(
              width: 500,
              height: 500,
              decoration: ShapeDecoration(
                shape: OvalBorder(
                  side: BorderSide(
                    width: 60,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24),
                    // Concorde logo
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        'lib/assets/images/concorde_logo.svg',
                        height: 34,
                      ),
                    ),
                    SizedBox(height: 40),
                    // User code field
                    TextField(
                      controller: _userCodeController,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Ügyfélkód',
                        labelStyle: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 1,
                            color: colors.inputBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 2,
                            color: colors.textPrimary,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Jelszó',
                        labelStyle: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 1,
                            color: colors.inputBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 2,
                            color: colors.textPrimary,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? TablerIcons.eye_off
                                : TablerIcons.eye,
                            color: colors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Login button
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.textPrimary,
                          foregroundColor: colors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(TablerIcons.arrow_right, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Tovább a hitelesítésre',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Open account button
                    SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: _handleOpenAccount,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          side: BorderSide(
                            width: 1,
                            color: colors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(TablerIcons.sparkles, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Számlanyitás',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Forgot password
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TablerIcons.lock_question,
                            size: 22,
                            color: colors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Elfelejtette a jelszavát?',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              letterSpacing: 0.10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    print('User Code: ${_userCodeController.text}');
    print('Password: ${_passwordController.text}');

    // Navigate to SMS authentication page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginHitelesTSDefault()),
    );
  }

  void _handleOpenAccount() {
    print('Open account pressed');
    // Navigate to account opening screen
  }

  void _handleForgotPassword() {
    print('Forgot password pressed');
    // Navigate to password recovery screen
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    _userCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
