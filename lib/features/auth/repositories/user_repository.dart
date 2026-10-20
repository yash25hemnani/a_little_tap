import 'package:a_little_tap/features/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  // Create users/{uid} right after sign-up
  // We have to create ourselves since FirebaseAuth and Firebase Firestore are not connected
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
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
}
