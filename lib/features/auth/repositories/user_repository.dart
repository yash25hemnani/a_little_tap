import 'package:a_little_tap/features/auth/models/user_model.dart';
import 'package:a_little_tap/features/feelings/constants/feelings.dart';
import 'package:a_little_tap/features/pairing/utils/invite_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  // Create users/{uid} right after sign-up
  // We have to create ourselves since FirebaseAuth and Firebase Firestore are not connected
  Future<void> createUser(UserModel user) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = generateInviteCode();
      final codeRef = _db.collection('inviteCodes').doc(code);
      final userRef = _db.collection('users').doc(user.id);

      final reserved = await _db.runTransaction<bool>((tx) async {
        final existing = await tx.get(codeRef);

        if (existing.exists) return false; // taken, try again

        tx.set(codeRef, {'uid': user.id});
        tx.set(userRef, {...user.toMap(), 'inviteCode': code});

        for (final (index, feeling) in defaultFeelings.indexed) {
          tx.set(userRef.collection('feelings').doc(), {
            ...feeling,
            'order': index,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        return true;
      });

      if (reserved) return;
    }
    throw Exception('Could not create an invite code, please try again');
  }

  // Watch one user, emits null if doc doesn't exist
  Stream<UserModel?> watchUser(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map(
          (snap) =>
              snap.exists ? UserModel.fromMap(snap.id, snap.data()!) : null,
        );
  }

  // Remember the feeling picked last, so Home opens on it
  Future<void> setLastFeeling(String uid, String feelingId) {
    return _db.collection('users').doc(uid).update({
      'lastFeelingId': feelingId,
    });
  }
}
