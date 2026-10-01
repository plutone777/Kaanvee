import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> register(
    String username,
    String email,
    String password,
  ) async {
    // Create Firebase Authentication account
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the Firebase UID
    final user = credential.user;

    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).set({
        'user_id': user.uid,
        'username': username,
        'email': email,
        'role': 'User',
        'points': 0,
        'preferences': {
          'notificationsEnabled': true,
          'recommendationNotifications': true,
          'vendorUpdateNotifications': true,
          'darkMode': true,
        },
      });
    }

    return credential;
  }

  Future<UserCredential> login(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();
}
