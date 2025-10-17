import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:cc_new/screens/phone_number_bottom_sheet.dart';
import 'package:cc_new/screens/pin_setup_page.dart';
import '../state/theme_state.dart' as app_theme;
import '../theme/app_colors.dart';

class LoginHitelesTSDefault extends StatefulWidget {
  const LoginHitelesTSDefault({super.key});

  @override
  _LoginHitelesTSDefaultState createState() => _LoginHitelesTSDefaultState();
}

class _LoginHitelesTSDefaultState extends State<LoginHitelesTSDefault> {
  final _smsCodeController = TextEditingController();
  int _countdown = 12;
  Timer? _timer;
  bool _hasError = false;
  String _errorMessage = '';
  final app_theme.ThemeState _themeState = app_theme.ThemeState();

  @override
  void initState() {
    super.initState();
    _themeState.addListener(_onThemeChanged);
    _startCountdown();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background circle decoration (bottom left) - brand color
          Positioned(
            left: -300,
            bottom: -515,
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
                    SizedBox(height: 8),
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(TablerIcons.arrow_left, color: colors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hitelesítés SMS-sel',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    // SMS instruction text
                    Text(
                      'Adja meg az 0670****398 számra SMS-ben kapott egyszeri jelszót! ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                    ),
                    SizedBox(height: 16),
                    // SMS code input field
                    TextField(
                      controller: _smsCodeController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: (value) {
                        // Clear error when user types
                        if (_hasError) {
                          setState(() {
                            _hasError = false;
                            _errorMessage = '';
                          });
                        }
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        suffixIcon: _hasError
                            ? Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  TablerIcons.alert_circle_filled,
                                  color: colors.error,
                                  size: 24,
                                ),
                              )
                            : null,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 1,
                            color: _hasError
                                ? colors.error
                                : colors.inputBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: _hasError ? 2 : 3,
                            color: _hasError
                                ? colors.error
                                : colors.textPrimary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 1,
                            color: colors.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 2,
                            color: colors.error,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 4,
                        color: _hasError ? colors.error : colors.textPrimary,
                      ),
                    ),
                    if (_hasError) ...[
                      SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                    // Continue button
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
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
                              'Tovább',
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
                    // Resend code button (disabled with countdown)
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: _countdown == 0 ? _handleResendCode : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surfaceElevated,
                          foregroundColor: colors.textPrimary,
                          disabledBackgroundColor: colors.surfaceElevated,
                          disabledForegroundColor: colors.textPrimary.withValues(alpha: 0.38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _countdown > 0
                              ? 'Új kód küldése (0:${_countdown.toString().padLeft(2, '0')})'
                              : 'Új kód küldése',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Phone call authentication button
                    SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: _handlePhoneAuthentication,
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
                            Icon(TablerIcons.phone_call, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Hitelesítés telefonhívással',
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
                    // Lost access link
                    TextButton(
                      onPressed: _handleLostAccess,
                      child: Text(
                        'Elvesztettem a hozzáférésem a számhoz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                    // Send to another number link
                    TextButton(
                      onPressed: _handleSendToOtherNumber,
                      child: Text(
                        'Kód küldése másik számra',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          letterSpacing: 0.10,
                        ),
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

  void _handleContinue() {
    print('SMS Code: ${_smsCodeController.text}');

    // Simulate SMS code verification
    if (_smsCodeController.text.length != 6) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Ellenőrizze, hogy jól írta-e be a kódot!';
      });
      return;
    }

    // Simulate incorrect code (for demo purposes)
    // In production, you would call your backend API here
    if (_smsCodeController.text != '123456') {
      setState(() {
        _hasError = true;
        _errorMessage = 'Ellenőrizze, hogy jól írta-e be a kódot!';
      });
      return;
    }

    // Code is correct - proceed to PIN setup screen
    print('SMS verification successful!');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PinSetupPage()),
    );
  }

  void _handleResendCode() {
    setState(() {
      _countdown = 12;
      _hasError = false;
      _errorMessage = '';
      _smsCodeController.clear();
    });
    _startCountdown();
    print('Resending SMS code');
    // Implement resend SMS logic here
  }

  void _handlePhoneAuthentication() async {
    print('Phone call authentication requested');

    // Show bottom sheet to select phone number
    final selectedNumber = await showPhoneNumberBottomSheet(context);

    if (selectedNumber != null) {
      print('Selected phone number: $selectedNumber');
      // Implement phone call authentication with selected number
    }
  }

  void _handleLostAccess() {
    print('Lost access to number');
    // Navigate to recovery screen
  }

  void _handleSendToOtherNumber() {
    print('Send to another number');
    // Navigate to alternative number screen
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    _timer?.cancel();
    _smsCodeController.dispose();
    super.dispose();
  }
}
