import 'package:flutter/material.dart';
import '../data/mock_portfolio_data.dart';

class AccountSelectorBottomSheet extends StatefulWidget {
  final String selectedAccount;
  final Function(String) onAccountSelected;

  const AccountSelectorBottomSheet({
    Key? key,
    required this.selectedAccount,
    required this.onAccountSelected,
  }) : super(key: key);

  @override
  State<AccountSelectorBottomSheet> createState() => _AccountSelectorBottomSheetState();
}

class _AccountSelectorBottomSheetState extends State<AccountSelectorBottomSheet> {
  late String _currentSelection;
  final MockPortfolioData _portfolioData = MockPortfolioData();

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedAccount;
  }

  String _formatValue(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} HUF';
  }

  List<Map<String, String>> _getAccountsWithValues() {
    List<Map<String, String>> accounts = [];

    // Add "Minden számla" (all accounts combined)
    var combined = _portfolioData.getCombinedPortfolio();
    accounts.add({
      'name': 'Minden számla',
      'value': _formatValue(combined.totalValue),
    });

    // Add individual accounts
    for (var account in _portfolioData.getAllAccounts()) {
      accounts.add({
        'name': account.accountName,
        'value': _formatValue(account.totalValue),
      });
    }

    return accounts;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
                      'Számla',
                      style: TextStyle(
                        color: const Color(0xFF1D293D),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
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
          // Account list
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: _getAccountsWithValues().map((account) {
                bool isSelected = _currentSelection == account['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentSelection = account['name']!;
                    });
                    widget.onAccountSelected(account['name']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFEF3C6) : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            account['name']!,
                            style: TextStyle(
                              color: const Color(0xFF1D293D),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              letterSpacing: 0.10,
                            ),
                          ),
                          Text(
                            account['value']!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF1D293D) : const Color(0xFF45556C),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              letterSpacing: 0.10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
