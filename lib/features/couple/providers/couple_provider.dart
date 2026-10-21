import 'package:a_little_tap/features/auth/models/user_model.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/couple/models/couple.dart';
import 'package:a_little_tap/features/couple/repositories/couple_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final coupleRepositoryProvider = Provider((ref) => CoupleRepository());

final coupleProvider = StreamProvider.family<Couple?, String>(
  (ref, coupleId) => ref.watch(coupleRepositoryProvider).watchCouple(coupleId),
);

// The signed-in user's partner, or null while loading or unpaired
// watch (not read) so it re-runs as each stream arrives
final partnerProvider = Provider<UserModel?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;

  if (uid == null) return null;

  final coupleId = ref.watch(userProvider(uid)).value?.coupleId;

  if (coupleId == null) return null;

  final partnerId = ref.watch(coupleProvider(coupleId)).value?.partnerOf(uid);

  if (partnerId == null) return null;

  return ref.watch(userProvider(partnerId)).value;
});
