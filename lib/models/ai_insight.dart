class AIInsight {
  final String id;
  final String title;
  final String description;
  final String type; // 'tip', 'warning', 'suggestion'
  final DateTime createdAt;
  final bool isRead;

  AIInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}
