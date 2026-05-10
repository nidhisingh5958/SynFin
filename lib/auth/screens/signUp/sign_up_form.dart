// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';

class SignUpForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const SignUpForm({super.key, this.extra});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailVerified = false;
  bool _showOtpField = false;
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isPhoneVerified = false;
  bool _showPhoneOtpField = false;
  final _phoneOtpController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChecked = false;
  bool _isLoading = false;
  bool _isVerifyingEmail = false;
  bool _isVerifyingPhone = false;

  String firstname = '';
  String lastname = '';
  String email = '';
  String phone = '';
  String password = '';
  Country? country;
  late String _role;

  bool _canResendEmailOtp = false;
  bool _canResendPhoneOtp = false;
  int _emailResendSeconds = 30; // Cooldown period in seconds
  int _phoneResendSeconds = 30;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    // Initialize with India as default country
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

  // submit form
  void _submitForm() async {
    if (!_formKey.currentState!.validate() || !_isChecked) {
      // Show message if terms not checked
      if (!_isChecked) {
        showSnackBar(
          context: context,
          message: 'Please accept the Terms and Conditions',
        );
      }
      return;
    }

    // Only proceed if both email and phone are verified
    if (!_isEmailVerified) {
      showSnackBar(
        context: context,
        message: 'Please verify your email before continuing',
      );
      return;
    }

    if (!_isPhoneVerified) {
      showSnackBar(
        context: context,
        message: 'Please verify your phone number before continuing',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackBar(context: context, message: 'Passwords do not match');
      return;
    }

    if (country == null) {
      showSnackBar(context: context, message: 'Please select a country code');
      return;
    }

    try {
      setState(() => _isLoading = true);

      final signUpController = ref.read(signUpControllerProvider);
      // Fixed: Pass the authStateProvider.notifier directly instead of using a stored variable
      await signUpController.signUp(
        context: context,
        firstName: _firstnameController.text.toLowerCase(),
        lastName: _lastnameController.text.toLowerCase(),
        email: _emailController.text,
        countryCode: '+${country!.phoneCode}',
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        role: _role,
        notifier: ref.read(authStateProvider.notifier),
      );
    } catch (e) {
      showSnackBar(
        context: context,
        message: 'Error during signup: ${e.toString()}',
      );
      debugPrint('$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _firstnameController.dispose();
    _lastnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _phoneOtpController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // And update the timer methods to check for disposed state:
  void startEmailResendTimer() {
    if (_disposed) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (_disposed) return;
      if (_emailResendSeconds > 0 && _showOtpField && !_isEmailVerified) {
        setState(() {
          _emailResendSeconds--;
        });
        startEmailResendTimer();
      } else if (_showOtpField && !_isEmailVerified) {
        setState(() {
          _canResendEmailOtp = true;
        });
      }
    });
  }

  void startPhoneResendTimer() {
    if (_disposed) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (_disposed) return;
      if (_phoneResendSeconds > 0 && _showPhoneOtpField && !_isPhoneVerified) {
        setState(() {
          _phoneResendSeconds--;
        });
        startPhoneResendTimer();
      } else if (_showPhoneOtpField && !_isPhoneVerified) {
        setState(() {
          _canResendPhoneOtp = true;
        });
      }
    });
  }

  Future<void> _requestEmailOtp() async {
    // Validate email before showing OTP field
    final emailValue = _emailController.text;
    if (emailValue.isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailValue)) {
      showSnackBar(context: context, message: 'Please enter a valid email');
      return;
    }

    try {
      setState(() {
        _showOtpField = true;
        _canResendEmailOtp = false;
        _emailResendSeconds = 30;
      });

      startEmailResendTimer();

      final signUpController = ref.read(signUpControllerProvider);
      bool sent = await signUpController.sendSignupOtp(
        context: context,
        identifier: _emailController.text,
      );

      if (sent) {
        showSnackBar(context: context, message: 'OTP sent to your email');
      }
    } catch (e) {
      setState(() {
        _showOtpField = false;
      });
      showSnackBar(
        context: context,
        message: 'Error sending OTP: ${e.toString()}',
      );
    }
  }

  Future<void> _verifyEmailOtp() async {
    setState(() {
      _isVerifyingEmail = true;
    });

    try {
      String plainOtp = _otpController.text;

      if (plainOtp.isEmpty) {
        showSnackBar(context: context, message: 'Please enter OTP');
        setState(() {
          _isVerifyingEmail = false;
        });
        return;
      }

      final signUpController = ref.read(signUpControllerProvider);
      bool verified = await signUpController.verifySignupOtp(
        context: context,
        identifier: _emailController.text,
        plainOtp: _otpController.text,
      );

      if (verified) {
        setState(() {
          _isEmailVerified = true;
          _showOtpField = false; // Hide OTP field after verification
        });
        showSnackBar(context: context, message: 'Email verified successfully');
      }
    } catch (e) {
      debugPrint("Email OTP verification error: ${e.toString()}");
      showSnackBar(
        context: context,
        message: 'Error verifying OTP: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isVerifyingEmail = false;
      });
    }
  }

  //  request Phone OTP
  Future<void> _requestPhoneOtp() async {
    // Validate phone before showing OTP field
    final phoneValue = _phoneController.text;
    if (phoneValue.isEmpty) {
      showSnackBar(
        context: context,
        message: 'Please enter a valid phone number',
      );
      return;
    }

    if (country == null) {
      showSnackBar(context: context, message: 'Please select a country code');
      return;
    }

    try {
      setState(() {
        _showPhoneOtpField = true;
        _canResendPhoneOtp = false;
        _phoneResendSeconds = 30;
      });

      // Start the resend timer
      startPhoneResendTimer();

      final signUpController = ref.read(signUpControllerProvider);
      bool sent = await signUpController.sendSignupOtp(
        context: context,
        identifier: _phoneController.text,
        countryCode: '+${country!.phoneCode}',
      );

      if (sent) {
        showSnackBar(
          context: context,
          message: 'OTP sent to your phone number',
        );
      }
    } catch (e) {
      setState(() {
        _showPhoneOtpField = false;
      });
      showSnackBar(
        context: context,
        message: 'Error sending OTP: ${e.toString()}',
      );
    }
  }

  Future<void> _verifyPhoneOtp() async {
    setState(() {
      _isVerifyingPhone = true;
    });

    try {
      String plainOtp = _phoneOtpController.text;

      if (plainOtp.isEmpty) {
        showSnackBar(context: context, message: 'Please enter OTP');
        setState(() {
          _isVerifyingPhone = false;
        });
        return;
      }

      final signUpController = ref.read(signUpControllerProvider);
      bool verified = await signUpController.verifySignupOtp(
        context: context,
        identifier: _phoneController.text,
        plainOtp: _phoneOtpController.text,
        countryCode: '+${country!.phoneCode}',
      );

      if (verified) {
        setState(() {
          _isPhoneVerified = true;
          _showPhoneOtpField = false; // Hide OTP field after verification
        });
        showSnackBar(
          context: context,
          message: 'Phone number verified successfully',
        );
      }
    } catch (e) {
      debugPrint("Phone number OTP verification error: ${e.toString()}");
      showSnackBar(
        context: context,
        message: 'Error verifying OTP: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isVerifyingPhone = false;
      });
    }
  }

  // Method to show country picker
  void _showCountryPicker() {
    showCustomCountryPicker(
      context: context,
      onSelect: (Country selectedCountry) {
        setState(() {
          country = selectedCountry;
          // If we're changing country and we're already verified, we need to reverify
          if (_isPhoneVerified) {
            _isPhoneVerified = false;
          }
        });
      },
      initialCountry: country,
      countryNameStyle: TextStyle(fontSize: 16, color: black),
      countryCodeStyle: TextStyle(
        fontSize: 16,
        color: grey600,
        fontWeight: FontWeight.w500,
      ),
      searchBarColor: Colors.grey[100],
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(20),
      searchHintText: 'Search country',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNameField(),
          const SizedBox(height: 14),
          _buildEmailFieldWithVerification(),
          const SizedBox(height: 14),
          _buildPhoneNumberField(),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _passwordController,
            hint: 'Password',
            isVisible: _isPasswordVisible,
            onVisibilityToggle: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          const SizedBox(height: 14),
          _buildPasswordField(
            controller: _confirmPasswordController,
            hint: 'Confirm Password',
            isVisible: _isConfirmPasswordVisible,
            onVisibilityToggle: () {
              setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              );
            },
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTermsCheckbox(),
          const SizedBox(height: 20),
          _buildSignUpButton(),
        ],
      ),
    );
  }

  // name field
  Widget _buildNameField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstnameController,
            decoration: InputDecoration(hintText: 'First Name'),
            style: TextStyle(fontSize: 14, color: black),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            onSaved: (value) => firstname = value!,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _lastnameController,
            decoration: InputDecoration(hintText: 'Last Name'),
            style: TextStyle(fontSize: 14, color: black),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            onSaved: (value) => lastname = value!,
          ),
        ),
      ],
    );
  }

  // email field with verification
  Widget _buildEmailFieldWithVerification() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  suffixIcon: _isEmailVerified
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : (!_showOtpField && _emailController.text.isNotEmpty
                            ? TextButton(
                                onPressed: _requestEmailOtp,
                                child: Text(
                                  'Verify',
                                  style: TextStyle(
                                    color: grey600,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : null),
                ),
                style: TextStyle(fontSize: 14, color: black),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  if (!_isEmailVerified) {
                    return 'Please verify your email';
                  }
                  return null;
                },
                onChanged: (value) {
                  // If email is changed after verification, reset verification
                  if (_isEmailVerified) {
                    setState(() {
                      _isEmailVerified = false;
                    });
                  }
                },
                onSaved: (value) => email = value!,
              ),
            ),
          ],
        ),

        // OTP field that appears conditionally
        if (_showOtpField)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          hintText: 'Enter OTP',
                          hintStyle: TextStyle(fontSize: 14, color: grey600),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(fontSize: 16, color: black),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isVerifyingEmail ? null : _verifyEmailOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: _isVerifyingEmail
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: white,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(color: white, fontSize: 14),
                            ),
                    ),
                  ],
                ),
                // Add the Resend OTP row
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive OTP?',
                        style: TextStyle(
                          fontSize: 12,
                          color: black.withValues(alpha: .8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _canResendEmailOtp
                          ? GestureDetector(
                              onTap: _requestEmailOtp,
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              'Resend in $_emailResendSeconds s',
                              style: TextStyle(fontSize: 12, color: grey600),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // phone number field with custom country picker
  Widget _buildPhoneNumberField() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code selector
            InkWell(
              onTap: _showCountryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      country?.flagEmoji ?? '🇮🇳',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '+${country?.phoneCode ?? '91'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: grey600),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone number input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  suffixIcon: _isPhoneVerified
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : (!_showPhoneOtpField && _phoneController.text.isNotEmpty
                            ? TextButton(
                                onPressed: _requestPhoneOtp,
                                child: Text(
                                  'Verify',
                                  style: TextStyle(
                                    color: grey600,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : null),
                ),
                style: TextStyle(fontSize: 14, color: black),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!_isPhoneVerified) {
                    return 'Please verify your phone number';
                  }
                  return null;
                },
                onChanged: (value) {
                  // If phone is changed after verification, reset verification
                  if (_isPhoneVerified) {
                    setState(() {
                      _isPhoneVerified = false;
                    });
                  }
                },
                onSaved: (value) => phone = value!,
              ),
            ),
          ],
        ),

        // OTP field that appears conditionally
        if (_showPhoneOtpField)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneOtpController,
                        decoration: InputDecoration(
                          hintText: 'Enter Phone OTP',
                          hintStyle: TextStyle(fontSize: 14, color: grey600),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(fontSize: 16, color: black),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isVerifyingPhone ? null : _verifyPhoneOtp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: _isVerifyingPhone
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: white,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(color: white, fontSize: 14),
                            ),
                    ),
                  ],
                ),
                // Resend OTP button
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive OTP?',
                        style: TextStyle(
                          fontSize: 12,
                          color: black.withValues(alpha: .8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _canResendPhoneOtp
                          ? GestureDetector(
                              onTap: _requestPhoneOtp,
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: grey600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              'Resend in $_phoneResendSeconds s',
                              style: TextStyle(fontSize: 12, color: grey600),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // password field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: black.withValues(alpha: .8),
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      style: TextStyle(fontSize: 14, color: black),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Password must contain at least one uppercase letter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Password must contain at least one number';
            }
            return null;
          },
    );
  }

  // terms and conditions
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (value) => setState(() => _isChecked = value!),
          activeColor: grey600,
          focusColor: grey600,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isChecked = !_isChecked),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: black.withValues(alpha: .8),
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(text: 'Accept '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // sign up button
  Widget _buildSignUpButton() {
    return SizedBox(
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const CircularProgressIndicator(color: white)
            : const Text('Sign Up'),
      ),
    );
  }
}
