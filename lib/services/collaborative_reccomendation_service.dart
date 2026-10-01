import '../models/collaborative_recommendation.dart';
import '../repositories/like_repository.dart';
import '../services/vendor_service.dart';

class CollaborativeRecommendationService {
  final LikeRepository _likeRepository;
  final VendorService _vendorService;

  CollaborativeRecommendationService(this._likeRepository, this._vendorService);

  Future<List<CollaborativeRecommendation>> getRecommendations(String userId) async {
    final userLikes = await _likeRepository.getUserLikes(userId);

    if (userLikes.isEmpty) {
      return [];
    }

    final allLikes = await _likeRepository.getAllLikes();
    final userLikedVendorIds = userLikes.map((like) => like.targetId).toSet();
    final similarUserIds = <String>{};

    for (final like in allLikes) {
      if (like.userId == userId) {
        continue;
      }

      if (userLikedVendorIds.contains(like.targetId)) {
        similarUserIds.add(like.userId);
      }
    }

    final candidateLikes = allLikes.where((like) {
      if (!similarUserIds.contains(like.userId)) {
        return false;
      }

      if (userLikedVendorIds.contains(like.targetId)) {
        return false;
      }

      return true;
    }).toList();

    final Map<String, int> vendorScores = {};

    for (final like in candidateLikes) {
      vendorScores[like.targetId] = (vendorScores[like.targetId] ?? 0) + 1;
    }

    final vendors = await _vendorService.getVendors();

    final approvedVendors = vendors.where((vendor) {
      return vendor.approvalStatus.trim().toLowerCase() == 'approved';
    }).toList();

    final vendorMap = {
      for (final vendor in approvedVendors) vendor.vendorId: vendor,
    };

    final recommendations = <CollaborativeRecommendation>[];

    for (final entry in vendorScores.entries) {
      final vendor = vendorMap[entry.key];

      if (vendor == null) {
        continue;
      }

      String? basedOnVendorName;

      for (final userLike in userLikes) {
        final usersWhoLikedThisVendor = allLikes
            .where((like) =>
                like.targetId == userLike.targetId && like.userId != userId)
            .map((like) => like.userId)
            .toSet();

        final hasRecommendedVendor = allLikes.any(
          (like) =>
              usersWhoLikedThisVendor.contains(like.userId) &&
              like.targetId == entry.key,
        );

        if (hasRecommendedVendor) {
          final basedOnVendor = vendorMap[userLike.targetId];

          if (basedOnVendor != null) {
            basedOnVendorName = basedOnVendor.name;
            break;
          }
        }
      }

      recommendations.add(
        CollaborativeRecommendation(
          vendor: vendor,
          basedOnVendorName: basedOnVendorName ?? 'a vendor you liked',
          score: entry.value,
        ),
      );
    }

    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations.take(3).toList();
  }
}
