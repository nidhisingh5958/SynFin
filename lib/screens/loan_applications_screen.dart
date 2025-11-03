import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import '../models/loan_application.dart';
import 'chatbot_screen.dart';

class LoanApplicationsScreen extends StatelessWidget {
  const LoanApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Applications')),
      body: Consumer<LoanProvider>(
        builder: (context, provider, _) {
          final apps = provider.applications;
          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('No loan applications yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final a = apps[index];
              return Card(
                child: ListTile(
                  title: Text(a.applicantName),
                  subtitle: Text('Amount: INR ${a.requestedAmount.toStringAsFixed(0)} • ${a.employmentType}'),
                  trailing: Text(a.status, style: TextStyle(color: _statusColor(a.status))),
                  onTap: () {
                    // open chat with context to continue sanctioning for this application
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
            },
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
