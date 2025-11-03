import 'dart:math';

class VerificationResult {
  final bool success;
  final String reason;
  final int creditScore;
  final bool needsSalarySlip;

  VerificationResult({
    required this.success,
    required this.reason,
    required this.creditScore,
    required this.needsSalarySlip,
  });
}

class UnderwritingResult {
  final bool approved;
  final double approvedAmount;
  final String note;

  UnderwritingResult({
    required this.approved,
    required this.approvedAmount,
    required this.note,
  });
}

/// Mock verification agent. Simulates KYC + credit score fetch.
Future<VerificationResult> verifyCustomerKYC(Map<String, dynamic> data) async {
  // simulate network delay
  await Future.delayed(const Duration(seconds: 2));

  // Simple deterministic mock: base credit score on name length + random
  final name = (data['name'] ?? '') as String;
  final base = name.length * 6;
  final rand = Random(name.length + (data['mobile']?.hashCode ?? 0));
  final creditScore = 300 + (base % 300) + rand.nextInt(200);

  bool needsSalarySlip = false;
  String reason = 'KYC verified';
  bool success = true;

  if ((data['employmentType'] ?? '').toString().toLowerCase().contains('self')) {
    needsSalarySlip = true;
    reason = 'Self-employed - salary proof recommended';
  }

  // Simple rule: low score -> fail
  if (creditScore < 400) {
    success = false;
    reason = 'Credit score too low';
  }

  return VerificationResult(
    success: success,
    reason: reason,
    creditScore: creditScore,
    needsSalarySlip: needsSalarySlip,
  );
}

/// Mock underwriting agent: decides approval based on credit score and requested amount.
Future<UnderwritingResult> underwriteLoan({
  required int creditScore,
  required double requestedAmount,
  required double monthlySalary,
}) async {
  await Future.delayed(const Duration(seconds: 2));

  // Simple rules:
  // - creditScore >= 700 -> approve up to requestedAmount
  // - creditScore 600-699 -> approve up to 75%
  // - creditScore 500-599 -> approve up to 50% if EMI < 50% salary
  // - else reject

  double approved = 0;
  String note = '';
  bool approvedFlag = false;

  if (creditScore >= 700) {
    approved = requestedAmount;
    approvedFlag = true;
    note = 'Approved at best terms';
  } else if (creditScore >= 600) {
    approved = requestedAmount * 0.75;
    approvedFlag = true;
    note = 'Partially approved due to medium score';
  } else if (creditScore >= 500) {
    // check EMI heuristic
    final monthlyEmi = _estimateEmi(requestedAmount);
    if (monthlyEmi <= monthlySalary * 0.5) {
      approved = requestedAmount * 0.5;
      approvedFlag = true;
      note = 'Limited approval with salary constraint';
    } else {
      approvedFlag = false;
      note = 'EMI too high compared to salary';
    }
  } else {
    approvedFlag = false;
    note = 'Credit score too low for underwriting';
  }

  return UnderwritingResult(
    approved: approvedFlag,
    approvedAmount: approved,
    note: note,
  );
}

double _estimateEmi(double loanAmount, {int tenureMonths = 36, double rate = 0.12}) {
  // Simple EMI formula approximation
  final r = rate / 12;
  final n = tenureMonths;
  if (r == 0) return loanAmount / n;
  final emi = (loanAmount * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  return emi;
}

/// Mock sanction letter generator: returns a simple string representing a PDF path or base64.
Future<String> generateSanctionLetter({
  required String customerName,
  required double amount,
  required String note,
}) async {
  await Future.delayed(const Duration(seconds: 1));
  final content = 'Sanction Letter\nCustomer: $customerName\nAmount: INR ${amount.toStringAsFixed(2)}\nNote: $note\nGenerated: ${DateTime.now()}';
  // In a real app we'd create a PDF. Here return the content as a placeholder.
  return content;
}
