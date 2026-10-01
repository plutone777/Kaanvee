import 'package:fyp_application/models/vendor_review.dart';
import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _service;

  ReviewRepository(this._service);

  Future<List<VendorReviewModel>> getVendorReviews(String vendorId) {
    return _service.getVendorReviews(vendorId);
  }

  Future<void> addVendorReview(VendorReviewModel review) {
    return _service.addVendorReview(review);
  }

  Future<void> updateVendorReview(VendorReviewModel review) {
    return _service.updateVendorReview(review);
  }

  Future<void> deleteVendorReview(String reviewId) {
    return _service.deleteVendorReview(reviewId);
  }

  Future<List<VendorReviewModel>> getReviewsByUser(String userId) {
    return _service.getReviewsByUser(userId);
  }

}
