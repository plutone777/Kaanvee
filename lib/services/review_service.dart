import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_application/models/vendor_review.dart';

class ReviewService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vendorReviews =>
      _firestore.collection('Vendor Review');

  CollectionReference<Map<String, dynamic>> get _menuReviews =>
      _firestore.collection('Menu Review');

  CollectionReference<Map<String, dynamic>> get _vendors =>
      _firestore.collection('Vendors');

  // ============================================================
  // Vendor Reviews
  // ============================================================

  Future<List<VendorReviewModel>> getVendorReviews(
    String vendorId,
  ) async {
    final snapshot = await _vendorReviews
        .where('vendorID', isEqualTo: vendorId)
        .get();

    return snapshot.docs
        .map((doc) => VendorReviewModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addVendorReview(
    VendorReviewModel review,
  ) async {
    await _vendorReviews
        .doc(review.vendorReviewId)
        .set(review.toFirestore());

    await _updateVendorRating(review.vendorId);
  }

  Future<void> updateVendorReview(
    VendorReviewModel review,
  ) async {
    await _vendorReviews
        .doc(review.vendorReviewId)
        .update(review.toFirestore());

    await _updateVendorRating(review.vendorId);
  }

  Future<void> deleteVendorReview(
    String reviewId,
  ) async {
    // Get the review before deleting it so we know
    // which vendor's rating needs to be updated.
    final document =
        await _vendorReviews.doc(reviewId).get();

    if (!document.exists) {
      return;
    }

    final data = document.data();

    if (data == null) {
      return;
    }

    final vendorId = data['vendorID'] as String?;

    await _vendorReviews.doc(reviewId).delete();

    if (vendorId != null && vendorId.isNotEmpty) {
      await _updateVendorRating(vendorId);
    }
  }

  // ============================================================
  // Update Vendor Rating Summary
  // ============================================================

  Future<void> _updateVendorRating(
    String vendorId,
  ) async {
    final snapshot = await _vendorReviews
        .where('vendorID', isEqualTo: vendorId)
        .get();

    if (snapshot.docs.isEmpty) {
      await _vendors.doc(vendorId).update({
        'averageRating': 0.0,
        'reviewCount': 0,
      });

      return;
    }

    double totalRating = 0.0;

    for (final document in snapshot.docs) {
      final data = document.data();

      final rating =
          (data['rating'] as num?)?.toDouble() ?? 0.0;

      totalRating += rating;
    }

    final reviewCount = snapshot.docs.length;

    final averageRating =
        totalRating / reviewCount;

    await _vendors.doc(vendorId).update({
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    });
  }

  // ============================================================
  // Reviews By User
  // ============================================================

  Future<List<VendorReviewModel>> getReviewsByUser(
    String userId,
  ) async {
    final snapshot = await _vendorReviews
        .where('userID', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => VendorReviewModel.fromFirestore(doc))
        .toList();
  }
}