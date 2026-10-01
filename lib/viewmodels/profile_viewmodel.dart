import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/models/vendor_review.dart';
import '../repositories/review_repository.dart';
import '../repositories/discussion_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ReviewRepository _reviewRepository;
  final DiscussionRepository _discussionRepository;

  ProfileViewModel(
    this._reviewRepository,
    this._discussionRepository,
  );

  List<VendorReviewModel> _vendorReviews = [];
  List<DiscussionModel> _discussions = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<VendorReviewModel> get vendorReviews => _vendorReviews;
  List<DiscussionModel> get discussions => _discussions;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile(String userId) async {
    _setLoading(true);

    try {
      _vendorReviews =
          await _reviewRepository.getReviewsByUser(userId);

      _discussions =
          await _discussionRepository.getDiscussionsByUser(userId);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
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
}