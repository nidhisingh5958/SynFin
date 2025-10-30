import 'package:flutter_test/flutter_test.dart';
import 'package:SynFin/models/transaction.dart';
import 'package:SynFin/models/budget.dart';
import 'package:SynFin/models/ai_insight.dart';

void main() {
  group('Transaction Model Tests', () {
    test('Transaction should be created with correct values', () {
      final transaction = Transaction(
        id: '1',
        title: 'Test Transaction',
        amount: 100.0,
        date: DateTime(2024, 1, 1),
        type: TransactionType.expense,
        category: Category.food,
      );

      expect(transaction.id, '1');
      expect(transaction.title, 'Test Transaction');
      expect(transaction.amount, 100.0);
      expect(transaction.type, TransactionType.expense);
      expect(transaction.category, Category.food);
    });

    test('Transaction should convert to and from JSON', () {
      final transaction = Transaction(
        id: '1',
        title: 'Test',
        amount: 50.0,
        date: DateTime(2024, 1, 1),
        type: TransactionType.income,
        category: Category.salary,
      );

      final json = transaction.toJson();
      final fromJson = Transaction.fromJson(json);

      expect(fromJson.id, transaction.id);
      expect(fromJson.title, transaction.title);
      expect(fromJson.amount, transaction.amount);
      expect(fromJson.type, transaction.type);
      expect(fromJson.category, transaction.category);
    });
  });

  group('Budget Model Tests', () {
    test('Budget should calculate remaining amount correctly', () {
      final budget = Budget(
        id: '1',
        categoryName: 'Food',
        limit: 500.0,
        spent: 200.0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(budget.remaining, 300.0);
    });

    test('Budget should calculate percentage used correctly', () {
      final budget = Budget(
        id: '1',
        categoryName: 'Food',
        limit: 500.0,
        spent: 250.0,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(budget.percentageUsed, 50.0);
    });
  });

  group('AI Insight Model Tests', () {
    test('AI Insight should be created with correct values', () {
      final insight = AIInsight(
        id: '1',
        title: 'Test Insight',
        description: 'Test Description',
        type: 'tip',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(insight.id, '1');
      expect(insight.title, 'Test Insight');
      expect(insight.description, 'Test Description');
      expect(insight.type, 'tip');
      expect(insight.isRead, false);
    });

    test('AI Insight should convert to and from JSON', () {
      final insight = AIInsight(
        id: '1',
        title: 'Test',
        description: 'Description',
        type: 'warning',
        createdAt: DateTime(2024, 1, 1),
        isRead: true,
      );

      final json = insight.toJson();
      final fromJson = AIInsight.fromJson(json);

      expect(fromJson.id, insight.id);
      expect(fromJson.title, insight.title);
      expect(fromJson.description, insight.description);
      expect(fromJson.type, insight.type);
      expect(fromJson.isRead, insight.isRead);
    });
  });
}
