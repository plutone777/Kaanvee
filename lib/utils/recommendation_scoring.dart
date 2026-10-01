import '../models/preferences.dart';
import '../models/vendor.dart';

class RecommendationScoring {
  /// Calculates a preference-based recommendation score
  /// from 0 to 100.
  ///
  /// Scoring:
  /// - Preferred tags: 50 points
  /// - Preferred price range: 25 points
  /// - Vendor rating: 10 points
  /// - Vendor likes: 10 points
  /// - Open status: 5 points
  static double calculateScore({
    required UserPreferences preferences,
    required VendorModel vendor,
    double rating = 0.0,
    int maxLikeCount = 0,
  }) {
    double score = 0.0;

    // ==========================================
    // PREFERRED TAGS
    // ==========================================

    if (preferences.preferredTags.isNotEmpty) {
      final matchingTags = vendor.tags.where(
        (vendorTag) => preferences.preferredTags.any(
          (preferredTag) =>
              vendorTag.toLowerCase() ==
              preferredTag.toLowerCase(),
        ),
      ).length;

      final tagScore =
          (matchingTags /
                  preferences.preferredTags.length) *
              50;

      score += tagScore;
    }

    // ==========================================
    // PREFERRED PRICE RANGE
    // ==========================================

    if (preferences.preferredPriceRanges.isNotEmpty) {
      final matchesPrice =
          preferences.preferredPriceRanges.any(
        (preferredPrice) =>
            preferredPrice.toLowerCase() ==
            vendor.priceRange.toLowerCase(),
      );

      if (matchesPrice) {
        score += 25;
      }
    }

    // ==========================================
    // VENDOR RATING
    // ==========================================

    final clampedRating =
        rating.clamp(0.0, 5.0);

    score +=
        (clampedRating / 5.0) * 10;

    // ==========================================
    // VENDOR LIKES
    // ==========================================

    if (maxLikeCount > 0) {
      final likeScore =
          (vendor.likeCount / maxLikeCount) * 10;

      score += likeScore.clamp(0.0, 10.0);
    }

    // ==========================================
    // OPEN STATUS
    // ==========================================

    if (vendor.openClosedStatus) {
      score += 5;
    }

    return score.clamp(0.0, 100.0);
  }
}
