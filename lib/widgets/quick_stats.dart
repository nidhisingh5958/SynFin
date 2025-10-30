import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final categorySpending = provider.getSpendingByCategory();

        if (categorySpending.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _getSections(categorySpending),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categorySpending.entries.map((entry) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: _getColorForCategory(
                          categoryToString(entry.key),
                        ),
                      ),
                      label: Text(
                        '${categoryToString(entry.key)}: \$${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getSections(Map<Category, double> data) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    return data.entries.map((MapEntry<Category, double> entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getColorForCategory(categoryToString(entry.key)),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    final colors = {
      'food': Colors.orange,
      'transport': Colors.blue,
      'shopping': Colors.purple,
      'bills': Colors.red,
      'entertainment': Colors.pink,
      'health': Colors.green,
      'education': Colors.teal,
      'other': Colors.grey,
      'salary': Colors.lightGreen,
      'freelance': Colors.cyan,
      'investment': Colors.amber,
    };
    return colors[category] ?? Colors.grey;
  }
}
