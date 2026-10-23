import 'package:a_little_tap/core/utils/format_when.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/home/widgets/info_card.dart';
import 'package:a_little_tap/features/moments/models/moment.dart';
import 'package:a_little_tap/features/moments/providers/moment_provider.dart';
import 'package:a_little_tap/features/moments/screens/moment_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// One tab of taps, loading 20 more each time it nears the bottom
class MomentList extends ConsumerStatefulWidget {
  final bool sent;

  const MomentList({super.key, required this.sent});

  @override
  ConsumerState<MomentList> createState() => _MomentListState();
}

class _MomentListState extends ConsumerState<MomentList>
    with AutomaticKeepAliveClientMixin {
  static const _page = 20;

  int _limit = _page;
  // Kept while a bigger page loads, so the list doesn't blank
  List<Moment> _shown = const [];

  // Keeps the scroll position and limit when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final sent = widget.sent;
    final uid = ref.watch(authStateProvider).value?.uid;
    final partner = ref.watch(partnerProvider);
    final fromUid = sent ? uid : partner?.id;

    if (fromUid == null) return const SizedBox.shrink();

    final async = ref.watch(
      momentsFromProvider((fromUid: fromUid, limit: _limit)),
    );
    _shown = async.value ?? _shown;

    // A full page means there may be more
    final hasMore = _shown.length == _limit;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (hasMore && !async.isLoading && n.metrics.extentAfter < 300) {
          setState(() => _limit += _page);
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _shown.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          // Spinner at the end while more may load
          if (i == _shown.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final moment = _shown[i];
          return InfoCard(
            icon: moment.feeling.icon,
            iconColor: moment.feeling.color,
            iconBackground: moment.feeling.circleColor,
            title: sent ? 'You' : partner?.displayName ?? '',
            subtitle:
                '${moment.feeling.title} • ${formatWhen(context, moment.createdAt)}',
            onTap: () => MomentDetailScreen.show(context, moment),
          );
        },
      ),
    );
  }
}
