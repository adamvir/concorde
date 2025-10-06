import 'package:flutter/material.dart';

class PhoneNumberBottomSheet extends StatefulWidget {
  const PhoneNumberBottomSheet({super.key});

  @override
  _PhoneNumberBottomSheetState createState() => _PhoneNumberBottomSheetState();
}

class _PhoneNumberBottomSheetState extends State<PhoneNumberBottomSheet> {
  String selectedPhoneNumber = '0670****398';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 12,
              left: 24,
              right: 12,
              bottom: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Telefonszám hitelesíthez',
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.27,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Color(0xFF1D293D)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Phone number list
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First phone number (selected)
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedPhoneNumber = '0670****398';
                    });
                    Navigator.pop(context, '0670****398');
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: ShapeDecoration(
                      color: selectedPhoneNumber == '0670****398'
                          ? const Color(0xFFFEF3C6)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          '0670****398',
                          style: TextStyle(
                            color: const Color(0xFF1D293D),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: selectedPhoneNumber == '0670****398'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Second phone number
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedPhoneNumber = '0670****123';
                    });
                    Navigator.pop(context, '0670****123');
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: ShapeDecoration(
                      color: selectedPhoneNumber == '0670****123'
                          ? const Color(0xFFFEF3C6)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          '0670****123',
                          style: TextStyle(
                            color: const Color(0xFF45556C),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: selectedPhoneNumber == '0670****123'
                                ? FontWeight.w600
                                : FontWeight.w500,
                            height: 1.43,
                            letterSpacing: 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
Future<String?> showPhoneNumberBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => PhoneNumberBottomSheet(),
  );
}
