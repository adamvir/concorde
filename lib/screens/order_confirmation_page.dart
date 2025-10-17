import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'order_auth_page.dart';
import '../state/theme_state.dart';
import '../theme/app_colors.dart';

class OrderConfirmationPage extends StatefulWidget {
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
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final ThemeState _themeState = ThemeState();

  @override
  void initState() {
    super.initState();
    _themeState.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _themeState.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark: _themeState.isDark);
    bool isBuy = widget.orderDirection == 'Vétel';

    // Dynamic colors: Módosítás = dark grey, Vétel = green, Eladás = red
    Color headerColor;
    if (widget.isEditMode) {
      headerColor = colors.textPrimary; // Dark grey for edit
    } else if (isBuy) {
      headerColor = colors.success; // Green for buy
    } else {
      headerColor = colors.error; // Red for sell
    }

    String orderTypeText = widget.orderType == 'Piaci' ? 'piaci áron' : 'limit árfolyamon';
    String headerTitle;
    if (widget.isEditMode) {
      headerTitle = 'Megbízás módosítása';
    } else if (isBuy) {
      headerTitle = 'Vétel $orderTypeText';
    } else {
      headerTitle = 'Eladás $orderTypeText';
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(TablerIcons.arrow_left, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Megbízás áttekintése',
          style: TextStyle(
            color: colors.textPrimary,
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
                  _buildHeader(colors, headerColor, headerTitle, isBuy),
                  SizedBox(height: 24),
                  // Order details
                  _buildSection(
                    colors: colors,
                    title: 'Megbízás',
                    children: [
                      _buildDetailRow(colors, 'Termék', '${widget.stockName}\n${widget.ticker}'),
                      _buildDetailRow(colors, 'Megbízás', widget.orderDirection),
                      _buildDetailRow(colors, 'Típus', '${widget.orderType} ár'),
                      _buildDetailRow(colors, 'Mennyiség', '${widget.quantity} db'),
                      _buildDetailRow(colors, 'Várható nettó érték', '${widget.expectedValue.toStringAsFixed(2)} ${widget.currency}'),
                      _buildDetailRow(colors, 'Számla', widget.accountName),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Costs
                  _buildSection(
                    colors: colors,
                    title: 'Költségek',
                    children: [
                      _buildDetailRow(colors, 'Jutalék', '3,5 ${widget.currency}'),
                      _buildDetailRow(colors, 'Deviza váltás\nköltsége', '15,4 ${widget.currency}'),
                      _buildDetailRow(colors, 'Szükséges fedezet', '${(widget.expectedValue + 18.9).toStringAsFixed(1)} ${widget.currency}'),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Advanced settings
                  _buildSection(
                    colors: colors,
                    title: 'Haladó beállítások',
                    children: [
                      _buildDetailRow(colors, 'Érvényesség', 'Mai napra'),
                      _buildDetailRow(colors, 'Stop ajánlat', 'Nincs'),
                      _buildDetailRow(colors, 'Látható mennyiség', 'Nem Iceberg ajánlat'),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Warnings
                  _buildWarnings(colors, isBuy),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(context, colors, isBuy),
    );
  }

  Widget _buildHeader(AppColors colors, Color color, String headerTitle, bool isBuy) {
    // Determine icon based on edit mode or buy/sell
    IconData iconData;
    if (widget.isEditMode) {
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
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.stockName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'kb. ${widget.expectedValue.toStringAsFixed(0)} ${widget.currency} értékben',
                  style: TextStyle(
                    color: colors.textSecondary,
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

  Widget _buildSection({required AppColors colors, required String title, required List<Widget> children}) {
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
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(TablerIcons.chevron_up, color: colors.textPrimary),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.border),
              bottom: BorderSide(color: colors.border),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(AppColors colors, String label, String value) {
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
                color: colors.textSecondary,
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
                color: colors.textPrimary,
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

  Widget _buildWarnings(AppColors colors, bool isBuy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Figyelmeztetések',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          _buildWarningCard(
            colors,
            'MiFID II figyelmeztetés: a termék komplex',
            Color(0xFFFEF3C6),
          ),
          SizedBox(height: 12),
          _buildWarningCard(
            colors,
            isBuy
                ? 'A megadott ár legalább 10%-kal magasabb a legutolsó záróártól. (Előző zárő: 124 USD, 2025.02.08, eltérés: +13,57%)'
                : 'A megadott ár legalább 10%-kal alacsonyabb a legutolsó záróártól. (Előző zárő: 124 USD, 2025.02.08, eltérés: -13,57%)',
            colors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(AppColors colors, String text, Color backgroundColor) {
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
            color: colors.warning,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.textPrimary,
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

  Widget _buildBottomButton(BuildContext context, AppColors colors, bool isBuy) {
    // Dynamic colors: Módosítás = dark grey, Vétel = green, Eladás = red
    Color buttonColor;
    if (widget.isEditMode) {
      buttonColor = colors.textPrimary; // Dark grey for edit
    } else if (isBuy) {
      buttonColor = colors.success; // Green for buy
    } else {
      buttonColor = colors.error; // Red for sell
    }

    String buttonText = widget.isEditMode
        ? 'Módosítás jóváhagyása'
        : (isBuy ? 'Vétel jóváhagyása' : 'Eladás jóváhagyása');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
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
                    widget.onConfirm();
                  },
                  isEditMode: widget.isEditMode,
                  orderDirection: widget.orderDirection,
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
