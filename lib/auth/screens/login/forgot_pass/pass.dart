// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:SynFin/services/auth/auth_repository.dart';
import 'package:SynFin/common/components/colors.dart';
import 'package:SynFin/utils/providers/auth_providers.dart';
import 'package:SynFin/utils/routes/route_constants.dart';
import 'package:SynFin/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PasswordInputScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const PasswordInputScreen({super.key, this.extra});

  @override
  ConsumerState<PasswordInputScreen> createState() =>
      _PasswordInputScreenState();
}

class _PasswordInputScreenState extends ConsumerState<PasswordInputScreen>
    with TickerProviderStateMixin {
  late final authController;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  String _identifier = '';
  String _role = '';
  bool _isDataLoaded = false;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    authController = ref.read(authStateProvider.notifier);

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _loadPasswordResetData();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.removeListener(_checkPasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  /// Load password reset data from SharedPreferences or route params
  Future<void> _loadPasswordResetData() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);

      // First try to get data from the verified OTP session
      final resetData = await authRepository.getPasswordResetData();

      if (resetData != null) {
        // Use data from verified OTP session
        setState(() {
          _identifier = resetData['identifier'] ?? '';
          _role = resetData['role'] ?? 'Patient';
          _isDataLoaded = true;
        });

        debugPrint('Loaded password reset data from OTP session:');
        debugPrint('Identifier: $_identifier');
        debugPrint('Role: $_role');

        // Start animations after data is loaded
        _animationController.forward();
      } else {
        // Fallback to route parameters (if passed directly)
        if (widget.extra != null) {
          setState(() {
            _identifier = widget.extra!['identifier'] ?? '';
            _role = widget.extra!['role'] ?? 'Patient';
            _isDataLoaded = true;
          });

          debugPrint('Loaded password reset data from route params:');
          debugPrint('Identifier: $_identifier');
          debugPrint('Role: $_role');

          // Start animations after data is loaded
          _animationController.forward();
        } else {
          // No valid session or route data
          debugPrint('No valid password reset session found');
          if (mounted) {
            showSnackBar(
              context: context,
              message: 'Invalid session. Please start password reset again.',
            );
            context.goNamed(RouteConstants.login);
          }
          return;
        }
      }

      // Validate that we have required data
      if (_identifier.isEmpty) {
        debugPrint('Missing identifier in password reset data');
        if (mounted) {
          showSnackBar(
            context: context,
            message: 'Invalid session. Please start password reset again.',
          );
          context.goNamed(RouteConstants.login);
        }
      }
    } catch (e) {
      debugPrint('Error loading password reset data: ${e.toString()}');
      if (mounted) {
        showSnackBar(
          context: context,
          message: 'Session error. Please start password reset again.',
        );
        context.goNamed(RouteConstants.login);
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackBar(context: context, message: 'Passwords do not match');
      return;
    }

    // Validate that we have the required data
    if (_identifier.isEmpty) {
      showSnackBar(
        context: context,
        message: 'Invalid session. Please start password reset again.',
      );
      context.goNamed(RouteConstants.login);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final authRepository = ref.read(authRepositoryProvider);

      // Additional validation
      if (_passwordController.text.length < 8) {
        showSnackBar(
          context: context,
          message: 'Password must be at least 8 characters long',
        );
        return;
      }

      debugPrint('Calling resetPassword with:');
      debugPrint('Identifier: $_identifier');
      debugPrint('Role: $_role');
      debugPrint('Password length: ${_passwordController.text.length}');

      await authRepository.resetPassword(
        context: context,
        identifier: _identifier,
        password: _passwordController.text,
        role: _role,
        notifier: authController,
      );
    } catch (e) {
      if (mounted) {
        debugPrint('Password reset error: ${e.toString()}');
        showSnackBar(context: context, message: 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBackPressed() async {
    // Clear password reset data when going back
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.clearPasswordResetData();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleCancelPressed() async {
    // Clear password reset data when canceling
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.clearPasswordResetData();

    if (mounted) {
      context.goNamed(RouteConstants.login);
    }
  }

  Widget _buildPasswordStrengthIndicator() {
    final requirements = [
      {'text': 'At least 8 characters', 'met': _hasMinLength},
      {'text': 'Uppercase letter', 'met': _hasUppercase},
      {'text': 'Lowercase letter', 'met': _hasLowercase},
      {'text': 'Number', 'met': _hasNumbers},
      {'text': 'Special character', 'met': _hasSpecialChar},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Requirements',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...requirements.map(
              (req) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: req['met'] as bool
                            ? Colors.green
                            : Colors.grey.shade300,
                      ),
                      child: req['met'] as bool
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      req['text'] as String,
                      style: TextStyle(
                        color: req['met'] as bool
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        fontWeight: req['met'] as bool
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          filled: true,
          suffixIcon: IconButton(
            splashRadius: 20,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey.shade600,
            ),
            onPressed: onVisibilityToggle,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isDataLoaded
          ? SafeArea(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Section
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: black.withValues(alpha: .2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock_reset,
                                      size: 32,
                                      color: black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Create New Password',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please create a strong password for your account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: grey800.withValues(alpha: .9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Password Fields
                            _buildPasswordField(
                              controller: _passwordController,
                              label: 'New Password',
                              isVisible: _isPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              isVisible: _isConfirmPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Password Strength Indicator
                            if (_passwordController.text.isNotEmpty)
                              _buildPasswordStrengthIndicator(),

                            const SizedBox(height: 32),

                            // Reset Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: .8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: .3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Reset Password',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Cancel Button
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleCancelPressed,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
