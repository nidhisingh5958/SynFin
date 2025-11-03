import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import 'chatbot_screen.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _salary = TextEditingController();
  String _employment = 'salaried';

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _salary.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<LoanProvider>();
    final name = _name.text.trim();
    final amount = double.parse(_amount.text.trim());
    final salary = double.parse(_salary.text.trim());

    provider.addApplication(
      name: name,
      requestedAmount: amount,
      monthlySalary: salary,
      employmentType: _employment,
    );

    // Open chatbot to process this application
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (c) => ChatbotScreen(
          initialMessage: 'Process loan $amount for $name',
          initialContext: {
            'name': name,
            'loanAmount': amount,
            'monthlySalary': salary,
            'employmentType': _employment,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Loan Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Applicant Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Requested Amount'),
                validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salary,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Salary'),
                validator: (v) => v == null || v.isEmpty ? 'Enter salary' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _employment,
                items: const [
                  DropdownMenuItem(value: 'salaried', child: Text('Salaried')),
                  DropdownMenuItem(value: 'self-employed', child: Text('Self-employed')),
                ],
                onChanged: (v) => setState(() => _employment = v ?? 'salaried'),
                decoration: const InputDecoration(labelText: 'Employment Type'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Application & Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
