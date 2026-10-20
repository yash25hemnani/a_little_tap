import 'package:a_little_tap/core/layout/main_layout.dart';
import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/pairing/models/pair_request.dart';
import 'package:a_little_tap/features/pairing/providers/pairing_provider.dart';
import 'package:a_little_tap/features/pairing/repositories/pairing_repository.dart';
import 'package:a_little_tap/features/pairing/widgets/invite_code_field.dart';
import 'package:a_little_tap/features/pairing/widgets/request_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
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

  Future<void> _copyCode() async {
    final code = ref.read(inviteCodeProvider);
    if (code == null) return;

    await Clipboard.setData(ClipboardData(text: code));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Code copied')));
  }

  Future<void> _connect() async {
    if (_loading || !_isComplete(_codeController.text)) return;
    FocusScope.of(context).unfocus();

    // self user doc, needed for my name and code
    final uid = ref.read(authStateProvider).value?.uid;
    final me = uid == null ? null : ref.read(userProvider(uid)).value;
    if (me == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(pairingRepositoryProvider)
          .sendRequest(me: me, code: _codeController.text);
      _codeController.clear();
    } on PairingException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Cancel (mine) and decline (theirs) both delete the request.
  // The stream drops it and the card disappears by itself.
  void _cancel(PairRequest request) =>
      ref.read(pairingRepositoryProvider).deleteRequest(request.id);

  void _decline(PairRequest request) =>
      ref.read(pairingRepositoryProvider).deleteRequest(request.id);

  void _accept(PairRequest request) {
    // Temporary: AuthGate will switch to MainLayout once coupleId is set
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final code = ref.watch(inviteCodeProvider);
    // Treat loading/error as "none" so the code field shows meanwhile
    final incoming = ref.watch(incomingRequestsProvider).value ?? [];
    final outgoing = ref.watch(outgoingRequestsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      // TEMP: for switching accounts while testing pairing
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            // AuthGate sees the sign-out and shows AuthScreen
            onPressed: () => ref.read(authServiceProvider).signOut(),
            child: const Text('Log out'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero illustration
                Image.asset('assets/images/holding_hands.png', height: 300),
                const SizedBox(height: 24),
                Text(
                  'Pair with your partner',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: text.headlineSmall,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),

                // Show one thing at a time:
                // an invite for me > my sent invite > my code + enter code.
                if (incoming.isNotEmpty)
                  // Someone sent me an invite
                  RequestCard(
                    title: '${incoming.first.fromName} wants to connect',
                    subtitle: 'Accept to become a pair',
                    actions: [
                      TextButton(
                        onPressed: () => _decline(incoming.first),
                        child: const Text('Decline'),
                      ),
                      FilledButton(
                        onPressed: () => _accept(incoming.first),
                        // The theme makes FilledButtons full width, which
                        // breaks inside a Row. Give this one a normal size.
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  )
                else if (outgoing.isNotEmpty)
                  // I sent an invite and am waiting
                  RequestCard(
                    title: 'Sent to ${outgoing.first.toName}',
                    subtitle: 'Waiting for them…',
                    actions: [
                      TextButton(
                        onPressed: () => _cancel(outgoing.first),
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                else ...[
                  // No invites: let me enter their code
                  InviteCodeField(
                    controller: _codeController,
                    errorText: _error,
                    onSubmitted: _connect,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: _codeController,
                    builder: (context, value, _) => FilledButton(
                      onPressed: _isComplete(value.text) ? _connect : null,
                      child: _loading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text('Connect'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // small pink chip (tap to copy), label underneath
                  Center(
                    child: Material(
                      color: AppColors.softPink,
                      shape: const StadiumBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _copyCode,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                code ?? 'XXXX-XXXX',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your code',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      textStyle: text.bodySmall,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
