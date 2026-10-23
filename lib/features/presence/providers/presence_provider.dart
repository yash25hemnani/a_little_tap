import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/presence/services/presence_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final presenceServiceProvider = Provider(
  (ref) => PresenceService(ref.read(userRepositoryProvider)),
);

// Ticks every 30s so "Online" and "Last seen" stay current without a doc change
final clockProvider = StreamProvider<void>(
  (ref) => Stream.periodic(const Duration(seconds: 30)),
);
