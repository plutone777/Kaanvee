import '../models/vendor.dart';

class RecommendationResult {
  final VendorModel vendor;
  final double matchPercentage;

  RecommendationResult({
    required this.vendor,
    required this.matchPercentage,
  });
}