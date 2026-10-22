import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/keepsakes/models/keepsake_event.dart';
import 'package:a_little_tap/features/keepsakes/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

final eventsProvider = StreamProvider<List<KeepsakeEvent>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;

  if (uid == null) return Stream.value(const []);

  final coupleId = ref.watch(userProvider(uid)).value?.coupleId;

  if (coupleId == null) return Stream.value(const []);

  return ref.watch(eventRepositoryProvider).watchEvents(coupleId);
});

final eventsByDayProvider = Provider<Map<DateTime, List<KeepsakeEvent>>>((ref) {
  final events = ref.watch(eventsProvider).value ?? const [];

  final byDay = <DateTime, List<KeepsakeEvent>>{};

  for (final e in events) {
    // e.date is already a UTC day, the same key table_calendar looks up
    byDay.putIfAbsent(e.date, () => []).add(e);
  }

  return byDay;
});

// Soonest event from today on, or null if nothing is planned
final nextEventProvider = Provider<KeepsakeEvent?>((ref) {
  final events = ref.watch(eventsProvider).value ?? const [];

  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);

  // Events arrive sorted by date, so the first match is the soonest
  return events.where((e) => !e.date.isBefore(today)).firstOrNull;
});
