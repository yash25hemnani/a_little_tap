import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/models/user_model.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/auth/services/auth_service.dart';
import 'package:a_little_tap/features/auth/widgets/password_field.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

enum AuthMode { signUp, logIn }

class AuthScreen extends ConsumerStatefulWidget {
  final AuthMode initialMode;

  const AuthScreen({super.key, this.initialMode = AuthMode.signUp});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  late AuthMode _mode = widget.initialMode;
  bool _loading = false;

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return "That email doesn't look right";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password';
    if (_isSignUp && password.length < 8) return 'Use at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Confirm your password';
    if (value != _password.text) return "Passwords don't match";
    return null;
  }

  // Back arrow shows if there's a previous screen, or if we can step back
  // from log in to the mode the screen opened in.
  bool get _canGoBack =>
      _mode != widget.initialMode || Navigator.of(context).canPop();

  void _toggleMode() {
    setState(() => _mode = _isSignUp ? AuthMode.logIn : AuthMode.signUp);
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus(); // hide keyboard
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final authService = AuthService();
    final userRepository = ref.read(userRepositoryProvider);

    try {
      if (_isSignUp) {
        final user = await authService.signUp(
          _email.text.trim(),
          _password.text,
        );

        if (user != null) {
          await userRepository.createUser(
            UserModel(
              id: user.uid,
              email: user.email!,
              name: user.displayName,
              createdAt: DateTime.now(),
            ),
          );
        }
      } else {
        await authService.signIn(_email.text.trim(), _password.text);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Something went wrong'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // Blocks the pop while in the other mode and switches back instead.
    // Covers both the arrow (via maybePop) and Android's system back.
    return PopScope(
      canPop: _mode == widget.initialMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _toggleMode();
      },
      child: Scaffold(
        body: Container(
          color: AppColors.surface,
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Visibility(
                    visible: _canGoBack,
                    // keep its space so the form doesn't jump when it appears
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.text,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      // so the keyboard doesn't cause overflow
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          // lets the OS offer saved passwords
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isSignUp ? 'Create account' : 'Welcome back',
                                // GoogleFonts.poppins (not copyWith) so the
                                // heavier weight's font file actually loads.
                                style: GoogleFonts.poppins(
                                  textStyle: text.headlineMedium,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSignUp
                                    ? 'Start sending little taps.'
                                    : 'Log in to stay close.',
                                style: GoogleFonts.poppins(
                                  textStyle: text.bodyMedium,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: _email,
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 16),
                              PasswordField(
                                controller: _password,
                                validator: _validatePassword,
                                autofillHints: [
                                  _isSignUp
                                      ? AutofillHints.newPassword
                                      : AutofillHints.password,
                                ],
                                // sign up: "Next" jumps to confirm; log in: "Done" submits
                                textInputAction: _isSignUp
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                onSubmitted: _isSignUp ? null : _submit,
                              ),
                              if (_isSignUp) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 4,
                                  ),
                                  child: Text(
                                    'At least 8 characters',
                                    style: text.bodySmall?.copyWith(
                                      color: AppColors.hint,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PasswordField(
                                  controller: _confirmPassword,
                                  hintText: 'Confirm password',
                                  validator: _validateConfirmPassword,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onSubmitted: _submit,
                                ),
                              ],
                              const SizedBox(height: 32),
                              FilledButton(
                                onPressed: _submit,
                                child: _loading
                                    ? const SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.onPrimary,
                                        ),
                                      )
                                    : Text(_isSignUp ? 'Continue' : 'Log in'),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isSignUp
                                        ? 'Already have an account?'
                                        : "Don't have an account?",
                                    style: GoogleFonts.poppins(
                                      textStyle: text.bodyMedium,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _toggleMode,
                                    child: Text(
                                      _isSignUp ? 'Log in' : 'Sign up',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
