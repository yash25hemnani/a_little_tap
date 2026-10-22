import 'package:a_little_tap/core/utils/format_when.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/home/widgets/info_card.dart';
import 'package:a_little_tap/features/moments/providers/moment_provider.dart';
import 'package:a_little_tap/features/moments/screens/moment_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MomentList extends ConsumerWidget {
  final bool sent;

  const MomentList({super.key, required this.sent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final partnerName = ref.watch(partnerProvider)?.displayName ?? '';
    final moments = (ref.watch(momentsProvider).value ?? const [])
        .where((m) => m.isFrom(uid ?? '') == sent)
        .toList();

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: moments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final moment = moments[i];
        return InfoCard(
          icon: moment.feeling.icon,
          iconColor: moment.feeling.color,
          iconBackground: moment.feeling.circleColor,
          title: sent ? 'You' : partnerName,
          subtitle: '${moment.feeling.title} • ${formatWhen(context, moment.createdAt)}',
          onTap: () => MomentDetailScreen.show(context, moment),
        );
      },
    );
  }
}
