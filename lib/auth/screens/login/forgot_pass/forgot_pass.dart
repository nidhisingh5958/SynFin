import 'package:SynFin/features/auth/screens/login/forgot_pass/pass_otp_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SynFin/common/components/app_header.dart';
import 'package:SynFin/common/components/colors.dart';
import 'package:SynFin/services/auth/auth_repository.dart';
import 'package:SynFin/utils/routes/route_constants.dart';
import 'package:SynFin/utils/snackbar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const ForgotPasswordScreen({super.key, this.extra});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  late String _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    // First check if role is passed in through router
    if (widget.extra != null && widget.extra!.containsKey('role')) {
      _role = widget.extra!['role'];
    } else {
      // Otherwise load from shared preferences
      final prefs = await SharedPreferences.getInstance();
      _role = prefs.getString('userRole') ?? 'Patient'; // Default to Patient
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        elevation: 0,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Forgot Password",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Don't worry! It happens. Please enter the email address associated with your account to reset your password.",
                    style: TextStyle(fontSize: 14, color: grey600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                EnhancedForgotPassForm(role: _role),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnhancedForgotPassForm extends ConsumerStatefulWidget {
  final String role;

  const EnhancedForgotPassForm({super.key, required this.role});

  @override
  ConsumerState<EnhancedForgotPassForm> createState() =>
      _EnhancedForgotPassFormState();
}

class _EnhancedForgotPassFormState
    extends ConsumerState<EnhancedForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Use the Provider to get the AuthRepository instance
      final authRepository = ref.read(authRepositoryProvider);

      debugPrint('=== PASSWORD RESET FLOW START ===');
      debugPrint('Email: ${_emailController.text.trim()}');
      debugPrint('Role: ${widget.role}');

      // Request password reset
      final success = await authRepository.requestPasswordReset(
        context,
        _emailController.text.trim(),
        widget.role,
      );

      debugPrint('Password reset request result: $success');

      if (success && mounted) {
        debugPrint('SUCCESS: About to show OTP bottom sheet');

        // Add a small delay to ensure the snackbar is dismissed
        await Future.delayed(Duration(milliseconds: 500));

        if (mounted) {
          _showOtpBottomSheet();
        }
      } else {
        debugPrint('FAILED: Password reset request unsuccessful');
        if (mounted) {
          showSnackBar(
            context: context,
            message: 'Failed to send reset email. Please try again.',
          );
        }
      }
    } catch (e) {
      debugPrint('ERROR in _handleSubmit: ${e.toString()}');
      if (mounted) {
        showSnackBar(
          context: context,
          message: 'Failed to send password reset request. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOtpBottomSheet() {
    if (!mounted) {
      debugPrint('Widget not mounted, cannot show bottom sheet');
      return;
    }

    debugPrint('=== SHOWING OTP BOTTOM SHEET ===');
    debugPrint('Context mounted: ${context.mounted}');
    debugPrint('Role: ${widget.role}');
    debugPrint('Email: ${_emailController.text.trim()}');

    try {
      showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            isDismissible: true,
            enableDrag: true,
            useSafeArea: true, // Add this for better safe area handling
            builder: (BuildContext bottomSheetContext) {
              debugPrint('Bottom sheet builder executing');

              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: OtpEntrySheet(
                      identifier: _emailController.text.trim(),
                      onVerificationComplete: () async {
                        debugPrint('OTP verification completed successfully');

                        // Close the bottom sheet
                        if (Navigator.canPop(bottomSheetContext)) {
                          Navigator.of(bottomSheetContext).pop();
                        }

                        // Navigate to password reset screen
                        if (mounted) {
                          context.goNamed(
                            RouteConstants.passReset,
                            extra: {
                              'identifier': _emailController.text.trim(),
                              'role': widget.role,
                              'fromForgotPassword': true,
                            },
                          );
                        }
                      },
                      role: widget.role,
                      isForgotPassword: true,
                    ),
                  );
                },
              );
            },
          )
          .then((_) {
            debugPrint('Bottom sheet dismissed');
          })
          .catchError((error, stackTrace) {
            debugPrint('Error showing bottom sheet: $error');
            debugPrint('Stack trace: $stackTrace');
          });
    } catch (e, stackTrace) {
      debugPrint('Exception in _showOtpBottomSheet: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined, color: grey600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: grey600),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: grey600),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color2, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            style: TextStyle(fontSize: 14, color: black),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Send Reset Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password? ",
                style: TextStyle(fontSize: 14, color: grey600),
              ),
              GestureDetector(
                onTap: () => context.goNamed(RouteConstants.login),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
