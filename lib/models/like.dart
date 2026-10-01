import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String userId;
  final String targetId;
  final DateTime date;

  LikeModel({
    required this.userId,
    required this.targetId,
    required this.date,
  });

  factory LikeModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return LikeModel(
      userId: data['userID'] ?? '',
      targetId: data['targetID'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userID': userId,
      'targetID': targetId,
      'date': Timestamp.fromDate(date),
    };
  }
}
