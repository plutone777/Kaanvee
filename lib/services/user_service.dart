import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_application/models/user.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('Users');

  Future<UserModel?> getUser(String userId) async {
    debugPrint('=== GET USER START ===');
    debugPrint('Looking for UID: $userId');

    try {
      final document = await _users.doc(userId).get();

      debugPrint('Firestore request completed');
      debugPrint('Exists: ${document.exists}');
      debugPrint('Document ID: ${document.id}');
      debugPrint('Data: ${document.data()}');

      if (!document.exists) {
        debugPrint('USER DOCUMENT NOT FOUND');
        return null;
      }

      debugPrint('Creating UserModel...');

      final user = UserModel.fromFirestore(document);

      debugPrint('UserModel created successfully');
      debugPrint('Username: ${user.username}');
      debugPrint('Role: ${user.role}');
      debugPrint('User ID: ${user.userId}');
      debugPrint('Profile Image URL: ${user.profileImageURL}');

      return user;
    } catch (e, stackTrace) {
      debugPrint('!!! GET USER ERROR !!!');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.userId).set(user.toFirestore());
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.userId).update(user.toFirestore());
  }

  Future<void> deleteUser(String userId) async {
    await _users.doc(userId).delete();
  }

  Future<void> addPoints(String userId, int points) async {
    await _users.doc(userId).update({
      'points': FieldValue.increment(points),
    });
  }

  Future<bool> isUsernameTaken(String username) async {
    final snapshot = await _users
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> updateAccount(
    UserModel user, {
    required String newEmail,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    if (currentUser.email != newEmail) {
      await currentUser.verifyBeforeUpdateEmail(newEmail);
    }

    await _users.doc(user.userId).update({
      'username': user.username,
      'email': newEmail,
      'role': user.role,
      'points': user.points,
      'location': user.location,
      'profileImageURL': user.profileImageURL,
      'preferences': user.preferences.toMap(),
    });
  }
}