import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ai_agent_provider.dart';
import '../providers/transaction_provider.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check backend status on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);
      aiProvider.checkBackendStatus();
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AIAgentProvider, TransactionProvider>(
      builder: (context, aiProvider, transactionProvider, _) {
        return Column(
          children: [
            // Backend Status Banner
            if (!aiProvider.isBackendAvailable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI Backend is offline. Some features may not work.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => aiProvider.checkBackendStatus(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAIAssistantCard(
                    context,
                    aiProvider,
                    transactionProvider,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AI Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Backend status indicator
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: aiProvider.isBackendAvailable
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            aiProvider.isBackendAvailable
                                ? 'Online'
                                : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: aiProvider.isBackendAvailable
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          if (aiProvider.insights.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Clear Insights'),
                                    content: const Text(
                                      'Are you sure you want to clear all insights?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          aiProvider.clearInsights();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Clear'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Clear All'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (aiProvider.isGenerating)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('AI is analyzing your finances...'),
                          ],
                        ),
                      ),
                    ),
                  if (aiProvider.insights.isEmpty && !aiProvider.isGenerating)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No insights yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add transactions to get AI-powered insights',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...aiProvider.insights.reversed.map((insight) {
                    return _buildInsightCard(context, insight, aiProvider);
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAIAssistantCard(
    BuildContext context,
    AIAgentProvider aiProvider,
    TransactionProvider transactionProvider,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Financial Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Query type badge
                if (aiProvider.lastResponse != null &&
                    !aiProvider.isGettingAdvice)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getQueryTypeColor(
                        aiProvider.lastResponse!.queryType,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getQueryTypeDisplay(aiProvider.lastResponse!.queryType),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Ask me about your finances...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_queryController.text.isNotEmpty) {
                      final query = _queryController.text;
                      _queryController.clear();

                      await aiProvider.sendMessage(
                        message: query,
                        transactions: transactionProvider.transactions,
                      );
                    }
                  },
                ),
              ),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  await aiProvider.sendMessage(
                    message: value,
                    transactions: transactionProvider.transactions,
                  );
                  _queryController.clear();
                }
              },
            ),
            if (aiProvider.isGettingAdvice)
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Thinking...'),
                  ],
                ),
              ),
            if (aiProvider.lastAdvice.isNotEmpty && !aiProvider.isGettingAdvice)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: aiProvider.lastResponse?.hasError == true
                        ? Colors.red.shade200
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (aiProvider.lastResponse?.hasError == true)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Error',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(aiProvider.lastAdvice),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getQueryTypeColor(String queryType) {
    switch (queryType) {
      case 'expenditure_analysis':
        return Colors.blue;
      case 'insights_generation':
        return Colors.purple;
      case 'tax_advice':
        return Colors.orange;
      case 'investment_advice':
        return Colors.green;
      case 'revenue_analysis':
        return Colors.teal;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getQueryTypeDisplay(String queryType) {
    switch (queryType) {
      case 'expenditure_analysis':
        return 'Spending';
      case 'insights_generation':
        return 'Insights';
      case 'tax_advice':
        return 'Tax';
      case 'investment_advice':
        return 'Investment';
      case 'revenue_analysis':
        return 'Revenue';
      case 'general_chat':
        return 'Chat';
      case 'error':
        return 'Error';
      default:
        return queryType;
    }
  }

  Widget _buildInsightCard(
    BuildContext context,
    dynamic insight,
    AIAgentProvider aiProvider,
  ) {
    Color getColorByType(String type) {
      switch (type) {
        case 'warning':
          return Colors.orange;
        case 'tip':
          return Colors.blue;
        case 'suggestion':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          aiProvider.markInsightAsRead(insight.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: getColorByType(insight.type), width: 4),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        insight.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (!insight.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat(
                    'MMM dd, yyyy • hh:mm a',
                  ).format(insight.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
