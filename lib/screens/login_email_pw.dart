import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cc_new/screens/login_hiteles_sms.dart';

class LoginEmailPw extends StatefulWidget {
  const LoginEmailPw({super.key});

  @override
  _LoginEmailPwState createState() => _LoginEmailPwState();
}

class _LoginEmailPwState extends State<LoginEmailPw> {
  final _userCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background circle decoration (bottom left)
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
                    color: const Color(0xFFFD9A00),
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
                      decoration: InputDecoration(
                        labelText: 'Ügyfélkód',
                        labelStyle: TextStyle(
                          color: const Color(0xFF45556C),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFFCAD5E2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 2,
                            color: const Color(0xFF1D293D),
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
                      decoration: InputDecoration(
                        labelText: 'Jelszó',
                        labelStyle: TextStyle(
                          color: const Color(0xFF45556C),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFFCAD5E2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            width: 2,
                            color: const Color(0xFF1D293D),
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
                            color: const Color(0xFF45556C),
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
                          backgroundColor: const Color(0xFF1D293D),
                          foregroundColor: Colors.white,
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
                          foregroundColor: const Color(0xFF45556C),
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFE2E8F0),
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
                            color: const Color(0xFF45556C),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Elfelejtette a jelszavát?',
                            style: TextStyle(
                              color: const Color(0xFF45556C),
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
    _userCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
