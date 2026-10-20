import 'package:a_little_tap/features/auth/models/user_model.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/repositories/user_repository.dart';
import 'package:a_little_tap/features/pairing/utils/invite_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

// A user's doc, live
final userProvider = StreamProvider.family<UserModel?, String>(
  (ref, userId) => ref.watch(userRepositoryProvider).watchUser(userId),
);

// The signed-in user's invite code as "XXXX-XXXX", or null while loading
final inviteCodeProvider = Provider((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return null;

  final code = ref.watch(userProvider(userId)).value?.inviteCode;

  return code == null ? null : formatInviteCode(code);
});
