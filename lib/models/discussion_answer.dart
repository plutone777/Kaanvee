import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionAnswerModel {
  final String answerId;
  final String discussionId;
  final String userId;
  final String answerText;
  final String? recommendedVendorId;
  final String? recommendedMenuId;
  final int likes;
  final List<String> likedBy;
  final DateTime createdDate;

  DiscussionAnswerModel({
    required this.answerId,
    required this.discussionId,
    required this.userId,
    required this.answerText,
    this.recommendedVendorId,
    this.recommendedMenuId,
    this.likes = 0,
    this.likedBy = const [],
    required this.createdDate,
  });

  factory DiscussionAnswerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return DiscussionAnswerModel(
      answerId: document.id,
      discussionId: data['discussionID'] ?? '',
      userId: data['userID'] ?? '',
      answerText: data['answerText'] ?? '',
      recommendedVendorId: data['recommendedVendorID'],
      recommendedMenuId: data['recommendedMenuID'],
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdDate: (data['createdDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'discussionID': discussionId,
      'userID': userId,
      'answerText': answerText,
      'recommendedVendorID': recommendedVendorId,
      'recommendedMenuID': recommendedMenuId,
      'likes': likes,
      'likedBy': likedBy,
      'createdDate': Timestamp.fromDate(createdDate),
    };
  }
}
