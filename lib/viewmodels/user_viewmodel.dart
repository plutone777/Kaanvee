import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/user.dart';
import '../repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;

  UserViewModel(this._repository);

  UserModel? _user;

  final Map<String, UserModel> _users = {};

  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  UserModel? getUser(String userId) {
    return _users[userId];
  }

Future<void> loadUser(
  String userId, {
  bool forceRefresh = false,
}) async {
  if (!forceRefresh && _users.containsKey(userId)) {
    _user = _users[userId];
    return;
  }

  await Future<void>.delayed(Duration.zero);

  _setLoading(true);

  try {
    final user = await _repository.getUser(userId);

    if (user != null) {
      _users[userId] = user;
      _user = user;
    }

    _errorMessage = null;
  } catch (e) {
    _errorMessage = 'Failed to load user.';
  } finally {
    _setLoading(false);
  }
}

  Future<bool> createUser(UserModel user) async {
    _setLoading(true);

    try {
      await _repository.createUser(user);

      _user = user;
      _users[user.userId] = user;

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create user.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser(UserModel user) async {
    _setLoading(true);

    try {
      await _repository.updateUser(user);

      _user = user;
      _users[user.userId] = user;

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(String userId) async {
    _setLoading(true);

    try {
      await _repository.deleteUser(userId);

      _users.remove(userId);

      if (_user?.userId == userId) {
        _user = null;
      }

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  Future<bool> isUsernameTaken(String username) async {
    return await _repository.isUsernameTaken(username);
  }

  Future<bool> updateAccount(UserModel user, {required String newEmail}) async {
    _setLoading(true);

    try {
      await _repository.updateAccount(user, newEmail: newEmail);

      _user = user;
      _users[user.userId] = user;

      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update account.';
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }
}
