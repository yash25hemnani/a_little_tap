import 'package:a_little_tap/features/couple/models/couple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleRepository {
  final _db = FirebaseFirestore.instance;

  // Watch one couple, emits null if the doc doesn't exist
  Stream<Couple?> watchCouple(String coupleId) => _db
      .collection('couples')
      .doc(coupleId)
      .snapshots()
      .map(
        (snap) => snap.exists ? Couple.fromMap(snap.id, snap.data()!) : null,
      );
}
