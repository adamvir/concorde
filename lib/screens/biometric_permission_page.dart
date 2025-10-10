import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:cc_new/screens/main_navigation.dart';

class BiometricPermissionPage extends StatelessWidget {
  const BiometricPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Title
                  Positioned(
                    left: 56,
                    top: 18,
                    child: Text(
                      'Biometrikus azonosítás',
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Question text
                    Text(
                      'Engedélyezi a biometrikus azonosítást?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                    ),
                    SizedBox(height: 32),
                    // Biometric icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Fingerprint icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.fingerprint,
                            size: 56,
                            color: const Color(0xFF1D293D),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Face ID icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.face,
                            size: 56,
                            color: const Color(0xFF1D293D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    // Description text
                    Text(
                      'Ha engedélyezi, akkor bejelentkezhet, és jóváhagyhat tranzakciókat ujjlenyomat vagy arcfelismerés segítségével.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                    ),
                    SizedBox(height: 24),
                    // Settings note
                    Text(
                      'A későbbiekben meg tudja ezt változtatni a Beállításokban.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Buttons at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Enable button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => _handleEnableBiometric(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D293D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Engedélyezem',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => _handleSkipBiometric(context),
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
                      child: Text(
                        'Most nem engedélyezem',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEnableBiometric(BuildContext context) {
    // Save user preference and navigate to main navigation
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainNavigation()),
      (route) => false,
    );
  }

  void _handleSkipBiometric(BuildContext context) {
    // Navigate to main navigation without biometric
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainNavigation()),
      (route) => false,
    );
  }
}
