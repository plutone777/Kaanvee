import '../models/preferences.dart';
import '../models/vendor.dart';
import '../models/recommendation_result.dart';
import '../services/user_service.dart';
import '../services/vendor_service.dart';
import '../utils/recommendation_scoring.dart';

class RecommendationService {
  final UserService _userService;
  final VendorService _vendorService;

  RecommendationService(this._userService, this._vendorService);

  Future<List<RecommendationResult>> getPreferenceRecommendations(
    String userId,
  ) async {
    final user = await _userService.getUser(userId);

    if (user == null) {
      return [];
    }

    final UserPreferences preferences = user.preferences;

    final vendors = (await _vendorService.getVendors())
        .where(
          (vendor) =>
              vendor.approvalStatus.trim().toLowerCase() == 'approved',
        )
        .toList();

    final matchingVendors = vendors.where((vendor) {
      final isOpen = _isCurrentlyOpen(vendor.operatingHours);

      if (!isOpen) {
        return false;
      }

      final matchesTag =
          preferences.preferredTags.isEmpty ||
          vendor.tags.any(
            (vendorTag) => preferences.preferredTags.any(
              (preferredTag) =>
                  vendorTag.toLowerCase() == preferredTag.toLowerCase(),
            ),
          );

      final matchesPrice =
          preferences.preferredPriceRanges.isEmpty ||
          preferences.preferredPriceRanges.any(
            (preferredPrice) =>
                preferredPrice.toLowerCase() ==
                vendor.priceRange.toLowerCase(),
          );

      return matchesTag || matchesPrice;
    }).toList();

    final maxLikeCount = matchingVendors.isEmpty
        ? 0
        : matchingVendors
            .map((vendor) => vendor.likeCount)
            .reduce((a, b) => a > b ? a : b);

    final List<_ScoredVendor> scoredVendors = [];

    for (final vendor in matchingVendors) {
      final rating = vendor.averageRating;

      final score = RecommendationScoring.calculateScore(
        preferences: preferences,
        vendor: vendor,
        rating: rating,
        maxLikeCount: maxLikeCount,
      );

      scoredVendors.add(
        _ScoredVendor(
          vendor: vendor,
          score: score,
        ),
      );
    }

    scoredVendors.removeWhere((vendor) => vendor.score <= 0);

    scoredVendors.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    return scoredVendors
        .take(4)
        .map(
          (item) => RecommendationResult(
            vendor: item.vendor,
            matchPercentage: item.score,
          ),
        )
        .toList();
  }

  bool _isCurrentlyOpen(String operatingHours) {
    if (operatingHours.trim().isEmpty) {
      return false;
    }

    final now = DateTime.now();

    try {
      final parts = operatingHours.split('-');

      if (parts.length != 2) {
        return false;
      }

      final openingTime = _parseTime(parts[0].trim(), now);
      final closingTime = _parseTime(parts[1].trim(), now);

      if (openingTime == null || closingTime == null) {
        return false;
      }

      DateTime adjustedClosingTime = closingTime;

      if (closingTime.isBefore(openingTime)) {
        adjustedClosingTime = closingTime.add(
          const Duration(days: 1),
        );
      }

      DateTime currentTime = now;

      if (adjustedClosingTime.day != openingTime.day &&
          currentTime.isBefore(openingTime)) {
        currentTime = currentTime.add(
          const Duration(days: 1),
        );
      }

      return !currentTime.isBefore(openingTime) &&
          !currentTime.isAfter(adjustedClosingTime);
    } catch (e) {
      return false;
    }
  }

  DateTime? _parseTime(String time, DateTime date) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(time);

    if (match == null) {
      return null;
    }

    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)?.toUpperCase();

    if (period != null) {
      if (period == 'AM' && hour == 12) {
        hour = 0;
      } else if (period == 'PM' && hour != 12) {
        hour += 12;
      }
    }

    if (hour > 23 || minute > 59) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }
}

class _ScoredVendor {
  final VendorModel vendor;
  final double score;

  _ScoredVendor({
    required this.vendor,
    required this.score,
  });
}
