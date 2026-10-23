import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/features/moments/models/moment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MomentRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Moment>> watchMoments(String coupleId, String fromUid, int limit) => _db
      .collection('couples')
      .doc(coupleId)
      .collection('moments')
      .where('fromUid', isEqualTo: fromUid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (snap) => snap.docs.map((d) => Moment.fromMap(d.id, d.data())).toList(),
      );

  Future<String> send({
    required String coupleId,
    required String fromUid,
    required Feeling feeling,
  }) async {
    final moment = Moment(
      id: '',
      fromUid: fromUid,
      feeling: feeling,
      createdAt: DateTime.now(),
    );

    final doc = await _db
        .collection('couples')
        .doc(coupleId)
        .collection('moments')
        .add(moment.toMap());

    return doc.id; // the worker needs this to find the moment
  }
}
