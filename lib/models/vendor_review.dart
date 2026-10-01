  import 'package:cloud_firestore/cloud_firestore.dart';

  class VendorReviewModel {
    final String vendorReviewId;
    final String vendorId;
    final String userId;
    final int rating;
    final String? reviewText;
    final DateTime createdDate;
    final DateTime? lastUpdated;

    final int? taste;
    final int? value;
    final int? portion;
    final int? service;
    final int? cleanliness;
    final int? waitingTime;

    VendorReviewModel({
      required this.vendorReviewId,
      required this.vendorId,
      required this.userId,
      required this.rating,
      this.reviewText,
      required this.createdDate,
      this.lastUpdated,
      this.taste,
      this.value,
      this.portion,
      this.service,
      this.cleanliness,
      this.waitingTime,
    });

    factory VendorReviewModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
    ) {
      final data = document.data()!;

      return VendorReviewModel(
        vendorReviewId: document.id,
        vendorId: data['vendorID'] ?? '',
        userId: data['userID'] ?? '',
        rating: data['rating'] ?? 0,
        reviewText: data['reviewText'],
        createdDate:
            (data['createdDate'] as Timestamp).toDate(),
        lastUpdated:
            (data['lastUpdated'] as Timestamp?)?.toDate(),
        taste: data['taste'],
        value: data['value'],
        portion: data['portion'],
        service: data['service'],
        cleanliness: data['cleanliness'],
        waitingTime: data['waitingTime'],
      );
    }

    Map<String, dynamic> toFirestore() {
      return {
        'vendorID': vendorId,
        'userID': userId,
        'rating': rating,
        'reviewText': reviewText,
        'createdDate': Timestamp.fromDate(createdDate),
        'lastUpdated': lastUpdated == null
            ? null
            : Timestamp.fromDate(lastUpdated!),
        'taste': taste,
        'value': value,
        'portion': portion,
        'service': service,
        'cleanliness': cleanliness,
        'waitingTime': waitingTime,
      };
    }
  }