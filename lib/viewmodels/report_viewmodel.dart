import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/report.dart';
import '../repositories/report_repository.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/models/user.dart';
import 'package:fyp_application/models/discussion.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository _repository;

  ReportViewModel(this._repository);

  List<ReportModel> _reports = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadReports() async {
    _setLoading(true);

    try {
      debugPrint('VIEWMODEL: Loading reports...');

      _reports = await _repository.getReports();

      debugPrint('VIEWMODEL: Reports loaded: ${_reports.length}');

      _errorMessage = null;
    } catch (e, stackTrace) {
      debugPrint('VIEWMODEL ERROR: $e');
      debugPrint('VIEWMODEL STACK TRACE: $stackTrace');

      _errorMessage = 'Failed to load reports: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPendingReports() async {
    _setLoading(true);

    try {
      _reports = await _repository.getPendingReports();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load reports.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createReport(ReportModel report) async {
    _setLoading(true);

    try {
      await _repository.createReport(report);

      _reports.add(report);

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit report.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReport(ReportModel report) async {
    _setLoading(true);

    try {
      await _repository.updateReport(report);

      final index = _reports.indexWhere(
        (item) => item.reportId == report.reportId,
      );

      if (index != -1) {
        _reports[index] = report;
      }

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update report.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<VendorModel?> getReportedVendor(String vendorId) {
    return _repository.getReportedVendor(vendorId);
  }

  Future<MenuModel?> getReportedMenu(String menuId) {
    return _repository.getReportedMenu(menuId);
  }

  Future<UserModel?> getReportedUser(String userId) {
    return _repository.getReportedUser(userId);
  }

  Future<DiscussionModel?> getReportedDiscussion(String discussionId) {
    return _repository.getReportedDiscussion(discussionId);
  }

  Future<bool> resolveReport(ReportModel report) async {
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid;

      if (adminId == null) {
        _errorMessage = 'Admin is not logged in.';
        notifyListeners();
        return false;
      }

      await _repository.resolveReport(report.reportId, adminId);

      final index = _reports.indexWhere(
        (item) => item.reportId == report.reportId,
      );

      if (index != -1) {
        _reports[index] = report.copyWith(
          status: 'Resolved',
          reviewedBy: adminId,
          reviewedDate: DateTime.now(),
        );
      }

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to resolve report.';
      notifyListeners();
      return false;
    }
  }
}
