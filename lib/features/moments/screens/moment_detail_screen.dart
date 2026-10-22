import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/feelings/utils/play_vibration.dart';
import 'package:a_little_tap/features/home/widgets/pulsing_icon.dart';
import 'package:a_little_tap/features/moments/models/moment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// One tap from the history, in its feeling's colours, with its pattern to replay
class MomentDetailScreen extends ConsumerWidget {
  final Moment moment;

  const MomentDetailScreen({super.key, required this.moment});

  static Future<void> show(BuildContext context, Moment moment) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MomentDetailScreen(moment: moment)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final feeling = moment.feeling;

    final uid = ref.watch(authStateProvider).value?.uid;
    final vibrate = uid == null
        ? true
        : ref.watch(userProvider(uid)).value?.vibrationEnabled ?? true;
    final partnerName = ref.watch(partnerProvider)?.displayName ?? '';
    final isMine = uid != null && moment.isFrom(uid);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: feeling.background),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: PulsingIcon(
                      heroTag: 'moment-${moment.id}',
                      size: 180,
                      icon: feeling.icon,
                      iconColor: feeling.color,
                      backgroundColor: feeling.circleColor,
                      ringColor: feeling.ringColor,
                    ),
                  ),
                ),
                Text(
                  isMine ? 'You sent' : 'From $partnerName',
                  style: text.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  feeling.title,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    color: feeling.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (feeling.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    feeling.subtitle,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  DateFormat(
                    'EEE, d MMM yyyy • h:mm a',
                  ).format(moment.createdAt),
                  style: text.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Hidden when there's no pattern or the Vibration setting is off
                if (vibrate && feeling.vibration.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => playVibration(feeling.vibration),
                      icon: const Icon(Icons.vibration_rounded),
                      label: const Text('Play vibration'),
                      style: FilledButton.styleFrom(
                        backgroundColor: feeling.color,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
