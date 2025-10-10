import 'package:flutter/material.dart';

class AccountState extends ChangeNotifier {
  static final AccountState _instance = AccountState._internal();

  factory AccountState() {
    return _instance;
  }

  AccountState._internal();

  String _selectedAccount = 'Minden számla';

  String get selectedAccount => _selectedAccount;

  void setSelectedAccount(String account) {
    print('AccountState: Setting account to: $account');
    _selectedAccount = account;
    notifyListeners();
    print('AccountState: Listeners notified');
  }
}
