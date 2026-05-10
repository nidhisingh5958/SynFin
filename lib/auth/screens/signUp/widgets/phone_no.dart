import 'package:flutter/services.dart';
import 'dart:math' as math;

// Phone number formatter
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var formattedValue = '';

    if (digitsOnly.length <= 3) {
      formattedValue = digitsOnly;
    } else if (digitsOnly.length <= 6) {
      formattedValue =
          '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    } else {
      formattedValue =
          '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(
        6,
        math.min(10, digitsOnly.length),
      )}';
    }

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
