import 'package:a_little_tap/core/layout/main_layout.dart';
import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/pairing/widgets/invite_code_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  // "7F3K-2Q9D" → 9 chars including the dash
  bool _isComplete(String text) => text.length == 9;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_isComplete(_codeController.text)) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Little heart badge; the whole header is centred around it
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.softPink,
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 34,
                      color: AppColors.heart,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Connect hearts',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: text.headlineMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your partner's code.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: text.bodyMedium,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                InviteCodeField(
                  controller: _codeController,
                  errorText: _error,
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder(
                  valueListenable: _codeController,
                  builder: (context, value, _) => FilledButton(
                    onPressed: _isComplete(value.text) ? _submit : null,
                    child: _loading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text('Continue'),
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
