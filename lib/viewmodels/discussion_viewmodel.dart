import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/models/discussion_answer.dart';
import 'package:fyp_application/services/user_service.dart';
import '../repositories/discussion_repository.dart';

class DiscussionViewModel extends ChangeNotifier {
  final DiscussionRepository _repository;
  final UserService _userService;

  DiscussionViewModel(this._repository, this._userService);

  List<DiscussionModel> _discussions = [];
  List<DiscussionAnswerModel> _answers = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<DiscussionModel> get discussions => _discussions;

  List<DiscussionAnswerModel> get answers => _answers;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDiscussions() async {
    _setLoading(true);

    try {
      _discussions = await _repository.getDiscussions();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load discussions.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAnswers(String discussionId) async {
    _setLoading(true);

    try {
      _answers = await _repository.getAnswers(discussionId);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load answers.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createDiscussion(DiscussionModel discussion) async {
    _setLoading(true);

    try {
      final newDiscussion = await _repository.createDiscussion(discussion);

      _discussions.add(newDiscussion);

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      print('CREATE DISCUSSION ERROR: $e');
      print('STACK TRACE: $stackTrace');

      _errorMessage = 'Failed to create discussion: $e';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addAnswer(DiscussionAnswerModel answer) async {
    _setLoading(true);

    try {
      await _repository.addAnswer(answer);

      _answers.add(answer);

      await _userService.addPoints(answer.userId, 2);

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add answer.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDiscussion(DiscussionModel discussion) async {
    _setLoading(true);

    try {
      await _repository.updateDiscussion(discussion);

      final index = _discussions.indexWhere(
        (item) => item.discussionId == discussion.discussionId,
      );

      if (index != -1) {
        _discussions[index] = discussion;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update discussion.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDiscussion(String discussionId) async {
    _setLoading(true);

    try {
      await _repository.deleteDiscussion(discussionId);

      _discussions.removeWhere(
        (discussion) => discussion.discussionId == discussionId,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete discussion.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> likeAnswer(String answerId) async {
    try {
      final success = await _repository.likeAnswer(answerId);

      if (success) {
        final index = _answers.indexWhere(
          (answer) => answer.answerId == answerId,
        );

        if (index != -1) {
          final answer = _answers[index];

          final currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser != null) {
            final likedBy = List<String>.from(answer.likedBy);

            if (likedBy.contains(currentUser.uid)) {
              likedBy.remove(currentUser.uid);
            } else {
              likedBy.add(currentUser.uid);
            }

            _answers[index] = DiscussionAnswerModel(
              answerId: answer.answerId,
              discussionId: answer.discussionId,
              userId: answer.userId,
              answerText: answer.answerText,
              recommendedVendorId: answer.recommendedVendorId,
              recommendedMenuId: answer.recommendedMenuId,
              likes: likedBy.length,
              likedBy: likedBy,
              createdDate: answer.createdDate,
            );

            notifyListeners();
          }
        }
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to like answer.';
      notifyListeners();
      return false;
    }
  }
}
