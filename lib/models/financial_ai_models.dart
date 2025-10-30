/// Expenditure entry for AI analysis
class ExpenditureEntry {
  final double amount;
  final String category;
  final String description;
  final String date; // ISO datetime

  ExpenditureEntry({
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
    };
  }

  factory ExpenditureEntry.fromJson(Map<String, dynamic> json) {
    return ExpenditureEntry(
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
    );
  }
}

/// Chat request to AI system
class ChatRequest {
  final String message;
  final String? userContext;
  final List<ExpenditureEntry>? expenditureData;

  ChatRequest({required this.message, this.userContext, this.expenditureData});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (userContext != null) 'user_context': userContext,
      if (expenditureData != null)
        'expenditure_data': expenditureData?.map((e) => e.toJson()).toList(),
    };
  }
}

/// Chat response from AI system
class ChatResponse {
  final String response;
  final String queryType;
  final Map<String, dynamic>? data;
  final String? error;

  ChatResponse({
    required this.response,
    required this.queryType,
    this.data,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] as String? ?? '',
      queryType: json['query_type'] as String? ?? 'general_chat',
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }

  bool get hasError => error != null;

  bool get isExpenditureAnalysis => queryType == 'expenditure_analysis';
  bool get isInsightsGeneration => queryType == 'insights_generation';
  bool get isTaxAdvice => queryType == 'tax_advice';
  bool get isInvestmentAdvice => queryType == 'investment_advice';
  bool get isRevenueAnalysis => queryType == 'revenue_analysis';
  bool get isGeneralChat => queryType == 'general_chat';
}

/// Expenditure analysis data
class ExpenditureAnalysis {
  final double totalSpending;
  final Map<String, double> categoryBreakdown;
  final Map<String, dynamic>? spendingTrend;
  final List<String>? recommendations;

  ExpenditureAnalysis({
    required this.totalSpending,
    required this.categoryBreakdown,
    this.spendingTrend,
    this.recommendations,
  });

  factory ExpenditureAnalysis.fromJson(Map<String, dynamic> json) {
    return ExpenditureAnalysis(
      totalSpending: (json['total_spending'] as num?)?.toDouble() ?? 0.0,
      categoryBreakdown:
          (json['category_breakdown'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
      spendingTrend: json['spending_trend'] as Map<String, dynamic>?,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

/// Query types enum
enum QueryType {
  expenditureAnalysis,
  insightsGeneration,
  taxAdvice,
  investmentAdvice,
  revenueAnalysis,
  generalChat,
  error,
}

extension QueryTypeExtension on QueryType {
  String get displayName {
    switch (this) {
      case QueryType.expenditureAnalysis:
        return 'Expenditure Analysis';
      case QueryType.insightsGeneration:
        return 'Insights';
      case QueryType.taxAdvice:
        return 'Tax Advice';
      case QueryType.investmentAdvice:
        return 'Investment Advice';
      case QueryType.revenueAnalysis:
        return 'Revenue Analysis';
      case QueryType.generalChat:
        return 'General Chat';
      case QueryType.error:
        return 'Error';
    }
  }

  static QueryType fromString(String value) {
    switch (value) {
      case 'expenditure_analysis':
        return QueryType.expenditureAnalysis;
      case 'insights_generation':
        return QueryType.insightsGeneration;
      case 'tax_advice':
        return QueryType.taxAdvice;
      case 'investment_advice':
        return QueryType.investmentAdvice;
      case 'revenue_analysis':
        return QueryType.revenueAnalysis;
      case 'general_chat':
        return QueryType.generalChat;
      default:
        return QueryType.error;
    }
  }
}
