import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/like.dart';

class LikeService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _likesCollection =>
      _firestore.collection('Likes');

  CollectionReference<Map<String, dynamic>> get _vendors =>
      _firestore.collection('Vendors');

  // ==========================================================
  // ADD LIKE
  // ==========================================================

  Future<void> addLike(LikeModel like) async {
    final likeId =
        '${like.userId}_${like.targetId}';

    final likeDocument =
        _likesCollection.doc(likeId);

    // Check whether the user has already liked
    // this vendor.
    final existingLike =
        await likeDocument.get();

    if (existingLike.exists) {
      return;
    }

    // Add the like document.
    await likeDocument.set(
      like.toFirestore(),
    );

    // Increase the vendor's like count.
    await _vendors.doc(like.targetId).update({
      'likeCount':
          FieldValue.increment(1),
    });
  }

  // ==========================================================
  // REMOVE LIKE
  // ==========================================================

  Future<void> removeLike(
    String userId,
    String targetId,
  ) async {
    final likeId =
        '${userId}_$targetId';

    final likeDocument =
        _likesCollection.doc(likeId);

    // Check whether the like actually exists.
    final existingLike =
        await likeDocument.get();

    if (!existingLike.exists) {
      return;
    }

    // Remove the like document.
    await likeDocument.delete();

    // Decrease the vendor's like count.
    await _vendors.doc(targetId).update({
      'likeCount':
          FieldValue.increment(-1),
    });
  }

  // ==========================================================
  // CHECK IF USER LIKED
  // ==========================================================

  Future<bool> hasLiked(
    String userId,
    String targetId,
  ) async {
    final likeId =
        '${userId}_$targetId';

    final document =
        await _likesCollection.doc(likeId).get();

    return document.exists;
  }

  // ==========================================================
  // GET USER LIKES
  // ==========================================================

  Future<List<LikeModel>> getUserLikes(
    String userId,
  ) async {
    final snapshot =
        await _likesCollection
            .where(
              'userID',
              isEqualTo: userId,
            )
            .get();

    return snapshot.docs
        .map(
          (document) =>
              LikeModel.fromFirestore(
            document,
          ),
        )
        .toList();
  }

// ==========================================================
// GET ALL LIKES
// ==========================================================

Future<List<LikeModel>> getAllLikes() async {
  final snapshot = await _likesCollection.get();

  return snapshot.docs
      .map(
        (document) => LikeModel.fromFirestore(document),
      )
      .toList();
}

}
