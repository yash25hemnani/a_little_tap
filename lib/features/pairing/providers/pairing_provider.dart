import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/pairing/models/pair_request.dart';
import 'package:a_little_tap/features/pairing/repositories/pairing_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pairingRepositoryProvider = Provider((ref) => PairingRepository());

// Requests sent to me, live. Empty while signed out.
// ref.watch (not read) so it restarts when a different user logs in.
final incomingRequestsProvider = StreamProvider<List<PairRequest>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);

  return ref.watch(pairingRepositoryProvider).watchIncoming(uid);
});

// Requests I sent, live. Empty while signed out.
final outgoingRequestsProvider = StreamProvider<List<PairRequest>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);

  return ref.watch(pairingRepositoryProvider).watchOutgoing(uid);
});
