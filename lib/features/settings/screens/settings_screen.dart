import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/notifications/providers/push_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logOut(BuildContext context, WidgetRef ref, String uid) async {
    // Read before popping, since ref can't be used once this screen is gone
    final push = ref.read(pushServiceProvider);
    final auth = ref.read(authServiceProvider);

    // Back to the gate first, so Settings isn't left on top of the auth screen
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Before signing out, while rules still allow the write
    await push.removeToken(uid);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => _logOut(context, ref, uid),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.softPink,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Log out'),
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
