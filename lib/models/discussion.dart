import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionModel {
  final String discussionId;
  final String userId;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime? lastUpdated;
  final String status;

  DiscussionModel({
    required this.discussionId,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdDate,
    this.lastUpdated,
    this.status = 'Active',
  });

  factory DiscussionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return DiscussionModel(
      discussionId: document.id,
      userId: data['userID'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdDate:
          (data['createdDate'] as Timestamp).toDate(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userID': userId,
      'title': title,
      'description': description,
      'createdDate': Timestamp.fromDate(createdDate),
      'lastUpdated': lastUpdated == null
          ? null
          : Timestamp.fromDate(lastUpdated!),
      'status': status,
    };
  }
}