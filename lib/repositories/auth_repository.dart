import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<UserCredential> register(
    String username,
    String email,
    String password,
  ) {
    return _service.register(username, email, password);
  }

  Future<UserCredential> login(
    String email,
    String password,
  ) {
    return _service.login(email, password);
  }

  Future<void> logout() async {
    await _service.logout();
  }

  User? get currentUser => _service.currentUser;

  Stream<User?> get authStateChanges =>
      _service.authStateChanges;
}