import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../services/biometric_auth_service.dart';

class OrderAuthPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final bool isEditMode;
  final String orderDirection;

  const OrderAuthPage({
    super.key,
    required this.onSuccess,
    this.isEditMode = false,
    this.orderDirection = 'Vétel',
  });

  @override
  State<OrderAuthPage> createState() => _OrderAuthPageState();
}

class _OrderAuthPageState extends State<OrderAuthPage> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  final List<String> _enteredPin = [];
  final int _pinLength = 6;
  bool _isBiometricAvailable = false;
  String _biometricTypeName = 'Biometrikus azonosítás';
  bool _isAuthenticating = false;

  // Mock stored PIN for demo - in production this would be securely stored
  final String _storedPin = '123456';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricsAvailable();
    final typeName = await _biometricService.getBiometricTypeName();

    setState(() {
      _isBiometricAvailable = isAvailable;
      _biometricTypeName = typeName;
    });

    // Auto-trigger biometric auth if available
    if (_isBiometricAvailable) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool authenticated = await _biometricService.authenticate(
        reason: 'Írd be a PIN kódot a megbízás jóváhagyásához',
      );

      if (authenticated) {
        widget.onSuccess();
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin.add(number);
      });

      if (_enteredPin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
      });
    }
  }

  void _verifyPin() {
    final enteredPinString = _enteredPin.join();

    if (enteredPinString == _storedPin) {
      // PIN correct - proceed with order
      widget.onSuccess();
      Navigator.pop(context, true);
    } else {
      // PIN incorrect - show error and reset
      _showError();
      setState(() {
        _enteredPin.clear();
      });
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hibás PIN kód'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          widget.isEditMode ? 'Megbízás módosításának jóváhagyása' : 'Megbízás jóváhagyása',
          style: const TextStyle(
            color: Color(0xFF1D293D),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Írja be a PIN kódot a megbízás\njóváhagyásához',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1D293D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildPinDots(),
              const SizedBox(height: 40),
              if (_isBiometricAvailable) ...[
                GestureDetector(
                  onTap: _authenticateWithBiometrics,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          TablerIcons.fingerprint,
                          size: 20,
                          color: Color(0xFF1D293D),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _biometricTypeName,
                          style: const TextStyle(
                            color: Color(0xFF1D293D),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Spacer(),
              _buildKeypad(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: isFilled ? Color(0xFF1D293D) : Color(0xFFCAD5E2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: Center(
            child: isFilled
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D293D),
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildKeypadRow(['', '0', 'back']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 56);
        } else if (key == 'back') {
          return _buildBackspaceButton();
        } else {
          return _buildNumberButton(key);
        }
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    // Determine helper text for each number
    String helperText = '';
    switch (number) {
      case '2':
        helperText = 'ABC';
        break;
      case '3':
        helperText = 'DEF';
        break;
      case '4':
        helperText = 'GHI';
        break;
      case '5':
        helperText = 'JKL';
        break;
      case '6':
        helperText = 'MNO';
        break;
      case '7':
        helperText = 'PQRS';
        break;
      case '8':
        helperText = 'TUV';
        break;
      case '9':
        helperText = 'WXYZ';
        break;
    }

    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Color(0xFF1D293D),
                fontSize: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            if (helperText.isNotEmpty)
              Text(
                helperText,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _onBackspacePressed,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 80,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Icon(
          TablerIcons.arrow_right,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
