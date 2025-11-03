import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/loan_application.dart';

class LoanProvider with ChangeNotifier {
  final List<LoanApplication> _applications = [];
  final _uuid = const Uuid();

  List<LoanApplication> get applications => List.unmodifiable(_applications);

  void addApplication({
    required String name,
    required double requestedAmount,
    required double monthlySalary,
    required String employmentType,
  }) {
    final app = LoanApplication(
      id: _uuid.v4(),
      applicantName: name,
      requestedAmount: requestedAmount,
      monthlySalary: monthlySalary,
      employmentType: employmentType,
    );
    _applications.add(app);
    notifyListeners();
  }

  void updateStatus(String id, String status, {String? sanctionLetter}) {
    final idx = _applications.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    _applications[idx].status = status;
    if (sanctionLetter != null) {
      _applications[idx].sanctionLetter = sanctionLetter;
    }
    notifyListeners();
  }

  LoanApplication? getById(String id) {
    try {
      return _applications.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
