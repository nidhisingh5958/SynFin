/// Example Usage of Financial AI Integration in Savify
/// This file demonstrates how to use the AI features in your Flutter app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_agent_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/financial_ai_models.dart';

/// Example 1: Simple Chat Query
Future<void> exampleSimpleChat(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);

  // Send a simple message
  final response = await aiProvider.sendMessage(
    message: "How can I save money on groceries?",
    userContext: "College student with limited budget",
  );

  print('AI Response: ${response.response}');
  print('Query Type: ${response.queryType}');
}

/// Example 2: Expenditure Analysis
Future<void> exampleExpenditureAnalysis(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);
  final transactionProvider = Provider.of<TransactionProvider>(
    context,
    listen: false,
  );

  // Analyze all transactions
  final analysis = await aiProvider.analyzeExpenditure(
    transactionProvider.transactions,
  );

  print('Total Spending: \$${analysis['total']}');
  print('Category Breakdown:');
  (analysis['breakdown'] as Map<String, double>).forEach((category, amount) {
    print('  $category: \$${amount.toStringAsFixed(2)}');
  });
  print('AI Message: ${analysis['message']}');

  if (analysis['recommendations'] != null) {
    print('Recommendations:');
    for (var rec in analysis['recommendations']) {
      print('  - $rec');
    }
  }
}

/// Example 3: Generate Insights
Future<void> exampleGenerateInsights(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);
  final transactionProvider = Provider.of<TransactionProvider>(
    context,
    listen: false,
  );

  // Generate insights
  await aiProvider.generateInsights(
    transactionProvider.transactions,
    5000.0, // monthly budget
  );

  // Access insights
  for (var insight in aiProvider.insights) {
    print(insight.title);
    print(insight.description);
    print('Type: ${insight.type}');
    print('---');
  }
}

/// Example 4: Chat with Transaction Context
Future<void> exampleChatWithContext(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);
  final transactionProvider = Provider.of<TransactionProvider>(
    context,
    listen: false,
  );

  // Ask a question with transaction context
  final response = await aiProvider.sendMessage(
    message: "Analyze my spending this month",
    transactions: transactionProvider.transactions,
  );

  // Check if it's an expenditure analysis
  if (response.isExpenditureAnalysis && response.data != null) {
    final analysis = ExpenditureAnalysis.fromJson(response.data!);
    print('Total: \$${analysis.totalSpending}');
    print('Categories:');
    analysis.categoryBreakdown.forEach((cat, amt) {
      print('  $cat: \$${amt.toStringAsFixed(2)}');
    });
  }
}

/// Example 5: Investment Advice
Future<void> exampleInvestmentAdvice(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);

  final advice = await aiProvider.getInvestmentAdvice(
    "I have \$10,000 to invest. What should I do?",
  );

  print('Investment Advice: $advice');
}

/// Example 6: Tax Advice
Future<void> exampleTaxAdvice(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);

  final advice = await aiProvider.getTaxAdvice(
    "What tax deductions can I claim as a freelance developer?",
  );

  print('Tax Advice: $advice');
}

/// Example 7: Check Backend Status
Future<void> exampleCheckBackend(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);

  await aiProvider.checkBackendStatus();

  if (aiProvider.isBackendAvailable) {
    print('✅ Backend is online and ready');
  } else {
    print('❌ Backend is offline');
    // Show user a message or fallback to local processing
  }
}

/// Example 8: Handle Response Types
Future<void> exampleHandleResponseTypes(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);
  final transactionProvider = Provider.of<TransactionProvider>(
    context,
    listen: false,
  );

  final response = await aiProvider.sendMessage(
    message: "Should I invest in stocks?",
    transactions: transactionProvider.transactions,
  );

  // Handle different response types
  if (response.isInvestmentAdvice) {
    print('Got investment advice: ${response.response}');
    // Show in a specialized UI for investment advice
  } else if (response.isTaxAdvice) {
    print('Got tax advice: ${response.response}');
    // Show in a specialized UI for tax advice
  } else if (response.isExpenditureAnalysis) {
    print('Got expenditure analysis: ${response.response}');
    // Show in a chart or detailed breakdown UI
  } else if (response.hasError) {
    print('Error occurred: ${response.error}');
    // Show error message to user
  } else {
    print('General chat response: ${response.response}');
    // Show in chat UI
  }
}

/// Example 9: Set User Context
Future<void> exampleSetUserContext(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);

  // Set user context for personalized responses
  aiProvider.setUserContext(
    "25-year-old software developer, annual income \$80,000, "
    "living in a rented apartment, saving for a house down payment",
  );

  // Now all queries will be personalized based on this context
  final response = await aiProvider.sendMessage(
    message: "What's the best way to save for a house?",
  );

  print(response.response);
}

/// Example 10: Complete Workflow with Error Handling
Future<void> exampleCompleteWorkflow(BuildContext context) async {
  final aiProvider = Provider.of<AIAgentProvider>(context, listen: false);
  final transactionProvider = Provider.of<TransactionProvider>(
    context,
    listen: false,
  );

  try {
    // 1. Check backend availability
    await aiProvider.checkBackendStatus();

    if (!aiProvider.isBackendAvailable) {
      print('Backend not available. Please start the AI service.');
      return;
    }

    // 2. Set user context
    aiProvider.setUserContext("College student with limited budget");

    // 3. Check if we have transactions
    if (transactionProvider.transactions.isEmpty) {
      print('No transactions to analyze. Please add some transactions first.');
      return;
    }

    // 4. Generate insights
    print('Generating insights...');
    await aiProvider.generateInsights(
      transactionProvider.transactions,
      3000.0, // monthly budget
    );

    // 5. Get expenditure analysis
    print('Analyzing expenditure...');
    final analysis = await aiProvider.analyzeExpenditure(
      transactionProvider.transactions,
    );

    print('\n--- Analysis Results ---');
    print('Total Spending: \$${analysis['total']}');
    print('Breakdown: ${analysis['breakdown']}');
    print('Message: ${analysis['message']}');

    // 6. Ask follow-up question
    print('\nAsking for savings advice...');
    final response = await aiProvider.sendMessage(
      message: "Based on my spending, how can I save \$500 per month?",
      transactions: transactionProvider.transactions,
    );

    print('\n--- Savings Advice ---');
    print('Query Type: ${response.queryType}');
    print('Response: ${response.response}');

    print('\n✅ Workflow completed successfully!');
  } catch (e) {
    print('❌ Error in workflow: $e');
  }
}

/// Example Widget: AI Chat Dialog
class AIChatDialog extends StatefulWidget {
  const AIChatDialog({super.key});

  @override
  State<AIChatDialog> createState() => _AIChatDialogState();
}

class _AIChatDialogState extends State<AIChatDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _response;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIAgentProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    return AlertDialog(
      title: const Text('AI Financial Assistant'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Ask me anything...'),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_response != null)
            Text(_response!),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
              _response = null;
            });

            final response = await aiProvider.sendMessage(
              message: _controller.text,
              transactions: transactionProvider.transactions,
            );

            setState(() {
              _isLoading = false;
              _response = response.response;
            });
          },
          child: const Text('Ask'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
