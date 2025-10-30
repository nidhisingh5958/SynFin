/// Configuration for Financial AI System Integration

class AIConfig {
  // Backend Configuration
  static const String backendUrl = 'http://localhost:8000';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration healthCheckTimeout = Duration(seconds: 5);

  // API Endpoints
  static const String chatEndpoint = '/chat';
  static const String healthEndpoint = '/';

  // Default User Context
  static const String defaultUserContext =
      'Individual user managing personal finances';

  // Cache Configuration
  static const int maxCachedInsights = 20;
  static const Duration insightCacheDuration = Duration(days: 7);

  // UI Configuration
  static const int maxRecommendationsToShow = 3;
  static const bool showQueryType = true;
  static const bool enableOfflineMode = false;

  // Feature Flags
  static const bool enableExpenditureAnalysis = true;
  static const bool enableInvestmentAdvice = true;
  static const bool enableTaxAdvice = true;
  static const bool enableSpendingPredictions = true;

  // Production Configuration
  // When deploying to production, update these values:
  static const String productionBackendUrl = 'https://your-ai-backend.com';
  static const bool isProduction = false;

  /// Get the active backend URL based on environment
  static String get activeBackendUrl {
    return isProduction ? productionBackendUrl : backendUrl;
  }

  /// API Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get full endpoint URL
  static String getEndpointUrl(String endpoint) {
    return '$activeBackendUrl$endpoint';
  }
}
