import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/models/discussion_answer.dart';

class DiscussionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _discussions =>
      _firestore.collection('Discussion');

  CollectionReference<Map<String, dynamic>> get _answers =>
      _firestore.collection('Discussion Answer');

  Future<List<DiscussionModel>> getDiscussions() async {
    final snapshot = await _discussions.get();

    return snapshot.docs
        .map((doc) => DiscussionModel.fromFirestore(doc))
        .toList();
  }

  Future<DiscussionModel?> getDiscussion(String discussionId) async {
    final document = await _discussions.doc(discussionId).get();

    if (!document.exists) {
      return null;
    }

    return DiscussionModel.fromFirestore(document);
  }

  Future<DiscussionModel> createDiscussion(DiscussionModel discussion) async {
    final document = _discussions.doc();

    final newDiscussion = DiscussionModel(
      discussionId: document.id,
      userId: discussion.userId,
      title: discussion.title,
      description: discussion.description,
      createdDate: discussion.createdDate,
      lastUpdated: discussion.lastUpdated,
      status: discussion.status,
    );

    await document.set(newDiscussion.toFirestore());

    return newDiscussion;
  }

  Future<void> updateDiscussion(DiscussionModel discussion) async {
    await _discussions
        .doc(discussion.discussionId)
        .update(discussion.toFirestore());
  }

  Future<void> deleteDiscussion(String discussionId) async {
    final answerSnapshot = await _answers
        .where('discussionID', isEqualTo: discussionId)
        .get();

    for (final answer in answerSnapshot.docs) {
      await answer.reference.delete();
    }
    await _discussions.doc(discussionId).delete();
  }

  Future<List<DiscussionAnswerModel>> getAnswers(String discussionId) async {
    final snapshot = await _answers
        .where('discussionID', isEqualTo: discussionId)
        .get();

    return snapshot.docs
        .map((doc) => DiscussionAnswerModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addAnswer(DiscussionAnswerModel answer) async {
    await _answers.doc(answer.answerId).set(answer.toFirestore());
  }

  Future<void> updateAnswer(DiscussionAnswerModel answer) async {
    await _answers.doc(answer.answerId).update(answer.toFirestore());
  }

  Future<void> deleteAnswer(String answerId) async {
    await _answers.doc(answerId).delete();
  }

  Future<bool> likeAnswer(String answerId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final answerRef = _answers.doc(answerId);

    final document = await answerRef.get();

    if (!document.exists) {
      return false;
    }

    final data = document.data()!;

    final likedBy = List<String>.from(data['likedBy'] ?? []);

    if (likedBy.contains(user.uid)) {
      // User already liked → unlike
      await answerRef.update({
        'likedBy': FieldValue.arrayRemove([user.uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await answerRef.update({
        'likedBy': FieldValue.arrayUnion([user.uid]),
        'likes': FieldValue.increment(1),
      });
    }

    return true;
  }

  Future<List<DiscussionModel>> getDiscussionsByUser(String userId) async {
    final snapshot = await _discussions
        .where('userID', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => DiscussionModel.fromFirestore(doc))
        .toList();
  }
}
