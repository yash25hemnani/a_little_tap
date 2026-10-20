import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Stream that emits whenever users logs in or out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current logged in user or null
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  // Throws FirebaseAuthException, the UI catches it
  Future<User?> signUp(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
