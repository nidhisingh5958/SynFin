import 'package:flutter/foundation.dart' hide Category;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => [..._transactions];
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString('transactions');

      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions = decoded.map((e) => Transaction.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = json.encode(
        _transactions.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('transactions', transactionsJson);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    notifyListeners();
    await _saveTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveTransactions();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Map<Category, double> getSpendingByCategory() {
    final Map<Category, double> spending = {};

    for (var transaction in _transactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      spending[transaction.category] =
          (spending[transaction.category] ?? 0) + transaction.amount;
    }

    return spending;
  }
}
