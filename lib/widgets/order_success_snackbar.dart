import 'package:flutter/material.dart';

class OrderSuccessSnackbar {
  static void show({
    required BuildContext context,
    required String orderDirection, // 'Vétel' or 'Eladás'
    required String stockName,
    required int quantity,
    required double price,
    required String currency,
  }) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 4),
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      content: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: const Color(0xFF1D293D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x4C000000),
              blurRadius: 3,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 8,
              offset: Offset(0, 4),
              spreadRadius: 3,
            ),
          ],
        ),
        child: Text(
          'Sikeresen beadott megbízás:\n$orderDirection - $stockName - ${quantity}db @ ${price.toStringAsFixed(2)} $currency',
          style: const TextStyle(
            color: Color(0xFFEFF0F7),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.43,
            letterSpacing: 0.10,
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
