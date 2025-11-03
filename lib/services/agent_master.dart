import 'dart:async';

import 'worker_agents.dart';

typedef UpdateCallback = void Function(String message);

class MasterAgent {
  /// Start a conversational flow. The [onUpdate] callback will be invoked with
  /// informational messages that should be shown in the chat UI.
  Future<Map<String, dynamic>> startConversation(
    String userMessage,
    UpdateCallback onUpdate, {
    Map<String, dynamic>? context,
  }) async {
    context ??= {};

    onUpdate('MasterAgent: Hi! I am SynFin Assistant. I can help you get a personal loan.');

    // Simple intent check
    if (userMessage.toLowerCase().contains('loan')) {
      onUpdate('MasterAgent: Sure — how much loan do you need?');
      // Wait for user to provide loan amount via context
    } else {
      onUpdate('MasterAgent: Tell me a bit about what you need — e.g., "I want a loan of 200000"');
    }

    // If caller passed loan info in context, proceed; else wait short time
    await Future.delayed(const Duration(milliseconds: 500));

    final loanAmount = context['loanAmount'] ?? _extractAmountFromText(userMessage);
    if (loanAmount == null) {
      onUpdate('MasterAgent: I didn\'t get the amount yet. Please type something like "Loan 150000"');
      return {'status': 'need_more_info'};
    }

    onUpdate('MasterAgent: Great — requested amount INR ${loanAmount.toStringAsFixed(2)}. I will initiate verification.');

    // Mock collecting basic details (in a real app we'd ask more)
    final customer = <String, dynamic>{
      'name': context['name'] ?? 'John Doe',
      'mobile': context['mobile'] ?? '9999999999',
      'employmentType': context['employmentType'] ?? 'salaried',
      'monthlySalary': context['monthlySalary'] ?? 50000.0,
    };

    onUpdate('Verification Agent: Validating KYC and fetching credit score...');
    final verification = await verifyCustomerKYC(customer);
    onUpdate('Verification Agent: ${verification.reason} (score: ${verification.creditScore})');

    if (!verification.success) {
      onUpdate('MasterAgent: Sorry, we cannot proceed: ${verification.reason}');
      return {'status': 'rejected', 'reason': verification.reason};
    }

    if (verification.needsSalarySlip) {
      onUpdate('MasterAgent: We need salary slip to continue (customer flagged as self-employed).');
      return {'status': 'needs_salary_slip'};
    }

    onUpdate('Underwriting Agent: Evaluating loan eligibility...');
    final underwriting = await underwriteLoan(
      creditScore: verification.creditScore,
      requestedAmount: loanAmount,
      monthlySalary: (customer['monthlySalary'] as double),
    );

    if (!underwriting.approved) {
      onUpdate('Underwriting Agent: Loan not approved. Note: ${underwriting.note}');
      return {'status': 'rejected', 'reason': underwriting.note};
    }

    onUpdate('Underwriting Agent: Approved INR ${underwriting.approvedAmount.toStringAsFixed(2)}');

    // Generate sanction letter
    onUpdate('Sanction Agent: Preparing sanction letter...');
    final letter = await generateSanctionLetter(
      customerName: customer['name'],
      amount: underwriting.approvedAmount,
      note: underwriting.note,
    );

    onUpdate('Sanction Agent: Sanction letter ready.');

    return {
      'status': 'approved',
      'approvedAmount': underwriting.approvedAmount,
      'sanctionLetter': letter,
    };
  }

  double? _extractAmountFromText(String text) {
    final reg = RegExp(r"(\d{5,})"); // crude: numbers with 5+ digits
    final m = reg.firstMatch(text.replaceAll(',', ''));
    if (m == null) return null;
    final num = double.tryParse(m.group(0)!);
    return num;
  }
}
