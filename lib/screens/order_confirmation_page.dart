import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'order_auth_page.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String stockName;
  final String ticker;
  final String orderDirection; // 'Vétel' or 'Eladás' or 'Módosítás'
  final String orderType; // 'Limit' or 'Piaci'
  final int quantity;
  final double price;
  final String currency;
  final String accountName;
  final double expectedValue;
  final VoidCallback onConfirm;
  final bool isEditMode;

  const OrderConfirmationPage({
    super.key,
    required this.stockName,
    required this.ticker,
    required this.orderDirection,
    required this.orderType,
    required this.quantity,
    required this.price,
    required this.currency,
    required this.accountName,
    required this.expectedValue,
    required this.onConfirm,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isBuy = orderDirection == 'Vétel';
    bool isSell = orderDirection == 'Eladás';

    // Dynamic colors: Módosítás = dark grey, Vétel = green, Eladás = red
    Color headerColor;
    if (isEditMode) {
      headerColor = const Color(0xFF1D293D); // Dark grey for edit
    } else if (isBuy) {
      headerColor = const Color(0xFF009966); // Green for buy
    } else {
      headerColor = const Color(0xFFEC003F); // Red for sell
    }

    String orderTypeText = orderType == 'Piaci' ? 'piaci áron' : 'limit árfolyamon';
    String headerTitle;
    if (isEditMode) {
      headerTitle = 'Megbízás módosítása';
    } else if (isBuy) {
      headerTitle = 'Vétel $orderTypeText';
    } else {
      headerTitle = 'Eladás $orderTypeText';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Megbízás áttekintése',
          style: TextStyle(
            color: Color(0xFF1D293D),
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with icon
                  _buildHeader(headerColor, headerTitle, isBuy),
                  SizedBox(height: 24),
                  // Order details
                  _buildSection(
                    title: 'Megbízás',
                    children: [
                      _buildDetailRow('Termék', '$stockName\n$ticker'),
                      _buildDetailRow('Megbízás', orderDirection),
                      _buildDetailRow('Típus', '$orderType ár'),
                      _buildDetailRow('Mennyiség', '$quantity db'),
                      _buildDetailRow('Várható nettó érték', '${expectedValue.toStringAsFixed(2)} $currency'),
                      _buildDetailRow('Számla', accountName),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Costs
                  _buildSection(
                    title: 'Költségek',
                    children: [
                      _buildDetailRow('Jutalék', '3,5 $currency'),
                      _buildDetailRow('Deviza váltás\nköltsége', '15,4 $currency'),
                      _buildDetailRow('Szükséges fedezet', '${(expectedValue + 18.9).toStringAsFixed(1)} $currency'),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Advanced settings
                  _buildSection(
                    title: 'Haladó beállítások',
                    children: [
                      _buildDetailRow('Érvényesség', 'Mai napra'),
                      _buildDetailRow('Stop ajánlat', 'Nincs'),
                      _buildDetailRow('Látható mennyiség', 'Nem Iceberg ajánlat'),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Warnings
                  _buildWarnings(isBuy),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(context, isBuy),
    );
  }

  Widget _buildHeader(Color color, String headerTitle, bool isBuy) {
    // Determine icon based on edit mode or buy/sell
    IconData iconData;
    if (isEditMode) {
      iconData = TablerIcons.circle_minus; // Minus icon for edit
    } else if (isBuy) {
      iconData = TablerIcons.circle_plus; // Plus icon for buy
    } else {
      iconData = TablerIcons.circle_minus; // Minus icon for sell
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerTitle,
                  style: const TextStyle(
                    color: Color(0xFF1D293D),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stockName,
                  style: const TextStyle(
                    color: Color(0xFF1D293D),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'kb. ${expectedValue.toStringAsFixed(0)} $currency értékben',
                  style: const TextStyle(
                    color: Color(0xFF45556C),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right side - Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF1D293D),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(TablerIcons.chevron_up, color: Color(0xFF1D293D)),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
              bottom: BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF45556C),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Color(0xFF1D293D),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarnings(bool isBuy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Figyelmeztetések',
            style: TextStyle(
              color: Color(0xFF1D293D),
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          _buildWarningCard(
            'MiFID II figyelmeztetés: a termék komplex',
            Color(0xFFFEF3C6),
          ),
          SizedBox(height: 12),
          _buildWarningCard(
            isBuy
                ? 'A megadott ár legalább 10%-kal magasabb a legutolsó záróártól. (Előző zárő: 124 USD, 2025.02.08, eltérés: +13,57%)'
                : 'A megadott ár legalább 10%-kal alacsonyabb a legutolsó záróártól. (Előző zárő: 124 USD, 2025.02.08, eltérés: -13,57%)',
            Color(0xFFFEF3C6),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(String text, Color backgroundColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            TablerIcons.alert_triangle,
            size: 20,
            color: Color(0xFFF59E0B),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Color(0xFF1D293D),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isBuy) {
    // Dynamic colors: Módosítás = dark grey, Vétel = green, Eladás = red
    Color buttonColor;
    if (isEditMode) {
      buttonColor = const Color(0xFF1D293D); // Dark grey for edit
    } else if (isBuy) {
      buttonColor = const Color(0xFF009966); // Green for buy
    } else {
      buttonColor = const Color(0xFFEC003F); // Red for sell
    }

    String buttonText = isEditMode
        ? 'Módosítás jóváhagyása'
        : (isBuy ? 'Vétel jóváhagyása' : 'Eladás jóváhagyása');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            // Navigate to authentication page
            final bool? authenticated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => OrderAuthPage(
                  onSuccess: () {
                    // Execute the transaction
                    onConfirm();
                  },
                  isEditMode: isEditMode,
                  orderDirection: orderDirection,
                ),
              ),
            );

            // If authenticated, close both pages
            if (authenticated == true && context.mounted) {
              Navigator.pop(context); // Close confirmation
              Navigator.pop(context); // Close trade page
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(TablerIcons.check, size: 20),
              SizedBox(width: 8),
              Text(
                buttonText,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
