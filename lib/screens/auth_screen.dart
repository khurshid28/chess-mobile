import 'package:chess_park/theme/app_constants.dart';
import 'package:chess_park/theme/app_theme.dart';
import 'package:chess_park/widgets/glass_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:chess_park/providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  String _email = '';
  String _password = '';
  String _displayName = '';
  Country? _selectedCountry;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? errorMessage;

      if (_isLogin) {
        errorMessage = await authProvider.signIn(_email, _password);
      } else {
        errorMessage = await authProvider.signUp(
          _email,
          _password,
          _displayName,
          _selectedCountry?.countryCode
        );
      }

      if (mounted && errorMessage != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred. Please try again.'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (email.isEmpty || !email.contains('@')) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );
      return;
    }

    navigator.pop();

    final errorMessage = await authProvider.sendPasswordResetEmail(email);

    if (mounted) {
      final message = errorMessage ?? 'Password reset link sent to your email.';
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showForgotPasswordDialog() {

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Enter your email'),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            onPressed: _sendResetLink,
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    InputDecoration customInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
      );
    }

    return Scaffold(

      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppConstants.appLogo,
                  height: 120,

                  color: theme.colorScheme.primary.withAlpha(230),
                ),
                const SizedBox(height: 32),

                GlassPanel(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create Account',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        if (!_isLogin)
                          TextFormField(
                            key: const ValueKey('displayName'),
                            decoration: customInputDecoration('Username'),
                            validator: (value) => (value ?? '').isEmpty ? 'Please enter a name' : null,
                            onSaved: (value) => _displayName = value ?? '',
                          ),
                        if (!_isLogin) const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('email'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: customInputDecoration('Email Address'),
                          validator: (value) => !(value ?? '').contains('@') ? 'Invalid email' : null,
                          onSaved: (value) => _email = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('password'),
                          obscureText: true,
                          decoration: customInputDecoration('Password'),
                          validator: (value) => (value ?? '').length < 6 ? 'Password is too short' : null,
                          onSaved: (value) => _password = value ?? '',
                        ),
                        if (!_isLogin) const SizedBox(height: 20),
                        if (!_isLogin)
                          SizedBox(
                            width: double.infinity,

                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.flag_outlined, color: AppTheme.kColorTextSecondary),
                              label: Text(_selectedCountry?.name ?? 'Select Country', style: const TextStyle(color: AppTheme.kColorTextSecondary)),
                              onPressed: () {
                                showCountryPicker(
                                  context: context,
                                  onSelect: (Country country) {
                                    setState(() {
                                      _selectedCountry = country;
                                    });
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),

                                side: BorderSide(color: Colors.white.withAlpha(230)),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const CircularProgressIndicator(color: AppTheme.kColorAccent)
                        else
                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                              onPressed: _submitAuthForm,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                          ),
                        if (_isLogin)
                          TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.kColorTextSecondary)),
                          ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _switchAuthMode,
                          child: Text(_isLogin ? 'Create a new account' : 'I already have an account', style: const TextStyle(color: AppTheme.kColorAccent)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}