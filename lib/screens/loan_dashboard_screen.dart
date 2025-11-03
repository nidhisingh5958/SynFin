import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import 'loan_applications_screen.dart';

class LoanDashboardScreen extends StatelessWidget {
  const LoanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanProvider>();
    final total = provider.applications.length;
    final approved = provider.applications.where((a) => a.status == 'approved').length;
    final rejected = provider.applications.where((a) => a.status == 'rejected').length;

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
                  Text('Loan Dashboard', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCard('Total', total.toString(), context),
                      _statCard('Approved', approved.toString(), context),
                      _statCard('Rejected', rejected.toString(), context),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('View Applications'),
            subtitle: const Text('See all loan applications and statuses'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const LoanApplicationsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
