import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:cc_new/screens/biometric_permission_page.dart';

class PinSetupPage extends StatefulWidget {
  final String? initialPin; // Pass the first PIN for confirmation

  const PinSetupPage({super.key, this.initialPin});

  @override
  _PinSetupPageState createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> with SingleTickerProviderStateMixin {
  List<String> _pinDigits = ['', '', '', '', '', ''];
  int _currentIndex = 0;
  bool _hasError = false;
  String _errorMessage = '';
  AnimationController? _cursorController;

  bool get _isConfirmation => widget.initialPin != null;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController?.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_currentIndex < 6) {
      setState(() {
        _pinDigits[_currentIndex] = number;
        _currentIndex++;
      });
    }
  }

  void _onBackspace() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pinDigits[_currentIndex] = '';
      });
    }
  }

  void _onContinue() {
    if (_currentIndex == 6) {
      String pin = _pinDigits.join();

      if (_isConfirmation) {
        // Confirming PIN - check if it matches
        if (pin == widget.initialPin) {
          print('PIN confirmed successfully: $pin');
          // Navigate to biometric permission page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BiometricPermissionPage()),
          );
        } else {
          // PINs don't match
          setState(() {
            _hasError = true;
            _errorMessage = 'A PIN kódok nem egyeznek!';
            _pinDigits = ['', '', '', '', '', ''];
            _currentIndex = 0;
          });
        }
      } else {
        // First PIN entry - navigate to confirmation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinSetupPage(initialPin: pin),
          ),
        );
      }
    }
  }

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
                    top: 9,
                    child: Text(
                      _isConfirmation ? 'PIN kód megerősítése' : 'PIN kód beállítása',
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
            SizedBox(height: 14),
            // Instruction text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _isConfirmation
                    ? 'Írja be újra a PIN kódot a megerősítéshez.'
                    : 'Adjon meg egy 6 számjegyű PIN kódot!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF1D293D),
                  fontSize: 17,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: 0.10,
                ),
              ),
            ),
            SizedBox(height: 16),
            // PIN input boxes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: _currentIndex == index ? 3 : 1,
                          color: _currentIndex == index
                              ? const Color(0xFF1D293D)
                              : const Color(0xFFCAD5E2),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: _pinDigits[index].isEmpty && _currentIndex == index && _cursorController != null
                            ? FadeTransition(
                                opacity: _cursorController!,
                                child: Container(
                                  width: 2,
                                  height: 24,
                                  color: const Color(0xFF1D293D),
                                ),
                              )
                            : Text(
                                _pinDigits[index].isEmpty ? '' : '•',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: const Color(0xFF1D293D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Error message
            if (_hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF93000A),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    letterSpacing: 0.10,
                  ),
                ),
              ),
            Spacer(),
            // Continue button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: _currentIndex == 6 ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D293D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1D293D).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Tovább',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.10,
                    ),
                  ),
                ),
              ),
            ),
            // Number pad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  // Row 1: 1, 2, 3
                  _buildNumberRow(['1', '2', '3']),
                  SizedBox(height: 12),
                  // Row 2: 4, 5, 6
                  _buildNumberRow(['4', '5', '6']),
                  SizedBox(height: 12),
                  // Row 3: 7, 8, 9
                  _buildNumberRow(['7', '8', '9']),
                  SizedBox(height: 12),
                  // Row 4: empty, 0, backspace
                  Row(
                    children: [
                      Expanded(child: SizedBox()),
                      Expanded(
                        child: _buildNumberButton('0'),
                      ),
                      Expanded(
                        child: _buildBackspaceButton(),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildNumberButton(number),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            number,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF1D293D),
              fontSize: 21,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 46,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: const Color(0xFF1D293D),
            size: 24,
          ),
        ),
      ),
    );
  }
}
