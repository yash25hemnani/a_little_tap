import 'package:a_little_tap/features/auth/models/user_model.dart';
import 'package:a_little_tap/features/auth/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

// A user's doc, live
final userProvider = StreamProvider.family<UserModel?, String>(
  (ref, userId) => ref.watch(userRepositoryProvider).watchUser(userId),
);
