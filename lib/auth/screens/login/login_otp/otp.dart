// ignore_for_file: use_build_context_synchronously

import 'package:SynFin/common/components/app_header.dart';
import 'package:SynFin/common/components/colors.dart';
import 'package:SynFin/features/auth/screens/login/login_otp/otp_sheet.dart';
import 'package:SynFin/utils/providers/auth_controllers.dart';
import 'package:SynFin/utils/providers/auth_providers.dart';
import 'package:SynFin/utils/routes/route_constants.dart';
import 'package:SynFin/utils/snackbar.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const OtpScreen({this.extra, super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _countryCodeController = TextEditingController(text: '+91');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  Country? country;
  late String _role;

  // enum to track login method
  LoginMethod _loginMethod = LoginMethod.email;

  @override
  void initState() {
    super.initState();
    _loadRole();
    country = Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'India',
      example: '9123456789',
      displayName: 'India (IN) [+91]',
      displayNameNoCountryCode: 'India (IN)',
      e164Key: '91-IN-0',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
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

  final _formKey = GlobalKey<FormState>();

  Future<void> _sendOTP() async {
    if ((_loginMethod == LoginMethod.email && _emailController.text.isEmpty) ||
        (_loginMethod == LoginMethod.phone && _phoneController.text.isEmpty)) {
      showSnackBar(
        context: context,
        message:
            'Please enter your ${_loginMethod == LoginMethod.email ? "email" : "phone number"}',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_formKey.currentState!.validate()) {
        final otpController = ref.read(loginWithOtpControllerProvider);
        await otpController.sendOtp(
          context: context,
          identifier: _loginMethod == LoginMethod.email
              ? _emailController.text
              : _phoneController.text,
          role: _role,
          countryCode: _loginMethod == LoginMethod.phone
              ? _countryCodeController.text
              : null,
        );

        showSnackBar(context: context, message: 'OTP sent successfully');
        _showOtpBottomSheet();
      }
    } catch (e) {
      showSnackBar(
        context: context,
        message: 'Failed to send OTP. Please try again.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to show the OTP entry bottom sheet
  void _showOtpBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return OtpEntrySheet(
          role: _role,
          identifier: _loginMethod == LoginMethod.email
              ? _emailController.text
              : _phoneController.text,
          countryCode: _loginMethod == LoginMethod.phone
              ? _countryCodeController.text
              : null,
          onVerificationComplete: () async {
            // First close the bottom sheet to prevent context issues
            Navigator.of(context).pop();

            // Then set the authentication state
            ref.read(authStateProvider.notifier).setAuthenticated(true, _role);

            // Show success message
            if (mounted) {
              showSnackBar(
                context: context,
                message: 'OTP verified successfully',
              );
              // Redirect based on user role
              if (_role == 'Doctor') {
                context.go(RouteConstants.doctorHome);
              } else {
                context.go(RouteConstants.home);
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(onBackPressed: () => Navigator.pop(context)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      // headings and intro
                      Text(
                        "OTP Verification",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "To sign in using OTP, please enter your phone number or email.",
                        style: TextStyle(fontSize: 14, color: grey600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildSmartInputField(),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildSendOtpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Combined input field with auto-detection
        TextFormField(
          controller: _loginMethod == LoginMethod.email
              ? _emailController
              : _phoneController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onChanged: (value) {
            // Auto-detect if input is email or phone
            if (value.isNotEmpty) {
              // Check if input contains @ symbol - likely an email
              if (value.contains('@') || value.contains(RegExp(r'[a-z]'))) {
                if (_loginMethod != LoginMethod.email) {
                  setState(() {
                    _loginMethod = LoginMethod.email;
                    _emailController.text = value;
                  });
                }
              }
              // Check if input has digits only - likely a phone number
              else if (RegExp(r'^[0-9+\s]+$').hasMatch(value)) {
                if (_loginMethod != LoginMethod.phone) {
                  setState(() {
                    _loginMethod = LoginMethod.phone;
                    _phoneController.text = value.replaceAll(
                      RegExp(r'[^\d]'),
                      '',
                    );
                  });
                }
              }
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email or phone number';
            }

            if (_loginMethod == LoginMethod.email) {
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            } else {
              if (value.length < 5) {
                // Minimal phone validation
                return 'Please enter a valid phone number';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your email or phone number',
            prefixIcon: _loginMethod == LoginMethod.phone
                ? GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          setState(() {
                            this.country = country;
                            _countryCodeController.text =
                                '+${country.phoneCode}';
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        _countryCodeController.text,
                        style: TextStyle(
                          color: black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    Icons.alternate_email,
                    color: black.withValues(alpha: .8),
                  ),
            suffixIcon: _loginMethod == LoginMethod.email
                ? Icon(Icons.email_outlined, color: black.withValues(alpha: .8))
                : Icon(Icons.phone_android, color: black.withValues(alpha: .8)),
          ),
          style: TextStyle(fontSize: 14, color: black),
        ),

        // Input type indicator
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.only(top: 8),
          child: Text(
            _loginMethod == LoginMethod.email
                ? 'Using email address'
                : 'Using phone number',
            style: TextStyle(
              color: black.withValues(alpha: .8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _sendOTP,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              'Send OTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}

enum LoginMethod { email, phone }
