import 'package:a_little_tap/features/auth/models/user_model.dart';
import 'package:a_little_tap/features/pairing/models/pair_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Errors the pairing screen can show as-is under the code field
class PairingException implements Exception {
  final String message;
  PairingException(this.message);

  @override
  String toString() => message;
}

class PairingRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('pairRequests');

  // Turn a typed code ("7F3K-Q29D" or "7f3kq29d") into a pair request
  Future<void> sendRequest({
    required UserModel me,
    required String code,
  }) async {
    // Codes are stored without the dash
    final cleanCode = code.replaceAll('-', '').toUpperCase();

    if (cleanCode == me.inviteCode) {
      throw PairingException("That's your own code");
    }

    final codeSnap = await _db.collection('inviteCodes').doc(cleanCode).get();
    if (!codeSnap.exists) {
      throw PairingException('No such code exists');
    }

    final partnerId = codeSnap.data()!['uid'] as String;

    final partnerSnap = await _db.collection('users').doc(partnerId).get();
    if (!partnerSnap.exists) {
      throw PairingException('No such code exists');
    }

    final partner = UserModel.fromMap(partnerId, partnerSnap.data()!);
    if (partner.isPaired) {
      throw PairingException('${partner.displayName} is already paired');
    }

    await _requests.doc(PairRequest.idFor(me.id, partnerId)).set({
      'fromUid': me.id,
      'fromName': me.displayName,
      'toUid': partnerId,
      'toName': partner.displayName,
      'createdAt': Timestamp.now(),
    });
  }

  // Requests sent to me
  Stream<List<PairRequest>> watchIncoming(String uid) => _requests
      .where('toUid', isEqualTo: uid)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => PairRequest.fromMap(d.id, d.data())).toList(),
      );

  // Requests I sent
  Stream<List<PairRequest>> watchOutgoing(String uid) => _requests
      .where('fromUid', isEqualTo: uid)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((d) => PairRequest.fromMap(d.id, d.data())).toList(),
      );

  // Decline (theirs) and cancel (mine) both just delete the request
  Future<void> deleteRequest(String requestId) =>
      _requests.doc(requestId).delete();
}
