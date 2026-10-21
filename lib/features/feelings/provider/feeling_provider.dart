import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/features/feelings/repositories/feeling_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feelingRepositoryProvider = Provider((ref) => FeelingRepository());

final feelingProvider = StreamProvider<List<Feeling>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);

  return ref.watch(feelingRepositoryProvider).watchFeelings(uid);
});

