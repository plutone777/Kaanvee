import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';
import '../models/preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final UserRepository _userRepository;

  AuthViewModel(this._repository, this._userRepository) {
    // Get the currently logged-in Firebase user.
    _user = FirebaseAuth.instance.currentUser;

    // Listen for login/logout changes.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final credential = await _repository.login(email, password);

      _user = credential.user;
      _errorMessage = null;

      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        _errorMessage = 'Email or password is incorrect.';
      } else {
        _errorMessage = e.message ?? 'Login failed.';
      }

      notifyListeners();

      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);

    try {
      // Create Firebase Authentication account.
      final credential = await _repository.register(username, email, password);

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        _errorMessage = 'Registration failed.';
        notifyListeners();
        return false;
      }

      _user = firebaseUser;

      // Create Firestore user document.
      final userModel = UserModel(
        userId: firebaseUser.uid,
        username: username,
        email: email,
        role: 'User',
        points: 0,
        location: 'Malé',
        preferences: UserPreferences(),
      );

      await _userRepository.createUser(userModel);

      _errorMessage = null;

      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed.';

      notifyListeners();

      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _repository.logout();

      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to log out.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
