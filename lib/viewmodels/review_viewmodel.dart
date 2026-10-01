import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/vendor_review.dart';
import 'package:fyp_application/services/user_service.dart';
import '../repositories/review_repository.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repository;
  final UserService _userService = UserService();

  ReviewViewModel(this._repository);

  List<VendorReviewModel> _vendorReviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VendorReviewModel> get vendorReviews => _vendorReviews;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVendorReviews(String vendorId) async {
    _setLoading(true);

    try {
      _vendorReviews = await _repository.getVendorReviews(vendorId);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load vendor reviews.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addVendorReview(VendorReviewModel review) async {
    _setLoading(true);

    try {
      await _repository.addVendorReview(review);

      _vendorReviews.add(review);

      await _userService.addPoints(review.userId, 5);

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add review.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteVendorReview(String reviewId) async {
    _setLoading(true);

    try {
      await _repository.deleteVendorReview(reviewId);

      _vendorReviews.removeWhere((review) => review.vendorReviewId == reviewId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete review.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
