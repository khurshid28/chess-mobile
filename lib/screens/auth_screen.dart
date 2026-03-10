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

    InputDecoration customInputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.kColorTextSecondary, size: 20),
        labelStyle: TextStyle(color: AppTheme.kColorTextSecondary),
        filled: true,
        fillColor: AppTheme.kColorTextPrimary.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Chess pawn logo with glow effect
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.primary.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/piece_sets/staunton/wP.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.kColorTextPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Sign in to continue' : 'Create your account',
                    style: TextStyle(
                      color: AppTheme.kColorTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Form
                  GlassPanel(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Username field (only for sign up)
                          if (!_isLogin) ...[
                            TextFormField(
                              key: const ValueKey('displayName'),
                              style: TextStyle(color: AppTheme.kColorTextPrimary),
                              decoration: customInputDecoration('Username', Icons.person_outline),
                              validator: (value) => (value ?? '').isEmpty ? 'Please enter a username' : null,
                              onSaved: (value) => _displayName = value ?? '',
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Email field
                          TextFormField(
                            key: const ValueKey('email'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: AppTheme.kColorTextPrimary),
                            decoration: customInputDecoration('Email Address', Icons.email_outlined),
                            validator: (value) => !(value ?? '').contains('@') ? 'Enter a valid email' : null,
                            onSaved: (value) => _email = value ?? '',
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          TextFormField(
                            key: const ValueKey('password'),
                            obscureText: true,
                            style: TextStyle(color: AppTheme.kColorTextPrimary),
                            decoration: customInputDecoration('Password', Icons.lock_outline),
                            validator: (value) => (value ?? '').length < 6 ? 'Minimum 6 characters' : null,
                            onSaved: (value) => _password = value ?? '',
                          ),
                          // Country selector (only for sign up)
                          if (!_isLogin) ...[
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  onSelect: (Country country) {
                                    setState(() {
                                      _selectedCountry = country;
                                    });
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.kColorTextPrimary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.flag_outlined, color: AppTheme.kColorTextSecondary, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedCountry?.name ?? 'Select Country (Optional)',
                                        style: TextStyle(
                                          color: _selectedCountry != null ? AppTheme.kColorTextPrimary : AppTheme.kColorTextSecondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (_selectedCountry != null)
                                      Text(
                                        _selectedCountry!.flagEmoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    Icon(Icons.keyboard_arrow_down, color: AppTheme.kColorTextSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          // Forgot password (only for login)
                          if (_isLogin) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 36),
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppTheme.kColorAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Submit button
                          SizedBox(
                            height: 52,
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _submitAuthForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                                    ),
                                    child: Text(
                                      _isLogin ? 'Sign In' : 'Create Account',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Switch auth mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? "Don't have an account?" : 'Already have an account?',
                        style: TextStyle(
                          color: AppTheme.kColorTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _switchAuthMode,
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Sign In',
                          style: TextStyle(
                            color: AppTheme.kColorAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}