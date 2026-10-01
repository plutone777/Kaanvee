import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String reportedBy;
  final String reportType;
  final String targetId;
  final String? imageUrl;
  final String reason;
  final String status;
  final String? reviewedBy;
  final DateTime createdDate;
  final DateTime? reviewedDate;

  ReportModel({
    required this.reportId,
    required this.reportedBy,
    required this.reportType,
    required this.targetId,
    this.imageUrl,
    required this.reason,
    this.status = 'Pending',
    this.reviewedBy,
    required this.createdDate,
    this.reviewedDate,
  });

  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;

    return ReportModel(
      reportId: document.id,
      reportedBy: data['reportedBy'] ?? '',
      reportType: data['reportType'] ?? '',
      targetId: data['targetID'] ?? '',
      imageUrl: data['imageURL'],
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'Pending',
      reviewedBy: data['reviewedBy'],
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      reviewedDate: (data['reviewedDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reportedBy': reportedBy,
      'reportType': reportType,
      'targetID': targetId,
      'imageURL': imageUrl,
      'reason': reason,
      'status': status,
      'reviewedBy': reviewedBy,
      'createdDate': Timestamp.fromDate(createdDate),
      'reviewedDate': reviewedDate == null
          ? null
          : Timestamp.fromDate(reviewedDate!),
    };
  }

  ReportModel copyWith({
    String? reportId,
    String? reportedBy,
    String? reportType,
    String? targetId,
    String? imageUrl,
    String? reason,
    String? status,
    String? reviewedBy,
    DateTime? createdDate,
    DateTime? reviewedDate,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      reportedBy: reportedBy ?? this.reportedBy,
      reportType: reportType ?? this.reportType,
      targetId: targetId ?? this.targetId,
      imageUrl: imageUrl ?? this.imageUrl,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      createdDate: createdDate ?? this.createdDate,
      reviewedDate: reviewedDate ?? this.reviewedDate,
    );
  }
}