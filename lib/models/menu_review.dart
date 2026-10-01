import 'package:cloud_firestore/cloud_firestore.dart';
// TODO: UNUSED
class MenuReviewModel {
  final String menuReviewId;
  final String menuId;
  final String userId;
  final int rating;
  final String? reviewText;
  final DateTime createdDate;
  final DateTime? lastUpdated;

  MenuReviewModel({
    required this.menuReviewId,
    required this.menuId,
    required this.userId,
    required this.rating,
    this.reviewText,
    required this.createdDate,
    this.lastUpdated,
  });

  factory MenuReviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return MenuReviewModel(
      menuReviewId: document.id,
      menuId: data['menuID'] ?? '',
      userId: data['userID'] ?? '',
      rating: data['rating'] ?? 0,
      reviewText: data['reviewText'],
      createdDate:
          (data['createdDate'] as Timestamp).toDate(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'menuID': menuId,
      'userID': userId,
      'rating': rating,
      'reviewText': reviewText,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': lastUpdated == null
          ? null
          : Timestamp.fromDate(lastUpdated!),
    };
  }
}