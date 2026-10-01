import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/models/discussion_answer.dart';
import '../services/discussion_service.dart';

class DiscussionRepository {
  final DiscussionService _service;

  DiscussionRepository(this._service);

  // Discussions

  Future<List<DiscussionModel>> getDiscussions() {
    return _service.getDiscussions();
  }

  Future<DiscussionModel?> getDiscussion(String discussionId) {
    return _service.getDiscussion(discussionId);
  }

  Future<DiscussionModel> createDiscussion(DiscussionModel discussion) {
    return _service.createDiscussion(discussion);
  }

  Future<void> updateDiscussion(DiscussionModel discussion) {
    return _service.updateDiscussion(discussion);
  }

  Future<void> deleteDiscussion(String discussionId) {
    return _service.deleteDiscussion(discussionId);
  }

  // Answers

  Future<List<DiscussionAnswerModel>> getAnswers(String discussionId) {
    return _service.getAnswers(discussionId);
  }

  Future<void> addAnswer(DiscussionAnswerModel answer) {
    return _service.addAnswer(answer);
  }

  Future<void> updateAnswer(DiscussionAnswerModel answer) {
    return _service.updateAnswer(answer);
  }

  Future<void> deleteAnswer(String answerId) {
    return _service.deleteAnswer(answerId);
  }

  Future<bool> likeAnswer(String answerId) {
    return _service.likeAnswer(answerId);
  }

  Future<List<DiscussionModel>> getDiscussionsByUser(String userId) {
    return _service.getDiscussionsByUser(userId);
  }
}
