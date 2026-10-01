import 'package:fyp_application/models/report.dart';
import '../services/report_service.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/models/user.dart';
import 'package:fyp_application/models/discussion.dart';

class ReportRepository {
  final ReportService _service;

  ReportRepository(this._service);

  Future<void> createReport(ReportModel report) {
    return _service.createReport(report);
  }

  Future<List<ReportModel>> getReports() {
    return _service.getReports();
  }

  Future<List<ReportModel>> getPendingReports() {
    return _service.getPendingReports();
  }

  Future<void> updateReport(ReportModel report) {
    return _service.updateReport(report);
  }

  Future<void> deleteReport(String reportId) {
    return _service.deleteReport(reportId);
  }

  Future<VendorModel?> getReportedVendor(String vendorId) {
    return _service.getReportedVendor(vendorId);
  }

  Future<MenuModel?> getReportedMenu(String menuId) {
    return _service.getReportedMenu(menuId);
  }

  Future<UserModel?> getReportedUser(String userId) {
    return _service.getReportedUser(userId);
  }

  Future<DiscussionModel?> getReportedDiscussion(String discussionId) {
    return _service.getReportedDiscussion(discussionId);
  }

  Future<void> resolveReport(String reportId, String adminId) {
    return _service.resolveReport(reportId, adminId);
  }
}
