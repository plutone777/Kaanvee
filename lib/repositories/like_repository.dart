import '../models/like.dart';
import '../services/like_service.dart';

class LikeRepository {
  final LikeService _service;

  LikeRepository(this._service);

  Future<void> addLike(LikeModel like) async {
    await _service.addLike(like);
  }

  Future<void> removeLike(String userId, String targetId) async {
    await _service.removeLike(userId, targetId);
  }

  Future<bool> hasLiked(String userId, String targetId) async {
    return await _service.hasLiked(userId, targetId);
  }

  Future<List<LikeModel>> getUserLikes(String userId) async {
    return await _service.getUserLikes(userId);
  }

  Future<List<LikeModel>> getAllLikes() async {
    return await _service.getAllLikes();
  }
}
