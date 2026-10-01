import 'package:fyp_application/models/user.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  Future<UserModel?> getUser(String userId) {
    return _service.getUser(userId);
  }

  Future<void> createUser(UserModel user) {
    return _service.createUser(user);
  }

  Future<void> updateUser(UserModel user) {
    return _service.updateUser(user);
  }

  Future<void> deleteUser(String userId) {
    return _service.deleteUser(userId);
  }

  Future<bool> isUsernameTaken(String username) {
    return _service.isUsernameTaken(username);
  }

  Future<void> updateAccount(UserModel user, {required String newEmail}) {
    return _service.updateAccount(user, newEmail: newEmail);
  }

}
