import 'vendor.dart';

class CollaborativeRecommendation {
  final VendorModel vendor;
  final String basedOnVendorName;
  final int score;

  CollaborativeRecommendation({
    required this.vendor,
    required this.basedOnVendorName,
    required this.score,
  });
}