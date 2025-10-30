import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/ai_insight.dart';
import '../models/financial_ai_models.dart';
import '../config/ai_config.dart';

/// AI Agent Service for generating financial insights and recommendations
/// Integrated with Financial AI System V2 backend
class AIAgentService {
  // Backend API configuration
  static String get _baseUrl => AIConfig.activeBackendUrl;
  static Duration get _timeout => AIConfig.requestTimeout;

  // User context for personalized responses
  String _userContext = 'Individual user managing personal finances';
  
  // Simple response cache
  final Map<String, ChatResponse> _responseCache = {};

  /// Update user context for personalized AI responses
  void setUserContext(String context) {
    _userContext = context;
  }

  /// Send a chat message to the AI system
  Future<ChatResponse> sendChatMessage({
    required String message,
    String? userContext,
    List<ExpenditureEntry>? expenditureData,
  }) async {
    // Validate input
    if (message.trim().isEmpty) {
      return ChatResponse(
        response: 'Please enter a valid message.',
        queryType: 'error',
        error: 'Empty message',
      );
    }
    
    try {
      final request = ChatRequest(
        message: message,
        userContext: userContext ?? _userContext,
        expenditureData: expenditureData,
      );

      final response = await http
          .post(
            _resolveEndpoint(AIConfig.chatEndpoint),
            headers: AIConfig.headers,
            body: json.encode(request.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        return ChatResponse(
          response:
              'Failed to get AI response. Server returned ${response.statusCode}',
          queryType: 'error',
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in sendChatMessage: $e');
      return ChatResponse(
        response:
            'Sorry, I\'m having trouble connecting to the AI service. Please check if the backend is running.',
        queryType: 'error',
        error: e.toString(),
      );
    }
  }

  /// Convert transactions to expenditure entries
  List<ExpenditureEntry> _transactionsToExpenditureEntries(
    List<Transaction> transactions,
  ) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .map(
          (t) => ExpenditureEntry(
            amount: t.amount,
            category: categoryToString(t.category),
            description: t.title,
            date: t.date.toIso8601String(),
          ),
        )
        .toList();
  }

  /// Generate financial insights based on transaction history
  Future<List<AIInsight>> generateInsights(
    List<Transaction> transactions,
    double monthlyBudget,
  ) async {
    if (transactions.isEmpty) {
      return [];
    }

    final insights = <AIInsight>[];

    try {
      // Get expenditure analysis from AI
      final expenditureData = _transactionsToExpenditureEntries(transactions);
      final response = await sendChatMessage(
        message: 'Analyze my spending and provide insights',
        expenditureData: expenditureData,
      );

      // Create insight from AI response
      if (!response.hasError) {
        insights.add(
          AIInsight(
            id: 'insight_${DateTime.now().millisecondsSinceEpoch}',
            title: _getInsightTitle(response.queryType),
            description: response.response,
            type: _getInsightType(response.queryType),
            createdAt: DateTime.now(),
          ),
        );

        // If there's structured data, create additional insights
        if (response.data != null && response.isExpenditureAnalysis) {
          final analysis = ExpenditureAnalysis.fromJson(response.data!);

          if (analysis.recommendations != null &&
              analysis.recommendations!.isNotEmpty) {
            for (
              var i = 0;
              i < analysis.recommendations!.length && i < 3;
              i++
            ) {
              insights.add(
                AIInsight(
                  id: 'insight_${DateTime.now().millisecondsSinceEpoch}_$i',
                  title: '💡 AI Recommendation',
                  description: analysis.recommendations![i],
                  type: 'suggestion',
                  createdAt: DateTime.now(),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error generating insights: $e');
    }

    return insights;
  }

  /// Get personalized financial advice
  Future<String> getFinancialAdvice(
    String query,
    List<Transaction> context,
  ) async {
    try {
      // Include recent transactions as context if relevant
      List<ExpenditureEntry>? expenditureData;
      if (query.toLowerCase().contains('spend') ||
          query.toLowerCase().contains('expense') ||
          query.toLowerCase().contains('budget')) {
        expenditureData = _transactionsToExpenditureEntries(context);
      }

      final response = await sendChatMessage(
        message: query,
        expenditureData: expenditureData,
      );

      return response.response;
    } catch (e) {
      debugPrint('Error getting advice: $e');
      return 'Sorry, I encountered an error processing your request. Please try again.';
    }
  }

  /// Analyze expenditure with detailed breakdown
  Future<Map<String, dynamic>> analyzeExpenditure(
    List<Transaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      return {
        'total': 0.0,
        'breakdown': <String, double>{},
        'message': 'No transactions to analyze',
      };
    }

    try {
      final expenditureData = _transactionsToExpenditureEntries(transactions);
      final response = await sendChatMessage(
        message: 'Provide detailed expenditure analysis',
        expenditureData: expenditureData,
      );

      if (response.isExpenditureAnalysis && response.data != null) {
        final analysis = ExpenditureAnalysis.fromJson(response.data!);
        return {
          'total': analysis.totalSpending,
          'breakdown': analysis.categoryBreakdown,
          'message': response.response,
          'recommendations': analysis.recommendations ?? [],
        };
      }

      return {
        'total': 0.0,
        'breakdown': <String, double>{},
        'message': response.response,
      };
    } catch (e) {
      debugPrint('Error analyzing expenditure: $e');
      return {
        'total': 0.0,
        'breakdown': <String, double>{},
        'message': 'Error analyzing expenditure',
      };
    }
  }

  /// Get investment advice
  Future<String> getInvestmentAdvice(String query) async {
    final response = await sendChatMessage(message: query);
    return response.response;
  }

  /// Get tax advice
  Future<String> getTaxAdvice(String query) async {
    final response = await sendChatMessage(message: query);
    return response.response;
  }

  /// Predict future spending based on historical data
  Future<Map<String, double>> predictNextMonthSpending(
    List<Transaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      return {};
    }

    try {
      final expenditureData = _transactionsToExpenditureEntries(transactions);
      final response = await sendChatMessage(
        message: 'Predict my spending for next month based on my history',
        expenditureData: expenditureData,
      );

      // Parse prediction from response
      if (response.data != null) {
        final predictions = <String, double>{};
        if (response.data!['predictions'] != null) {
          final predData =
              response.data!['predictions'] as Map<String, dynamic>;
          predData.forEach((key, value) {
            predictions[key] = (value as num).toDouble();
          });
        }
        return predictions;
      }

      return {};
    } catch (e) {
      debugPrint('Error predicting spending: $e');
      return {};
    }
  }

  /// Helper method to get insight title based on query type
  String _getInsightTitle(String queryType) {
    switch (queryType) {
      case 'expenditure_analysis':
        return '📊 Spending Analysis';
      case 'insights_generation':
        return '💡 AI Insight';
      case 'tax_advice':
        return '📋 Tax Advice';
      case 'investment_advice':
        return '📈 Investment Suggestion';
      case 'revenue_analysis':
        return '💰 Revenue Analysis';
      default:
        return '🤖 AI Suggestion';
    }
  }

  /// Helper method to get insight type based on query type
  String _getInsightType(String queryType) {
    switch (queryType) {
      case 'expenditure_analysis':
        return 'tip';
      case 'tax_advice':
        return 'warning';
      case 'investment_advice':
        return 'suggestion';
      default:
        return 'tip';
    }
  }

  /// Check if backend is available
  Future<bool> checkBackendHealth() async {
    try {
      final response = await http
          .get(_resolveEndpoint(AIConfig.healthEndpoint))
          .timeout(AIConfig.healthCheckTimeout);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Backend health check failed: $e');
      return false;
    }
  }

  /// Resolve endpoint URI with Android emulator localhost support
  Uri _resolveEndpoint(String endpoint) {
    final base = Uri.parse(_baseUrl);
    // Map localhost to 10.0.2.2 when running on Android emulator
    if (!kIsWeb && Platform.isAndroid) {
      if (base.host == 'localhost' || base.host == '127.0.0.1') {
        final fixed = base.replace(host: '10.0.2.2');
        return fixed.replace(path: _joinPath(fixed.path, endpoint));
      }
    }
    return base.replace(path: _joinPath(base.path, endpoint));
  }

  String _joinPath(String a, String b) {
    final left = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final right = b.startsWith('/') ? b.substring(1) : b;
    return '$left/$right';
  }
}
