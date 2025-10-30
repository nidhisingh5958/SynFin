class Budget {
  final String id;
  final String categoryName;
  final double limit;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.categoryName,
    required this.limit,
    required this.spent,
    required this.startDate,
    required this.endDate,
  });

  double get remaining => limit - spent;
  double get percentageUsed => (spent / limit * 100).clamp(0, 100);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'limit': limit,
      'spent': spent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryName: json['categoryName'],
      limit: json['limit'],
      spent: json['spent'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}
