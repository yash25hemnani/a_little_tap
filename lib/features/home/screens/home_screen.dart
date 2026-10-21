import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/core/utils/format_when.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/features/feelings/provider/feeling_provider.dart';
import 'package:a_little_tap/features/home/screens/sending_screen.dart';
import 'package:a_little_tap/features/home/widgets/info_card.dart';
import 'package:a_little_tap/features/home/widgets/partner_card.dart';
import 'package:a_little_tap/features/home/widgets/picker_sheet.dart';
import 'package:a_little_tap/features/home/widgets/pulsing_icon.dart';
import 'package:a_little_tap/features/moments/providers/moment_provider.dart';
import 'package:a_little_tap/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user id
    final uid = ref.watch(authStateProvider).value?.uid;
    final user = uid == null ? null : ref.watch(userProvider(uid)).value;

    // Get last feeling id
    final lastId = user?.lastFeelingId;
    final coupleId = user?.coupleId;

    // Get list of feelings
    final feelings = ref.watch(feelingProvider).value ?? const <Feeling>[];

    // Last used, else first (also covers a last feeling that was deleted)
    final feeling =
        feelings.where((f) => f.id == lastId).firstOrNull ??
        feelings.firstOrNull;

    final partnerName = ref.watch(partnerProvider)?.displayName ?? '';

    final lastMoment = ref.watch(lastReceivedProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // extra 8 keeps the header at 24 from the edge; only the cards widen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: PartnerCard(
                        name: partnerName,
                        isOnline: false,
                        lastSeen: DateTime.now().subtract(
                          const Duration(minutes: 2),
                        ),
                        onTap: () {},
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      color: AppColors.textSecondary,
                      tooltip: 'Settings',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  // Spinner until the feelings stream arrives
                  child: feeling == null
                      ? const CircularProgressIndicator()
                      : PulsingIcon(
                          icon: feeling.icon,
                          iconColor: feeling.color,
                          backgroundColor: feeling.circleColor,
                          ringColor: feeling.ringColor,
                          // Plain tap sends the last picked feeling
                          onTap: () {
                            if (uid == null || coupleId == null) return;

                            SendingScreen.show(
                              context,
                              partnerName: partnerName,
                              feeling: feeling,
                              vibrate: user?.vibrationEnabled ?? true,
                              send: () => ref
                                  .read(momentRepositoryProvider)
                                  .send(
                                    coupleId: coupleId,
                                    fromUid: uid,
                                    feeling: feeling,
                                  ),
                            );
                          },
                          onLongPress: () async {
                            if (uid == null || coupleId == null) return;

                            final picked = await PickerSheet.show(
                              context,
                              feelings,
                            );
                            if (picked == null || !context.mounted) {
                              return; // sheet dismissed
                            }
                            // Not awaited, so the sending screen opens right away
                            if (picked.id != feeling.id) {
                              ref
                                  .read(userRepositoryProvider)
                                  .setLastFeeling(uid, picked.id);
                            }

                            SendingScreen.show(
                              context,
                              partnerName: partnerName,
                              feeling: picked,
                              vibrate: user?.vibrationEnabled ?? true,
                              send: () => ref
                                  .read(momentRepositoryProvider)
                                  .send(
                                    coupleId: coupleId,
                                    fromUid: uid,
                                    feeling: picked,
                                  ),
                            );
                          },
                        ),
                ),
              ),

              // Feeling name and hint read as one label under the icon
              Text(
                feeling?.title ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: feeling?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                'Tap to send a little something',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // Pink heart until the first tap arrives
              InfoCard(
                icon: lastMoment?.feeling.icon ?? Icons.favorite_rounded,
                iconColor: lastMoment?.feeling.color ?? AppColors.heart,
                iconBackground:
                    lastMoment?.feeling.circleColor ?? AppColors.softPink,
                title: 'Last tap from $partnerName',
                subtitle: lastMoment == null
                    ? 'No taps yet'
                    : '${lastMoment.feeling.title} • ${formatWhen(context, lastMoment.createdAt)}',
                onTap: () {},
              ),

              const SizedBox(height: 12),
              InfoCard(
                icon: Icons.event_rounded,
                iconColor: AppColors.lavender,
                iconBackground: AppColors.lavenderSoft,
                title: 'Movie night',
                subtitle: 'Sat, Oct 25 • in 5 days',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
