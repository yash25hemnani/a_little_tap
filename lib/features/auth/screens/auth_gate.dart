import 'package:a_little_tap/core/layout/main_layout.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/auth/screens/auth_screen.dart';
import 'package:a_little_tap/features/pairing/screens/pairing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider);

    return authUser.when(
      loading: () => const _Loading(),
      error: (e, _) => const AuthScreen(),
      data: (user) {
        if (user == null) return const AuthScreen();

        // Signed in → watch their users/{uid} doc
        final userDoc = ref.watch(userProvider(user.uid));
        return userDoc.when(
          loading: () => const _Loading(),
          error: (e, _) => const PairingScreen(),
          // null doc or no coupleId → still needs pairing
          data: (u) => (u?.isPaired ?? false)
              ? const MainLayout()
              : const PairingScreen(),
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
