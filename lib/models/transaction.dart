enum TransactionType { income, expense }

enum Category {
  salary,
  freelance,
  investment,
  food,
  transport,
  shopping,
  bills,
  entertainment,
  health,
  education,
  other,
}

// a `name` getter for enums for Dart SDKs that don't include Enum.name
extension TransactionTypeName on TransactionType {
  String get name => toString().split('.').last;
}

extension CategoryName on Category {
  String get name => toString().split('.').last;
}

// Helpers to reliably get enum names at runtime
String transactionTypeToString(TransactionType t) =>
    t.toString().split('.').last;
String categoryToString(Category c) => c.toString().split('.').last;

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final Category category;
  final String? notes;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'category': category.name,
      'notes': notes,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      category: Category.values.firstWhere((e) => e.name == json['category']),
      notes: json['notes'],
    );
  }
}
