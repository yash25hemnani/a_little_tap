import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/moments/models/moment.dart';
import 'package:a_little_tap/features/moments/repositories/moment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final momentRepositoryProvider = Provider((ref) => MomentRepository());

// Newest taps from one person, up to limit; empty while loading or unpaired
// A Dart record compares by value, so the same sender and limit share one stream
final momentsFromProvider = StreamProvider.autoDispose
    .family<List<Moment>, ({String fromUid, int limit})>((ref, args) {
      final uid = ref.watch(authStateProvider).value?.uid;
      if (uid == null) return Stream.value(const []);

      final coupleId = ref.watch(userProvider(uid)).value?.coupleId;
      if (coupleId == null) return Stream.value(const []);

      return ref
          .watch(momentRepositoryProvider)
          .watchMoments(coupleId, args.fromUid, args.limit);
    });

// Newest tap from the partner, or null if none yet
final lastReceivedProvider = Provider<Moment?>((ref) {
  final partnerId = ref.watch(partnerProvider)?.id;
  if (partnerId == null) return null;

  return ref
      .watch(momentsFromProvider((fromUid: partnerId, limit: 1)))
      .value
      ?.firstOrNull;
});
