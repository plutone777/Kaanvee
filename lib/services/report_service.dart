import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_application/models/report.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/models/user.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:flutter/foundation.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('Reports');

  Future<void> createReport(ReportModel report) async {
    await _reports.doc(report.reportId).set(report.toFirestore());
  }

  Future<List<ReportModel>> getReports() async {
    try {
      debugPrint('REPORTS: Starting getReports()');

      final snapshot = await _reports.get();

      debugPrint('REPORTS: Firestore query completed');
      debugPrint('REPORTS: Number of documents: ${snapshot.docs.length}');

      final reports = <ReportModel>[];

      for (final doc in snapshot.docs) {
        debugPrint('REPORTS: Reading document ${doc.id}');
        debugPrint('REPORTS: Data = ${doc.data()}');

        final report = ReportModel.fromFirestore(doc);

        debugPrint(
          'REPORTS: Parsed report ${report.reportId}, '
          'type=${report.reportType}, '
          'target=${report.targetId}',
        );

        reports.add(report);
      }

      debugPrint('REPORTS: Successfully loaded ${reports.length} reports');

      return reports;
    } catch (e, stackTrace) {
      debugPrint('REPORTS ERROR: $e');
      debugPrint('REPORTS STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  Future<List<ReportModel>> getPendingReports() async {
    final snapshot = await _reports.where('status', isEqualTo: 'Pending').get();

    return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
  }

  Future<void> updateReport(ReportModel report) async {
    await _reports.doc(report.reportId).update(report.toFirestore());
  }

  Future<void> deleteReport(String reportId) async {
    await _reports.doc(reportId).delete();
  }

  Future<VendorModel?> getReportedVendor(String vendorId) async {
    try {
      final document = await _firestore
          .collection('Vendors')
          .doc(vendorId)
          .get();

      debugPrint('REPORT VENDOR ID: $vendorId');
      debugPrint('VENDOR EXISTS: ${document.exists}');

      if (!document.exists) {
        return null;
      }

      return VendorModel.fromFirestore(document);
    } catch (e, stackTrace) {
      debugPrint('GET REPORTED VENDOR ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Future<MenuModel?> getReportedMenu(String menuId) async {
    try {
      final document = await _firestore.collection('Menu').doc(menuId).get();

      debugPrint('REPORT MENU ID: $menuId');
      debugPrint('MENU EXISTS: ${document.exists}');

      if (!document.exists) {
        return null;
      }

      debugPrint('MENU DATA: ${document.data()}');

      return MenuModel.fromFirestore(document);
    } catch (e, stackTrace) {
      debugPrint('GET REPORTED MENU ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Future<UserModel?> getReportedUser(String userId) async {
    try {
      final document = await _firestore.collection('Users').doc(userId).get();

      debugPrint('REPORT USER ID: $userId');
      debugPrint('USER EXISTS: ${document.exists}');

      if (!document.exists) {
        return null;
      }

      debugPrint('USER DATA: ${document.data()}');

      return UserModel.fromFirestore(document);
    } catch (e, stackTrace) {
      debugPrint('GET REPORTED USER ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Future<DiscussionModel?> getReportedDiscussion(String discussionId) async {
    try {
      final document = await _firestore
          .collection('Discussion')
          .doc(discussionId)
          .get();

      debugPrint('REPORT DISCUSSION ID: $discussionId');
      debugPrint('DISCUSSION EXISTS: ${document.exists}');

      if (!document.exists) {
        return null;
      }

      debugPrint('DISCUSSION DATA: ${document.data()}');

      return DiscussionModel.fromFirestore(document);
    } catch (e, stackTrace) {
      debugPrint('GET REPORTED DISCUSSION ERROR: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  Future<void> resolveReport(String reportId, String adminId) async {
    await _reports.doc(reportId).update({
      'status': 'Resolved',
      'reviewedBy': adminId,
      'reviewedDate': FieldValue.serverTimestamp(),
    });
  }
}
