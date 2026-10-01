import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/like.dart';
import '../repositories/like_repository.dart';

class LikeViewModel extends ChangeNotifier {
  final LikeRepository _repository;

  LikeViewModel(this._repository);

  final Map<String, bool> _likedTargets = {};

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isLiked(String targetId) {
    return _likedTargets[targetId] ?? false;
  }

  Future<void> loadLikeStatus(String targetId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final liked = await _repository.hasLiked(user.uid, targetId);

      _likedTargets[targetId] = liked;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load like status.';
      notifyListeners();
    }
  }

  Future<bool> toggleLike(String targetId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _errorMessage = 'You must be logged in to like a vendor.';
      notifyListeners();
      return false;
    }

    final currentlyLiked = isLiked(targetId);

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (currentlyLiked) {
        await _repository.removeLike(user.uid, targetId);

        _likedTargets[targetId] = false;
      } else {
        final like = LikeModel(
          userId: user.uid,
          targetId: targetId,
          date: DateTime.now(),
        );

        await _repository.addLike(like);

        _likedTargets[targetId] = true;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update like.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<LikeModel>> getUserLikes() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    try {
      return await _repository.getUserLikes(user.uid);
    } catch (e) {
      _errorMessage = 'Failed to load likes.';
      notifyListeners();
      return [];
    }
  }

  void clearLikes() {
    _likedTargets.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
