import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/ai_agent_provider.dart';
import 'transactions_screen.dart';
import 'ai_insights_screen.dart';
import 'add_transaction_screen.dart';
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
      const TransactionsScreen(),
      const AIInsightsScreen(),
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
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
                _generateInsights();
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
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'AI Insights',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        _generateInsights();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const BalanceCard(),
          const SizedBox(height: 20),
          const QuickStats(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _currentIndex = 1);
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const RecentTransactions(),
        ],
      ),
    );
  }
}
