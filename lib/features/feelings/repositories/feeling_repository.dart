import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeelingRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Feeling>> watchFeelings(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('feelings')
      .orderBy('order')
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => Feeling.fromMap(d.id, d.data())).toList(),
      );

  Future<void> addFeeling(String uid, Feeling feeling) => _db
      .collection('users')
      .doc(uid)
      .collection('feelings')
      .add({...feeling.toMap(), 'createdAt': FieldValue.serverTimestamp()});

  Future<void> updateFeeling(String uid, Feeling feeling) => _db
      .collection('users')
      .doc(uid)
      .collection('feelings')
      .doc(feeling.id)
      .update(feeling.toMap());

  Future<void> deleteFeeling(String uid, String id) =>
      _db.collection('users').doc(uid).collection('feelings').doc(id).delete();
}
