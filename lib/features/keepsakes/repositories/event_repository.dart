import 'package:a_little_tap/features/keepsakes/models/keepsake_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<KeepsakeEvent>> watchEvents(String coupleId) => _db
      .collection('couples')
      .doc(coupleId)
      .collection('events')
      .orderBy('date')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => KeepsakeEvent.fromMap(d.id, d.data()))
            .toList(),
      );

  Future<void> add({
    required String coupleId,
    required String title,
    required DateTime date,
    required String createdBy,
  }) async {
    final event = KeepsakeEvent(
      id: '',
      title: title,
      // Saved as UTC midnight so both phones show the same day in any timezone
      date: DateTime.utc(date.year, date.month, date.day),
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    await _db
        .collection('couples')
        .doc(coupleId)
        .collection('events')
        .add(event.toMap());
  }

  Future<void> delete(String coupleId, String eventId) => _db
      .collection('couples')
      .doc(coupleId)
      .collection('events')
      .doc(eventId)
      .delete();
}
