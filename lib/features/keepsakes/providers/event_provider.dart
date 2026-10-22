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

// Events on a given UTC day; a lookup rather than a map so yearly events show every year
final eventsByDayProvider = Provider<List<KeepsakeEvent> Function(DateTime)>((
  ref,
) {
  final events = ref.watch(eventsProvider).value ?? const [];

  return (day) => events.where((e) => e.isOn(day)).toList();
});

// Soonest event from today on, with the day it next falls on; null if nothing is planned
final nextEventProvider = Provider<({KeepsakeEvent event, DateTime on})?>((
  ref,
) {
  final events = ref.watch(eventsProvider).value ?? const [];

  // Today's local date as a UTC day, the same form events are stored in
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);

  ({KeepsakeEvent event, DateTime on})? soonest;

  for (final e in events) {
    final on = e.nextOn(today);
    if (on == null) continue;
    if (soonest == null || on.isBefore(soonest.on)) {
      soonest = (event: e, on: on);
    }
  }

  return soonest;
});