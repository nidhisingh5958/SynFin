import 'package:SynFin/common/components/colors.dart';
import 'package:SynFin/utils/providers/auth_controllers.dart';
import 'package:SynFin/utils/providers/auth_providers.dart';
import 'package:SynFin/utils/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';

class LoginForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const LoginForm({super.key, this.extra});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+91');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isPasswordVisible = false;
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
    _passwordController.dispose();
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

  Future<void> _handleLogin() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() => _isLoading = true);

        final loginController = ref.read(loginControllerProvider);

        // Pass the login method to the sign-up function
        await loginController.signIn(
          context: context,
          input: _loginMethod == LoginMethod.email
              ? _emailController.text
              : _phoneController.text,
          password: _passwordController.text,
          role: _role,
          countryCode: _loginMethod == LoginMethod.phone
              ? _countryCodeController.text
              : null,
          notifier: ref.read(authStateProvider.notifier),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      setState(() => _isLoading = false);
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Smart input field that auto-detects input type
          _buildSmartInputField(),

          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 14),
          _buildForgotPassword(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 30),
          _buildLoginWithOtp(),
        ],
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

  // Password field
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      validator: _validatePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: black.withValues(alpha: .8),
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
      ),
      style: TextStyle(fontSize: 14, color: black),
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: () => context.pushNamed(RouteConstants.forgotPass),
          child: Text(
            'Forgot Password?',
            style: TextStyle(color: black, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildLoginWithOtp() {
    return Center(
      child: TextButton(
        onPressed: () {
          context.goNamed(RouteConstants.otp);
        },
        child: Text(
          'Sign In with OTP',
          style: TextStyle(fontSize: 16, color: black.withValues(alpha: .8)),
        ),
      ),
    );
  }
}

enum LoginMethod { email, phone }

// error message
class FormError extends StatelessWidget {
  const FormError({super.key, required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        errors.length,
        (index) => formErrorText(error: errors[index]),
      ),
    );
  }

  Row formErrorText({error}) {
    return Row(
      children: [
        Image(image: AssetImage("assets/icons/error.png")),
        SizedBox(width: 20),
        Text(error),
      ],
    );
  }
}
