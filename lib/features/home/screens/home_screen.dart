import 'dart:async';

import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/core/utils/format_event_day.dart';
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
import 'package:a_little_tap/features/keepsakes/providers/event_provider.dart';
import 'package:a_little_tap/features/keepsakes/screens/event_detail_screen.dart';
import 'package:a_little_tap/features/moments/providers/moment_provider.dart';
import 'package:a_little_tap/features/moments/screens/moment_detail_screen.dart';
import 'package:a_little_tap/features/notifications/providers/push_provider.dart';
import 'package:a_little_tap/features/presence/providers/presence_provider.dart';
import 'package:a_little_tap/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  // Switches MainLayout to the Keepsakes tab
  final VoidCallback? onOpenKeepsakes;

  const HomeScreen({super.key, this.onOpenKeepsakes});

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

    final partner = ref.watch(partnerProvider);

    final lastMoment = ref.watch(lastReceivedProvider);

    final nextEvent = ref.watch(nextEventProvider);

    // Rebuilds every 30s so the partner drops offline once their heartbeat stops
    ref.watch(clockProvider);

    // Spinner until the partner and feelings arrive, so nothing shows half-filled
    if (partner == null || feeling == null) {
      return const Scaffold(
        backgroundColor: AppColors.offWhite,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final partnerName = partner.displayName;

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
                        isOnline: partner.isOnline,
                        lastSeen: partner.lastSeen,
                        subtitle: lastMoment == null
                            ? null
                            : 'Last tap • ${formatWhen(context, lastMoment.createdAt)}',
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
                  child: PulsingIcon(
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
                              send: () async {
                                final momentId = await ref
                                    .read(momentRepositoryProvider)
                                    .send(
                                      coupleId: coupleId,
                                      fromUid: uid,
                                      feeling: feeling,
                                    );

                                unawaited(
                                  ref
                                      .read(pushServiceProvider)
                                      .notifyPartner(
                                        coupleId: coupleId,
                                        momentId: momentId,
                                      ),
                                );
                              },
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
                              send: () async {
                                final momentId = await ref
                                    .read(momentRepositoryProvider)
                                    .send(
                                      coupleId: coupleId,
                                      fromUid: uid,
                                      feeling: picked,
                                    );

                                unawaited(
                                  ref
                                      .read(pushServiceProvider)
                                      .notifyPartner(
                                        coupleId: coupleId,
                                        momentId: momentId,
                                      ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),

              // Feeling name and hint read as one label under the icon
              Text(
                feeling.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: feeling.color,
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
                onTap: lastMoment == null
                    ? null
                    : () => MomentDetailScreen.show(context, lastMoment),
              ),

              const SizedBox(height: 12),
              InfoCard(
                icon: Icons.event_rounded,
                iconColor: AppColors.lavender,
                iconBackground: AppColors.lavenderSoft,
                title: nextEvent?.event.title ?? 'No plans yet',
                subtitle: nextEvent == null
                    ? 'Add a date in Keepsakes'
                    : formatEventDay(nextEvent.on),
                // No event yet: opens the Keepsakes tab to add one
                onTap: nextEvent == null
                    ? onOpenKeepsakes
                    : () => EventDetailScreen.show(
                        context,
                        nextEvent.event,
                        nextEvent.on,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
