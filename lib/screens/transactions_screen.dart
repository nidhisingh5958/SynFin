import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'income', label: Text('Income')),
              ButtonSegment(value: 'expense', label: Text('Expense')),
            ],
            selected: {_filterType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _filterType = newSelection.first;
              });
            },
          ),
        ),
        Expanded(
          child: Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              var transactions = provider.transactions;

              if (_filterType != 'all') {
                transactions = transactions.where((t) {
                  return transactionTypeToString(t.type) == _filterType;
                }).toList();
              }

              transactions.sort((a, b) => b.date.compareTo(a.date));

              if (transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first transaction',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(context, transaction, provider);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Transaction transaction,
    TransactionProvider provider,
  ) {
    final isIncome = transaction.type == TransactionType.income;

    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.deleteTransaction(transaction.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(transaction.title),
          subtitle: Text(
            '${categoryToString(transaction.category)} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.salary:
        return Icons.attach_money;
      case Category.freelance:
        return Icons.work;
      case Category.investment:
        return Icons.trending_up;
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_car;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.bills:
        return Icons.receipt;
      case Category.entertainment:
        return Icons.movie;
      case Category.health:
        return Icons.health_and_safety;
      case Category.education:
        return Icons.school;
      case Category.other:
        return Icons.more_horiz;
    }
  }
}
