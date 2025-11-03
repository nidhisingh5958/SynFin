import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/ai_agent_provider.dart';
import '../providers/loan_provider.dart';
import 'chatbot_screen.dart';
import 'loan_dashboard_screen.dart';
import 'loan_applications_screen.dart';
import 'add_loan_screen.dart';
import 'profile_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_stats.dart';
import '../widgets/recent_transactions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  void _generateInsights() {
    Future.delayed(const Duration(milliseconds: 500), () {
      final transactionProvider = context.read<TransactionProvider>();
      final aiProvider = context.read<AIAgentProvider>();

      if (transactionProvider.transactions.isNotEmpty) {
        aiProvider.generateInsights(
          transactionProvider.transactions,
          5000.0, // Default monthly budget
        );
      }
    });
  }

  // Logout handled in ProfileScreen

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeContent(),
      const LoanDashboardScreen(),
      const LoanApplicationsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SynFin'),
        elevation: 0,
        actions: [
          Consumer<AIAgentProvider>(
            builder: (context, aiProvider, _) {
              final unreadCount = aiProvider.unreadInsightsCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    onPressed: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Talk to Sales Assistant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotScreen()),
              );
            },
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddLoanScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Applications',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to SynFin Loan Platform', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Use the + button to create a new loan application or open the chat assistant to process sanctions.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Applications',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _currentIndex = 2);
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Consumer<LoanProvider>(
            builder: (context, loanProvider, _) {
              final apps = loanProvider.applications;
              if (apps.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text('No applications yet'),
                    ],
                  ),
                );
              }

              return Column(
                children: apps.take(4).map((a) {
                  return Card(
                    child: ListTile(
                      title: Text(a.applicantName),
                      subtitle: Text('INR ${a.requestedAmount.toStringAsFixed(0)} • ${a.employmentType}'),
                      trailing: Text(a.status, style: TextStyle(color: a.status == 'approved' ? Colors.green : (a.status == 'rejected' ? Colors.red : Colors.orange))),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => ChatbotScreen(
                              initialMessage: 'Process loan ${a.requestedAmount.toStringAsFixed(0)} for ${a.applicantName}',
                              initialContext: {
                                'name': a.applicantName,
                                'loanAmount': a.requestedAmount,
                                'monthlySalary': a.monthlySalary,
                                'employmentType': a.employmentType,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
