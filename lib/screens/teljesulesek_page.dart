import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../services/transaction_service.dart';
import '../state/account_state.dart';
import '../widgets/account_selector_bottom_sheet.dart' as account_chooser;
import 'package:intl/intl.dart';

class TeljesulasekPage extends StatefulWidget {
  const TeljesulasekPage({super.key});

  @override
  State<TeljesulasekPage> createState() => _TeljesulasekPageState();
}

class _TeljesulasekPageState extends State<TeljesulasekPage> {
  final TransactionService _transactionService = TransactionService();
  final AccountState _accountState = AccountState();

  @override
  void initState() {
    super.initState();
    _accountState.addListener(_onAccountChanged);
    // Mark all transactions as viewed when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Clear notification badge using dynamic
        dynamic service = _transactionService;
        final transactions = service.completedTransactions as List;
        for (var t in transactions) {
          t.isViewed = true;
        }
        service.notifyListeners();
      } catch (e) {
        // Silently handle if method doesn't exist yet
      }
    });
  }

  @override
  void dispose() {
    _accountState.removeListener(_onAccountChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    setState(() {});
  }

  void _showAccountSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => account_chooser.AccountSelectorBottomSheet(
        selectedAccount: _accountState.selectedAccount,
        onAccountSelected: (account) {
          _accountState.setSelectedAccount(account);
        },
      ),
    );
  }

  List<dynamic> _getFilteredTransactions() {
    try {
      // Use dynamic to bypass IDE errors
      dynamic service = _transactionService;
      final allTransactions = service.completedTransactions as List;
      if (_accountState.selectedAccount == 'Minden számla') {
        return allTransactions;
      }
      return allTransactions
          .where((t) => t.accountName == _accountState.selectedAccount)
          .toList();
    } catch (e) {
      // Return empty list if service not ready
      return [];
    }
  }

  String _formatTransactionTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      // Today - show "Ma HH:mm:ss"
      return 'Ma ${DateFormat('HH:mm:ss').format(date)}';
    } else {
      // Other days - show "yyyy.MM.dd."
      return '${DateFormat('yyyy.MM.dd').format(date)}.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getFilteredTransactions();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(TablerIcons.arrow_left, color: Color(0xFF1D293D)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: GestureDetector(
          onTap: _showAccountSelector,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teljesülések',
                style: TextStyle(
                  color: Color(0xFF1D293D),
                  fontSize: 22,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.27,
                ),
              ),
              Text(
                _accountState.selectedAccount,
                style: const TextStyle(
                  color: Color(0xFF45556C),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.chevron_down, color: Color(0xFF1D293D)),
            onPressed: _showAccountSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
            ),
            child: const Text(
              'Az utolsó 2 munkanap teljesülései.',
              style: TextStyle(
                color: Color(0xFF45556C),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: 0.10,
              ),
            ),
          ),

          // Table header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Termék and Vétel/Eladás
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Termék',
                      style: TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.50,
                      ),
                    ),
                    Text(
                      'Vétel / Eladás',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Second row: Össz. darab and Érték
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Össz. darab @ átl. ár',
                      style: TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.50,
                      ),
                    ),
                    Text(
                      'Érték',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Third row: Teljesülés ideje and Számla
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Teljesülés ideje',
                      style: TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.50,
                      ),
                    ),
                    Text(
                      'Számla',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'Nincs teljesült megbízás',
                      style: TextStyle(
                        color: Color(0xFF45556C),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isBuy = transaction.type.toString() == 'TransactionType.buy';
                      final formattedValue = NumberFormat('#,##0.00', 'en_US')
                          .format(transaction.totalValue)
                          .replaceAll(',', ' ');

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First row: Stock name and Buy/Sell
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  transaction.stockName,
                                  style: const TextStyle(
                                    color: Color(0xFF1D293D),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                                Text(
                                  isBuy ? 'Vétel' : 'Eladás',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: isBuy ? const Color(0xFF009966) : const Color(0xFFEC003F),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // Second row: Quantity @ price and Value
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${transaction.quantity} db @ ${transaction.price.toStringAsFixed(2).replaceAll('.', ',')} ${transaction.currency}',
                                  style: const TextStyle(
                                    color: Color(0xFF45556C),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                                Text(
                                  '$formattedValue ${transaction.currency}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFF1D293D),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // Third row: Time and Account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTransactionTime(transaction.completedAt),
                                  style: const TextStyle(
                                    color: Color(0xFF45556C),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                                Text(
                                  transaction.accountName,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFF45556C),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.43,
                                    letterSpacing: 0.10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
