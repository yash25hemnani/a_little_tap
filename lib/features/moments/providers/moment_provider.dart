import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/moments/models/moment.dart';
import 'package:a_little_tap/features/moments/repositories/moment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final momentRepositoryProvider = Provider((ref) => MomentRepository());

// The couple's taps, newest first; empty while loading or unpaired
final momentsProvider = StreamProvider<List<Moment>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);

  final coupleId = ref.watch(userProvider(uid)).value?.coupleId;
  if (coupleId == null) return Stream.value(const []);

  return ref.watch(momentRepositoryProvider).watchMoments(coupleId);
});

// Newest tap from the partner, or null if none yet
final lastReceivedProvider = Provider<Moment?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return null;

  return ref
      .watch(momentsProvider)
      .value
      ?.where((m) => !m.isFrom(uid))
      .firstOrNull;
});
