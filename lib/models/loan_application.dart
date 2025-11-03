class LoanApplication {
  final String id;
  final String applicantName;
  final double requestedAmount;
  final double monthlySalary;
  final String employmentType;
  String status; // pending / approved / rejected
  String? sanctionLetter;

  LoanApplication({
    required this.id,
    required this.applicantName,
    required this.requestedAmount,
    required this.monthlySalary,
    required this.employmentType,
    this.status = 'pending',
    this.sanctionLetter,
  });
}
