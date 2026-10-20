import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/home/widgets/info_card.dart';
import 'package:a_little_tap/features/moments/models/moment.dart';
import 'package:flutter/material.dart';

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Our moments',
                    style: text.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Pill indicator instead of the default underline
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.track,
                    borderRadius: BorderRadius.circular(24)
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.heart,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.softPink,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [Tab(text: 'Received'), Tab(text: 'Sent')],
                  ),
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _MomentList(sent: false),
                      _MomentList(sent: true),
                    ],
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

class _MomentList extends StatelessWidget {
  final bool sent;

  const _MomentList({required this.sent});

  @override
  Widget build(BuildContext context) {
    final moments = sampleMoments.where((m) => m.sent == sent).toList();

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
          title: sent ? 'You' : 'Varsha',
          subtitle: '${moment.feeling.title} • ${_when(context, moment.at)}',
          onTap: () {},
        );
      },
    );
  }
}

// Today → "3:24 PM", yesterday → "Yesterday", older → "Apr 20"
String _when(BuildContext context, DateTime at) {
  final l10n = MaterialLocalizations.of(context);
  final today = DateUtils.dateOnly(DateTime.now());
  final day = DateUtils.dateOnly(at);

  if (day == today) return l10n.formatTimeOfDay(TimeOfDay.fromDateTime(at));
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return l10n.formatShortMonthDay(at);
}