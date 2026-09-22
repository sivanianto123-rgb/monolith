import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/state/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;
  bool _submitting = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _destination() {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    return (from == null || from.isEmpty) ? '/orders' : from;
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool _isValidEmail(String email) => _emailPattern.hasMatch(email);

  /// Returns null if strong enough, otherwise a message explaining why not.
  String? _passwordStrengthError(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Password must include at least one letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must include at least one number.';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(Object error) {
    if (error is FirebaseAuthException) {
      // Always log the real code/message so it shows up in the browser
      // console — the toast below is deliberately friendlier/shorter for
      // some codes, and shouldn't be the only place the real cause is
      // visible.
      debugPrint(
        'FirebaseAuthException: code=${error.code} message=${error.message}',
      );
    } else {
      debugPrint('Auth error: $error');
    }
    _showMessage(_messageFor(error));
  }

  String _messageFor(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Something went wrong. Please try again.';
    }
    switch (error.code) {
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this Firebase '
            'project. Enable it under Authentication > Sign-in method in '
            'the Firebase console.';
      case 'network-request-failed':
        return 'Could not reach the auth server. If you are developing '
            'locally, make sure either the Firebase emulators are running '
            '(firebase emulators:start) or firebase_options.dart points at '
            'a real project.';
      case 'popup-timeout':
        return error.message ?? 'The sign-in window timed out.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      case 'popup-blocked':
        return 'Your browser blocked the sign-in popup. Allow popups for '
            'this site and try again.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Enter an email and password.');
      return;
    }
    if (!_isValidEmail(email)) {
      _showMessage('Enter a valid email address.');
      return;
    }
    if (_isSignUp) {
      if (_nameController.text.trim().isEmpty) {
        _showMessage('Enter your full name.');
        return;
      }
      final passwordError = _passwordStrengthError(password);
      if (passwordError != null) {
        _showMessage(passwordError);
        return;
      }
    }
    setState(() => _submitting = true);
    try {
      final auth = ref.read(authServiceProvider);
      if (_isSignUp) {
        await auth.signUpWithEmail(
          email: email,
          password: password,
          fullName: _nameController.text.trim(),
        );
        if (!mounted) return;
        _showMessage('Account created.');
      } else {
        await auth.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        _showMessage('Welcome back.');
      }
      if (!mounted) return;
      context.go(_destination());
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() => _submitting = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      _showMessage('Welcome back.');
      context.go(_destination());
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowText('Account'),
        const SizedBox(height: 16),
        DisplayHeading(
          _isSignUp ? 'Create account' : 'Sign in',
          color: AppColors.foreground,
          fontSize: responsiveDisplaySize(context, max: wide ? 64 : 40),
        ),
        const SizedBox(height: 20),
        Text(
          'Save the pairs you design in 3D, keep your sizes on file and follow every order.',
          style: GoogleFonts.archivo(
            fontSize: 15,
            height: 1.6,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );

    final formCard = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSignUp) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_isSignUp ? 'Create account' : 'Sign in'),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: GoogleFonts.archivo(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _submitting ? null : _submitGoogle,
              child: const Text('Continue with Google'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isSignUp = !_isSignUp),
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.archivo(
                    fontSize: 13,
                    color: AppColors.mutedForeground,
                  ),
                  children: [
                    TextSpan(
                      text: _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                    ),
                    TextSpan(
                      text: _isSignUp ? 'Sign in' : 'Create one',
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 72 : 40),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: copy),
                  const SizedBox(width: 64),
                  Expanded(flex: 5, child: formCard),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [copy, const SizedBox(height: 40), formCard],
              ),
      ),
    );
  }
}
