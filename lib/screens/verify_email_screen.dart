import 'dart:async';
import 'package:chess_park/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_park/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.refreshUser();
      } catch (e) {
        debugPrint("Error refreshing user in VerifyEmailScreen: $e");
        if (e is FirebaseAuthException &&
            (e.code == 'user-token-expired' || e.code == 'user-disabled')) {
          debugPrint(
            "Session expired during verification check. Stopping timer.",
          );
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (_isSending) return;
    setState(() {
      _isSending = true;
    });
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to send email: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'your account';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 40, color: AppTheme.kColorAccent),

              const SizedBox(height: 20),
              Text(
                'A verification email has been sent to $userEmail.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              const Text(
                'Checking status automatically...',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Resend Email'),
                onPressed: _isSending ? null : _resendEmail,
              ),
              const SizedBox(height: 10),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
