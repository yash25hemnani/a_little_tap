import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/feelings/screens/feelings_screen.dart';
import 'package:a_little_tap/features/notifications/providers/push_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loggingOut = false;

  // Stays on Settings with a spinner, then drops back to the gate once signed out
  Future<void> _logOut(String uid) async {
    setState(() => _loggingOut = true);

    // Read now, since this screen is gone by the time the snackbar shows
    final push = ref.read(pushServiceProvider);
    final auth = ref.read(authServiceProvider);
    final navigator = Navigator.of(context);
    // The app-wide messenger, so the snackbar still shows on the auth screen
    final messenger = ScaffoldMessenger.of(context);

    // Before signing out, while rules still allow the write
    await push.removeToken(uid);
    await auth.signOut();

    // The gate is already showing the auth screen underneath
    navigator.popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final uid = ref.watch(authStateProvider).value?.uid;
    final user = uid == null ? null : ref.watch(userProvider(uid)).value;
    final repo = ref.read(userRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.offWhite,
      ),
      body: uid == null || user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'Notifications',
                    style: text.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Switches follow the user doc, so they flip once Firestore writes
                _Card(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Push notifications'),
                      value: user.pushEnabled,
                      onChanged: (v) => repo.setSetting(uid, 'pushEnabled', v),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('Vibration'),
                      value: user.vibrationEnabled,
                      onChanged: (v) =>
                          repo.setSetting(uid, 'vibrationEnabled', v),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    'Personalize',
                    style: text.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _Card(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.favorite_border_rounded),
                      title: const Text('Feelings'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context)
                                            .push(MaterialPageRoute(builder: (_) => FeelingsScreen())),
                    )
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton(
                  // Disabled while logging out, so it can't run twice
                  onPressed: _loggingOut ? null : () => _logOut(uid),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.softPink,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.softPink,
                  ),
                  child: _loggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Text('Log out'),
                ),
              ],
            ),
    );
  }
}

// White rounded card, same look as InfoCard
class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
