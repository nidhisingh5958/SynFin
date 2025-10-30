import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_insight.dart';
import '../models/transaction.dart';
import '../models/financial_ai_models.dart';
import '../services/ai_agent_service.dart';

class AIAgentProvider with ChangeNotifier {
  final AIAgentService _aiService = AIAgentService();

  List<AIInsight> _insights = [];
  bool _isGenerating = false;
  String _lastAdvice = '';
  bool _isGettingAdvice = false;
  bool _isBackendAvailable = false;
  ChatResponse? _lastResponse;

  List<AIInsight> get insights => [..._insights];
  bool get isGenerating => _isGenerating;
  String get lastAdvice => _lastAdvice;
  bool get isGettingAdvice => _isGettingAdvice;
  bool get isBackendAvailable => _isBackendAvailable;
  ChatResponse? get lastResponse => _lastResponse;

  int get unreadInsightsCount => _insights.where((i) => !i.isRead).length;

  AIAgentProvider() {
    _loadInsights();
    checkBackendStatus();
  }

  /// Check if the AI backend is available
  Future<void> checkBackendStatus() async {
    _isBackendAvailable = await _aiService.checkBackendHealth();
    notifyListeners();
  }

  /// Set user context for personalized responses
  void setUserContext(String context) {
    _aiService.setUserContext(context);
  }

  /// Send a direct chat message to AI
  Future<ChatResponse> sendMessage({
    required String message,
    String? userContext,
    List<Transaction>? transactions,
  }) async {
    _isGettingAdvice = true;
    notifyListeners();

    try {
      List<ExpenditureEntry>? expenditureData;
      if (transactions != null && transactions.isNotEmpty) {
        expenditureData = transactions
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

      _lastResponse = await _aiService.sendChatMessage(
        message: message,
        userContext: userContext,
        expenditureData: expenditureData,
      );

      _lastAdvice = _lastResponse!.response;

      return _lastResponse!;
    } catch (e) {
      debugPrint('Error sending message: $e');
      _lastAdvice = 'Sorry, I encountered an error. Please try again.';
      return ChatResponse(
        response: _lastAdvice,
        queryType: 'error',
        error: e.toString(),
      );
    } finally {
      _isGettingAdvice = false;
      notifyListeners();
    }
  }

  /// Analyze expenditure with the AI
  Future<Map<String, dynamic>> analyzeExpenditure(
    List<Transaction> transactions,
  ) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final result = await _aiService.analyzeExpenditure(transactions);
      return result;
    } catch (e) {
      debugPrint('Error analyzing expenditure: $e');
      return {
        'total': 0.0,
        'breakdown': <String, double>{},
        'message': 'Error analyzing expenditure',
      };
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Get investment advice
  Future<String> getInvestmentAdvice(String query) async {
    _isGettingAdvice = true;
    notifyListeners();

    try {
      final advice = await _aiService.getInvestmentAdvice(query);
      _lastAdvice = advice;
      return advice;
    } catch (e) {
      debugPrint('Error getting investment advice: $e');
      _lastAdvice = 'Sorry, I encountered an error. Please try again.';
      return _lastAdvice;
    } finally {
      _isGettingAdvice = false;
      notifyListeners();
    }
  }

  /// Get tax advice
  Future<String> getTaxAdvice(String query) async {
    _isGettingAdvice = true;
    notifyListeners();

    try {
      final advice = await _aiService.getTaxAdvice(query);
      _lastAdvice = advice;
      return advice;
    } catch (e) {
      debugPrint('Error getting tax advice: $e');
      _lastAdvice = 'Sorry, I encountered an error. Please try again.';
      return _lastAdvice;
    } finally {
      _isGettingAdvice = false;
      notifyListeners();
    }
  }

  Future<void> _loadInsights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final insightsJson = prefs.getString('insights');

      if (insightsJson != null) {
        final List<dynamic> decoded = json.decode(insightsJson);
        _insights = decoded.map((e) => AIInsight.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading insights: $e');
    }
  }

  Future<void> _saveInsights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final insightsJson = json.encode(
        _insights.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('insights', insightsJson);
    } catch (e) {
      debugPrint('Error saving insights: $e');
    }
  }

  Future<void> generateInsights(
    List<Transaction> transactions,
    double monthlyBudget,
  ) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final newInsights = await _aiService.generateInsights(
        transactions,
        monthlyBudget,
      );

      _insights.addAll(newInsights);

      // Keep only last 20 insights
      if (_insights.length > 20) {
        _insights = _insights.sublist(_insights.length - 20);
      }

      await _saveInsights();
    } catch (e) {
      debugPrint('Error generating insights: $e');
    }

    _isGenerating = false;
    notifyListeners();
  }

  Future<void> getAdvice(String query, List<Transaction> context) async {
    _isGettingAdvice = true;
    notifyListeners();

    try {
      _lastAdvice = await _aiService.getFinancialAdvice(query, context);
    } catch (e) {
      debugPrint('Error getting advice: $e');
      _lastAdvice = 'Sorry, I encountered an error. Please try again.';
    }

    _isGettingAdvice = false;
    notifyListeners();
  }

  void markInsightAsRead(String id) {
    final index = _insights.indexWhere((i) => i.id == id);
    if (index != -1) {
      _insights[index] = AIInsight(
        id: _insights[index].id,
        title: _insights[index].title,
        description: _insights[index].description,
        type: _insights[index].type,
        createdAt: _insights[index].createdAt,
        isRead: true,
      );
      _saveInsights();
      notifyListeners();
    }
  }

  void clearInsights() {
    _insights.clear();
    _saveInsights();
    notifyListeners();
  }
}
